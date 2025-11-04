/// UI utilities for console-based interface
import 'dart:io';

class UIHelper {
  /// Clear the console screen
  static void clearScreen() {
    if (Platform.isWindows) {
      print('\x1B[2J\x1B[0f'); // Windows
    } else {
      print('\x1B[2J\x1B[3J\x1B[H'); // Unix/Linux/macOS
    }
  }

  /// Print a header
  static void printHeader(String title) {
    print('\n${"=" * 60}');
    print(' ' * ((60 - title.length) ~/ 2) + title);
    print("=" * 60);
  }

  /// Print a subheader
  static void printSubHeader(String title) {
    print('\n${"-" * 60}');
    print(' ' * ((60 - title.length) ~/ 2) + title);
    print("-" * 60);
  }

  /// Print success message
  static void printSuccess(String message) {
    print('\n✅ $message');
  }

  /// Print error message
  static void printError(String message) {
    print('\n❌ $message');
  }

  /// Print warning message
  static void printWarning(String message) {
    print('\n⚠️  $message');
  }

  /// Print info message
  static void printInfo(String message) {
    print('\nℹ️  $message');
  }

  /// Print a menu with options
  static void printMenu(String title, List<String> options) {
    printHeader(title);
    for (var i = 0; i < options.length; i++) {
      print('${i + 1}. ${options[i]}');
    }
    print('0. Back/Exit');
  }

  /// Print a table with data
  static void printTable(List<List<String>> data, {List<String>? headers}) {
    if (data.isEmpty) {
      printWarning('No data to display');
      return;
    }

    // Calculate column widths
    final columnCount = data[0].length;
    final columnWidths = List.filled(columnCount, 0);

    // Include headers in width calculation
    if (headers != null) {
      for (var i = 0; i < headers.length; i++) {
        columnWidths[i] = headers[i].length;
      }
    }

    // Calculate maximum width for each column
    for (var row in data) {
      for (var i = 0; i < row.length; i++) {
        columnWidths[i] =
            columnWidths[i] > row[i].length ? columnWidths[i] : row[i].length;
      }
    }

    // Print headers
    if (headers != null) {
      _printTableRow(headers, columnWidths);
      _printTableSeparator(columnWidths);
    }

    // Print data
    for (var row in data) {
      _printTableRow(row, columnWidths);
    }
  }

  /// Print a table row
  static void _printTableRow(List<String> row, List<int> columnWidths) {
    final cells = row.asMap().entries.map((entry) {
      return entry.value.padRight(columnWidths[entry.key]);
    }).toList();
    print('| ${cells.join(' | ')} |');
  }

  /// Print table separator
  static void _printTableSeparator(List<int> columnWidths) {
    print('+${columnWidths.map((w) => '-' * (w + 2)).join('+')}+');
  }

  /// Display loading message
  static void showLoading(String message) {
    stdout.write('\r$message... ');
  }

  /// Update loading message
  static void updateLoading(String message) {
    stdout.write('\r$message');
  }

  /// Complete loading
  static void completeLoading(String message) {
    print('\r✅ $message');
  }

  /// Print a progress bar
  static void printProgressBar(int current, int total, {int width = 40}) {
    final percentage = (current / total * 100).toInt();
    final completed = (current / total * width).toInt();
    final remaining = width - completed;

    stdout.write('\r[');
    stdout.write('=' * completed);
    stdout.write('>' * (remaining > 0 ? 1 : 0));
    stdout.write(' ' * (remaining > 0 ? remaining - 1 : 0));
    stdout.write('] $percentage%');
  }

  /// Wait for user to press enter
  static void pressEnterToContinue() {
    print('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format time for display
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Format datetime for display
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Format duration in minutes to readable format
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours hour${hours > 1 ? 's' : ''}'
        '${remainingMinutes > 0 ? ' $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}' : ''}';
  }

  /// Print application header
  static void printApplicationHeader() {
    clearScreen();
    print('''
╔═══════════════════════════════════════════════════════════╗
║             HOSPITAL MANAGEMENT SYSTEM v1.0               ║
╚═══════════════════════════════════════════════════════════╝
''');
  }

  /// Print goodbye message
  static void printGoodbye() {
    printHeader('Thank you for using Hospital Management System!');
  }
}
