import 'dart:io';
import 'dart:convert';

/// Base class for JSON file operations
/// Provides common CRUD operations for JSON persistence
///
/// Type parameter [T] represents the model type
class JsonDataSource<T> {
  final String fileName;
  final String dataDirectory;
  final T Function(Map<String, dynamic>) fromJson;

  JsonDataSource({
    required this.fileName,
    required this.fromJson,
    this.dataDirectory = 'data',
  }) {
    _ensureDirectoryExists();
  }

  /// Ensure the data directory exists
  void _ensureDirectoryExists() {
    final dir = Directory(dataDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Get the full file path
  String get _filePath => '$dataDirectory/$fileName';

  /// Read all records from the JSON file
  /// Returns empty list if file doesn't exist
  Future<List<T>> readAll() async {
    try {
      final file = File(_filePath);

      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.trim().isEmpty) {
        return [];
      }

      final data = json.decode(contents);
      if (data is List) {
        return data
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw DataSourceException('Failed to read from $fileName: $e', e);
    }
  }

  /// Write all records to the JSON file
  Future<void> writeAll(
      List<T> items, Map<String, dynamic> Function(T) toJson) async {
    try {
      final file = File(_filePath);
      final jsonList = items.map(toJson).toList();
      final jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      throw DataSourceException('Failed to write to $fileName: $e', e);
    }
  }

  /// Find a record by ID
  Future<T?> findById(
    String id,
    String Function(T) idGetter,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final items = await readAll();
    try {
      return items.firstWhere((item) => idGetter(item) == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new record
  Future<void> add(
    T item,
    String Function(T) idGetter,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final items = await readAll();
    final id = idGetter(item);

    // Check if already exists
    if (items.any((existing) => idGetter(existing) == id)) {
      throw DataSourceException('Item with ID $id already exists');
    }

    items.add(item);
    await writeAll(items, toJson);
  }

  /// Update an existing record
  Future<void> update(
    String id,
    T item,
    String Function(T) idGetter,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final items = await readAll();
    final index = items.indexWhere((existing) => idGetter(existing) == id);

    if (index == -1) {
      throw DataSourceException('Item with ID $id not found');
    }

    items[index] = item;
    await writeAll(items, toJson);
  }

  /// Delete a record by ID
  Future<void> delete(
    String id,
    String Function(T) idGetter,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final items = await readAll();
    items.removeWhere((item) => idGetter(item) == id);
    await writeAll(items, toJson);
  }

  /// Check if a record exists
  Future<bool> exists(
    String id,
    String Function(T) idGetter,
  ) async {
    final items = await readAll();
    return items.any((item) => idGetter(item) == id);
  }

  /// Find records matching a predicate
  Future<List<T>> findWhere(bool Function(T) predicate) async {
    final items = await readAll();
    return items.where(predicate).toList();
  }

  /// Clear all records
  Future<void> clear(Map<String, dynamic> Function(T) toJson) async {
    await writeAll([], toJson);
  }
}

/// Exception thrown by data source operations
class DataSourceException implements Exception {
  final String message;
  final dynamic originalError;

  DataSourceException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'DataSourceException: $message\nOriginal error: $originalError';
    }
    return 'DataSourceException: $message';
  }
}
