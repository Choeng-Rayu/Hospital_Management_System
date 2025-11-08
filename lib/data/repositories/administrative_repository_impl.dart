import '../../domain/repositories/administrative_repository.dart';
import '../../domain/entities/administrative.dart';
import 'package:hospital_management/data/datasources/local/administrative_local_data_source.dart';
import '../models/administrative_model.dart';

/// Implementation of AdministrativeRepository using local JSON data sources
class AdministrativeRepositoryImpl implements AdministrativeRepository {
  final AdministrativeLocalDataSource _administrativeDataSource;

  AdministrativeRepositoryImpl({
    required AdministrativeLocalDataSource administrativeDataSource,
  }) : _administrativeDataSource = administrativeDataSource;

  @override
  Future<Administrative> getAdministrativeById(String staffId) async {
    final model = await _administrativeDataSource.findByStaffId(staffId);
    if (model == null) {
      throw Exception('Administrative staff with ID $staffId not found');
    }

    return model.toEntity();
  }

  @override
  Future<List<Administrative>> getAllAdministrative() async {
    final models = await _administrativeDataSource.readAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveAdministrative(Administrative administrative) async {
    final model = AdministrativeModel.fromEntity(administrative);

    // Check if administrative staff exists
    final exists = await _administrativeDataSource
        .administrativeExists(administrative.staffID);

    if (exists) {
      await _administrativeDataSource.update(
        administrative.staffID,
        model,
        (a) => a.staffID,
        (a) => a.toJson(),
      );
    } else {
      await _administrativeDataSource.add(
        model,
        (a) => a.staffID,
        (a) => a.toJson(),
      );
    }
  }

  @override
  Future<void> updateAdministrative(Administrative administrative) async {
    final model = AdministrativeModel.fromEntity(administrative);

    // Check if administrative staff exists
    final exists = await _administrativeDataSource
        .administrativeExists(administrative.staffID);

    if (!exists) {
      throw Exception(
          'Administrative staff with ID ${administrative.staffID} not found for update');
    }

    await _administrativeDataSource.update(
      administrative.staffID,
      model,
      (a) => a.staffID,
      (a) => a.toJson(),
    );
  }

  @override
  Future<void> deleteAdministrative(String staffId) async {
    await _administrativeDataSource.delete(
      staffId,
      (a) => a.staffID,
      (a) => a.toJson(),
    );
  }

  @override
  Future<List<Administrative>> searchAdministrativeByName(String name) async {
    final models =
        await _administrativeDataSource.findAdministrativeByName(name);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Administrative>> getAdministrativeByResponsibility(
      String responsibility) async {
    final models = await _administrativeDataSource
        .findAdministrativeByResponsibility(responsibility);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> administrativeExists(String staffId) async {
    return await _administrativeDataSource.administrativeExists(staffId);
  }
}
