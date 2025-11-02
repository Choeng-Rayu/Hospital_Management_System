import 'presentation/controllers/main_menu_controller.dart';

/// Entry point for the Hospital Management System
/// This is a console-based application for managing hospital operations
void main() async {
  // Create and run the main menu controller
  final controller = MainMenuController();
  await controller.run();
}
