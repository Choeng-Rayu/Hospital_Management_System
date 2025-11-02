import 'package:hospital_management/domain/repositories/room_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

class RoomMenu extends BaseMenu {
  final RoomRepository roomRepository;

  RoomMenu({
    required this.roomRepository,
  });

  @override
  String get menuTitle => 'ROOM MANAGEMENT';

  @override
  List<String> get menuOptions => [
        'Add New Room',
        'View All Rooms',
        'View Room Details',
        'Update Room',
        'Delete Room',
        'View Available Rooms',
        'Assign Patient to Room',
        'Discharge Patient from Room',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _addRoom();
        break;
      case 2:
        await _viewAllRooms();
        break;
      case 3:
        await _viewRoomDetails();
        break;
      case 4:
        await _updateRoom();
        break;
      case 5:
        await _deleteRoom();
        break;
      case 6:
        await _viewAvailableRooms();
        break;
      case 7:
        await _assignPatientToRoom();
        break;
      case 8:
        await _dischargePatientFromRoom();
        break;
    }
  }

  Future<void> _addRoom() async {
    UIHelper.printInfo('Add New Room - Coming Soon');
  }

  Future<void> _viewAllRooms() async {
    UIHelper.printInfo('View All Rooms - Coming Soon');
  }

  Future<void> _viewRoomDetails() async {
    UIHelper.printInfo('View Room Details - Coming Soon');
  }

  Future<void> _updateRoom() async {
    UIHelper.printInfo('Update Room - Coming Soon');
  }

  Future<void> _deleteRoom() async {
    UIHelper.printInfo('Delete Room - Coming Soon');
  }

  Future<void> _viewAvailableRooms() async {
    UIHelper.printInfo('View Available Rooms - Coming Soon');
  }

  Future<void> _assignPatientToRoom() async {
    UIHelper.printInfo('Assign Patient to Room - Coming Soon');
  }

  Future<void> _dischargePatientFromRoom() async {
    UIHelper.printInfo('Discharge Patient from Room - Coming Soon');
  }
}
