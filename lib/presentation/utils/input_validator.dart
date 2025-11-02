/// Input validation utilities for the hospital management system
import 'dart:io';

class InputValidator {
  /// Validate and read string input
  static String readString(String prompt, {bool allowEmpty = false}) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (input.isEmpty && !allowEmpty) {
        print('❌ Input cannot be empty. Please try again.');
        continue;
      }

      return input;
    }
  }

  /// Validate and read integer input
  static int readInt(String prompt, {int? min, int? max}) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final number = int.tryParse(input);
      if (number == null) {
        print('❌ Please enter a valid number.');
        continue;
      }

      if (min != null && number < min) {
        print('❌ Number must be at least $min.');
        continue;
      }

      if (max != null && number > max) {
        print('❌ Number must be at most $max.');
        continue;
      }

      return number;
    }
  }

  /// Validate and read date input
  static DateTime readDate(String prompt) {
    while (true) {
      stdout.write('$prompt (YYYY-MM-DD): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      try {
        final date = DateTime.parse(input);
        return date;
      } catch (e) {
        print('❌ Invalid date format. Use YYYY-MM-DD.');
      }
    }
  }

  /// Validate and read choice from menu
  static int readChoice(int maxChoice) {
    while (true) {
      stdout.write('\nEnter your choice (0-$maxChoice): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final choice = int.tryParse(input);
      if (choice == null || choice < 0 || choice > maxChoice) {
        print('❌ Please enter a number between 0 and $maxChoice.');
        continue;
      }

      return choice;
    }
  }

  /// Read boolean (yes/no) input
  static bool readBoolean(String prompt) {
    while (true) {
      stdout.write('$prompt (y/n): ');
      final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

      if (input == 'y' || input == 'yes') return true;
      if (input == 'n' || input == 'no') return false;

      print('❌ Please enter y or n.');
    }
  }

  /// Validate and read ID with specific format
  static String readId(String prompt, String prefix) {
    while (true) {
      stdout.write('$prompt (format: ${prefix}XXX): ');
      final input = stdin.readLineSync()?.trim().toUpperCase() ?? '';

      if (!input.startsWith(prefix)) {
        print('❌ ID must start with $prefix.');
        continue;
      }

      if (input.length != 4) {
        print('❌ ID must be 4 characters (e.g., ${prefix}001).');
        continue;
      }

      if (!RegExp(r'^[A-Z][0-9]{3}$').hasMatch(input)) {
        print('❌ Invalid format. Use ${prefix}XXX where X is a number.');
        continue;
      }

      return input;
    }
  }

  /// Validate and read time input
  static String readTime(String prompt) {
    while (true) {
      stdout.write('$prompt (HH:MM): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(input)) {
        return input;
      }

      print('❌ Invalid time format. Use HH:MM (24-hour format).');
    }
  }

  /// Read and validate email
  static String readEmail(String prompt) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(input)) {
        return input;
      }

      print('❌ Invalid email format.');
    }
  }

  /// Read and validate phone number
  static String readPhone(String prompt) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(input)) {
        return input;
      }

      print('❌ Invalid phone number format.');
    }
  }

  /// Validate and read blood type
  static String readBloodType(String prompt) {
    final validTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    while (true) {
      stdout.write('$prompt ${validTypes.join('/')}: ');
      final input = stdin.readLineSync()?.trim().toUpperCase() ?? '';

      if (validTypes.contains(input)) {
        return input;
      }

      print('❌ Invalid blood type. Use: ${validTypes.join(", ")}');
    }
  }

  /// Read multiple lines of text
  static List<String> readMultipleLines(String prompt,
      {String endMarker = 'END'}) {
    print('$prompt (type $endMarker on a new line when finished):');
    final lines = <String>[];

    while (true) {
      final input = stdin.readLineSync()?.trim() ?? '';
      if (input.toUpperCase() == endMarker) break;
      lines.add(input);
    }

    return lines;
  }
}
