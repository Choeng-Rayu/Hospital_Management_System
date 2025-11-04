/// Base menu class that all menu classes will extend
import 'package:hospital_management/presentation/utils/input_validator.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

abstract class BaseMenu {
  String get menuTitle;
  List<String> get menuOptions;

  Future<void> show() async {
    bool isRunning = true;

    while (isRunning) {
      try {
        UIHelper.clearScreen();
        UIHelper.printMenu(menuTitle, menuOptions);

        final choice = InputValidator.readChoice(menuOptions.length);
        if (choice == 0) {
          isRunning = false;
          continue;
        }

        await handleChoice(choice);
        UIHelper.pressEnterToContinue();
      } catch (e) {
        UIHelper.printError('An error occurred: $e');
        UIHelper.pressEnterToContinue();
      }
    }
  }

  Future<void> handleChoice(int choice);
}
