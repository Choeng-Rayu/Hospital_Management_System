import 'package:hospital_management/domain/repositories/room_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/entities/room.dart';
import 'package:hospital_management/domain/entities/bed.dart';
import 'package:hospital_management/domain/entities/enums/room_type.dart';
import 'package:hospital_management/domain/entities/enums/room_status.dart';
import 'package:hospital_management/domain/entities/enums/bed_type.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';

class RoomMenu extends BaseMenu {
  final RoomRepository roomRepository;
  final PatientRepository? patientRepository;

  RoomMenu({
    required this.roomRepository,
    this.patientRepository,
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
    UIHelper.printHeader('Add New Room');

    try {
      // Generate room ID
      final allRooms = await roomRepository.getAllRooms();
      final roomId = 'R${(allRooms.length + 1).toString().padLeft(3, '0')}';

      // Get room number
      final roomNumber =
          InputValidator.readString('Enter room number (e.g., 101, 202)');

      // Get room type
      UIHelper.printSubHeader('Select Room Type');
      print('1. General Ward');
      print('2. Private Room');
      print('3. ICU');
      print('4. Pediatric');
      print('5. Maternity');
      print('6. Isolation');
      print('7. Emergency');

      final typeChoice = InputValidator.readChoice(7);
      if (typeChoice == 0) return;

      final roomTypes = {
        1: RoomType.GENERAL_WARD,
        2: RoomType.PRIVATE_ROOM,
        3: RoomType.ICU,
        4: RoomType.PEDIATRIC,
        5: RoomType.MATERNITY,
        6: RoomType.ISOLATION,
        7: RoomType.EMERGENCY,
      };
      final roomType = roomTypes[typeChoice]!;

      // Get room status
      UIHelper.printSubHeader('Select Room Status');
      print('1. Available');
      print('2. Occupied');
      print('3. Under Maintenance');
      print('4. Reserved');
      print('5. Closed');

      final statusChoice = InputValidator.readChoice(5);
      if (statusChoice == 0) return;

      final roomStatuses = {
        1: RoomStatus.AVAILABLE,
        2: RoomStatus.OCCUPIED,
        3: RoomStatus.UNDER_MAINTENANCE,
        4: RoomStatus.RESERVED,
        5: RoomStatus.CLOSED,
      };
      final roomStatus = roomStatuses[statusChoice]!;

      // Add beds
      final bedCount =
          InputValidator.readInt('Enter number of beds', min: 1, max: 10);
      final beds = <Bed>[];

      for (var i = 1; i <= bedCount; i++) {
        UIHelper.printSubHeader('Bed $i');
        final bedNumber = InputValidator.readString(
            'Enter bed number (e.g., ${roomNumber}-$i)');

        // Get bed type
        print('Select Bed Type:');
        print('1. Standard');
        print('2. Premium');
        print('3. ICU Bed');
        print('4. Pediatric Bed');
        print('5. Stretcher');

        final bedTypeChoice = InputValidator.readChoice(5);
        if (bedTypeChoice == 0) return;

        final bedTypes = {
          1: BedType.STANDARD,
          2: BedType.PREMIUM,
          3: BedType.ICU_BED,
          4: BedType.PEDIATRIC_BED,
          5: BedType.STRETCHER,
        };
        final bedType = bedTypes[bedTypeChoice]!;

        // Get features
        final features = <String>[];
        var addFeature = InputValidator.readBoolean('Add bed features?');
        while (addFeature) {
          final feature = InputValidator.readString(
              'Enter feature (e.g., Oxygen, Monitor)');
          features.add(feature);
          addFeature = InputValidator.readBoolean('Add another feature?');
        }

        final bed = Bed(
          bedNumber: bedNumber,
          bedType: bedType,
          features: features,
        );
        beds.add(bed);
      }

      // Create room with empty equipment list for now
      final room = Room(
        roomId: roomId,
        number: roomNumber,
        roomType: roomType,
        status: roomStatus,
        equipment: [],
        beds: beds,
      );

      await roomRepository.saveRoom(room);

      UIHelper.printSuccess('Room added successfully!');
      UIHelper.printInfo('Room ID: $roomId');
      UIHelper.printInfo('Room Number: $roomNumber');
      UIHelper.printInfo('Beds: $bedCount');
    } catch (e) {
      UIHelper.printError('Failed to add room: $e');
    }
  }

  Future<void> _viewAllRooms() async {
    UIHelper.printHeader('All Rooms');

    try {
      final rooms = await roomRepository.getAllRooms();

      if (rooms.isEmpty) {
        UIHelper.printWarning('No rooms found');
        return;
      }

      final tableData = rooms
          .map((room) => [
                room.roomId,
                room.number,
                room.roomType.toString().split('.').last,
                room.status.toString().split('.').last,
                room.beds.length.toString(),
                room.availableBedCount.toString(),
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Number', 'Type', 'Status', 'Total Beds', 'Available'],
      );

      UIHelper.printInfo('Total rooms: ${rooms.length}');
    } catch (e) {
      UIHelper.printError('Failed to retrieve rooms: $e');
    }
  }

  Future<void> _viewRoomDetails() async {
    UIHelper.printHeader('Room Details');

    try {
      final roomId = InputValidator.readString('Enter room ID');
      final room = await roomRepository.getRoomById(roomId);

      _displayRoomDetails(room);
    } catch (e) {
      UIHelper.printError('Failed to retrieve room details: $e');
    }
  }

  Future<void> _updateRoom() async {
    UIHelper.printHeader('Update Room');

    try {
      final roomId = InputValidator.readString('Enter room ID');
      final room = await roomRepository.getRoomById(roomId);

      _displayRoomDetails(room);

      // Update room status
      UIHelper.printSubHeader('Select New Status');
      print('1. Available');
      print('2. Occupied');
      print('3. Under Maintenance');
      print('4. Reserved');
      print('5. Closed');

      final statusChoice = InputValidator.readChoice(5);
      if (statusChoice == 0) return;

      final roomStatuses = {
        1: RoomStatus.AVAILABLE,
        2: RoomStatus.OCCUPIED,
        3: RoomStatus.UNDER_MAINTENANCE,
        4: RoomStatus.RESERVED,
        5: RoomStatus.CLOSED,
      };

      final newStatus = roomStatuses[statusChoice]!;
      room.updateStatus(newStatus);
      await roomRepository.updateRoom(room);

      UIHelper.printSuccess('Room status updated successfully!');
      UIHelper.printInfo('New Status: ${newStatus.toString().split('.').last}');
    } catch (e) {
      UIHelper.printError('Failed to update room: $e');
    }
  }

  Future<void> _deleteRoom() async {
    UIHelper.printHeader('Delete Room');

    try {
      final roomId = InputValidator.readString('Enter room ID');
      final room = await roomRepository.getRoomById(roomId);

      _displayRoomDetails(room);

      final confirm = InputValidator.readBoolean(
        'Are you sure you want to delete this room?',
      );

      if (!confirm) {
        UIHelper.printInfo('Deletion cancelled');
        return;
      }

      await roomRepository.deleteRoom(roomId);
      UIHelper.printSuccess('Room deleted successfully');
    } catch (e) {
      UIHelper.printError('Failed to delete room: $e');
    }
  }

  Future<void> _viewAvailableRooms() async {
    UIHelper.printHeader('Available Rooms');

    try {
      final rooms = await roomRepository.getAvailableRooms();

      if (rooms.isEmpty) {
        UIHelper.printWarning('No available rooms found');
        return;
      }

      final tableData = rooms
          .map((room) => [
                room.roomId,
                room.number,
                room.roomType.toString().split('.').last,
                room.beds.length.toString(),
                room.availableBedCount.toString(),
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Number', 'Type', 'Total Beds', 'Available Beds'],
      );

      UIHelper.printInfo('Total available rooms: ${rooms.length}');
    } catch (e) {
      UIHelper.printError('Failed to retrieve available rooms: $e');
    }
  }

  Future<void> _assignPatientToRoom() async {
    UIHelper.printHeader('Assign Patient to Room');

    try {
      if (patientRepository == null) {
        UIHelper.printError('Patient repository not available');
        return;
      }

      // Get patient
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await patientRepository!.getPatientById(patientId);

      UIHelper.printInfo('Patient: ${patient.name}');

      // Get room
      final roomId = InputValidator.readString('Enter room ID');
      final room = await roomRepository.getRoomById(roomId);

      _displayRoomDetails(room);

      if (!room.hasAvailableBeds) {
        UIHelper.printWarning('No available beds in this room');
        return;
      }

      // Show available beds
      UIHelper.printSubHeader('Available Beds');
      final availableBeds = room.getAvailableBeds();
      for (var i = 0; i < availableBeds.length; i++) {
        print(
            '${i + 1}. ${availableBeds[i].bedNumber} (${availableBeds[i].bedType.toString().split('.').last})');
      }

      final bedChoice = InputValidator.readChoice(availableBeds.length);
      if (bedChoice == 0) return;

      final selectedBed = availableBeds[bedChoice - 1];
      room.assignPatientToBed(patient, selectedBed.bedNumber);
      await roomRepository.updateRoom(room);

      UIHelper.printSuccess('Patient assigned to room successfully!');
      UIHelper.printInfo('Patient: ${patient.name}');
      UIHelper.printInfo('Room: ${room.number}');
      UIHelper.printInfo('Bed: ${selectedBed.bedNumber}');
    } catch (e) {
      UIHelper.printError('Failed to assign patient to room: $e');
    }
  }

  Future<void> _dischargePatientFromRoom() async {
    UIHelper.printHeader('Discharge Patient from Room');

    try {
      if (patientRepository == null) {
        UIHelper.printError('Patient repository not available');
        return;
      }

      // Get patient
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await patientRepository!.getPatientById(patientId);

      UIHelper.printInfo('Patient: ${patient.name}');

      // Find room with this patient
      final allRooms = await roomRepository.getAllRooms();
      Room? patientRoom;

      for (final room in allRooms) {
        if (room.currentPatients.contains(patient)) {
          patientRoom = room;
          break;
        }
      }

      if (patientRoom == null) {
        UIHelper.printWarning('Patient not found in any room');
        return;
      }

      _displayRoomDetails(patientRoom);

      final confirm = InputValidator.readBoolean(
        'Confirm discharge for ${patient.name}?',
      );

      if (!confirm) {
        UIHelper.printInfo('Discharge cancelled');
        return;
      }

      patientRoom.dischargePatient(patient);
      await roomRepository.updateRoom(patientRoom);

      UIHelper.printSuccess('Patient discharged successfully!');
      UIHelper.printInfo('Patient: ${patient.name}');
      UIHelper.printInfo('Room: ${patientRoom.number}');
    } catch (e) {
      UIHelper.printError('Failed to discharge patient: $e');
    }
  }

  void _displayRoomDetails(Room room) {
    UIHelper.printSubHeader('Room Information');
    print('ID: ${room.roomId}');
    print('Number: ${room.number}');
    print('Type: ${room.roomType.toString().split('.').last}');
    print('Status: ${room.status.toString().split('.').last}');
    print('Total Beds: ${room.beds.length}');
    print('Available Beds: ${room.availableBedCount}');

    print('\nBeds:');
    for (final bed in room.beds) {
      print('  - ${bed.bedNumber} (${bed.bedType.toString().split('.').last})');
      print('    Status: ${bed.isAvailable ? "Available" : "Occupied"}');
      if (!bed.isAvailable && bed.currentPatient != null) {
        print('    Patient: ${bed.currentPatient!.name}');
      }
      if (bed.features.isNotEmpty) {
        print('    Features: ${bed.features.join(', ')}');
      }
    }

    if (room.equipment.isNotEmpty) {
      print('\nEquipment:');
      for (final equip in room.equipment) {
        print('  - ${equip.name} (${equip.status.toString().split('.').last})');
      }
    }

    if (room.currentPatients.isNotEmpty) {
      print('\nCurrent Patients:');
      for (final patient in room.currentPatients) {
        print('  - ${patient.name} (${patient.patientID})');
      }
    }
  }
}
