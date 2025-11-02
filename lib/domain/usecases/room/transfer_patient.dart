import '../../repositories/room_repository.dart';
import '../../repositories/patient_repository.dart';

/// Use case for transferring a patient to a different room
class TransferPatient {
  final RoomRepository roomRepository;
  final PatientRepository patientRepository;

  TransferPatient({
    required this.roomRepository,
    required this.patientRepository,
  });

  /// Execute patient transfer
  ///
  /// Steps:
  /// 1. Validate patient exists and is admitted
  /// 2. Validate target room exists and has available beds
  /// 3. Discharge from current bed
  /// 4. Assign to new bed
  /// 5. Update both rooms and patient
  Future<void> execute({
    required String patientId,
    required String targetRoomId,
    required String targetBedNumber,
  }) async {
    // 1. Get patient
    final patient = await patientRepository.getPatientById(patientId);

    // 2. Validate patient is currently admitted
    if (patient.currentRoom == null || patient.currentBed == null) {
      throw PatientNotAdmittedException(
        'Patient $patientId is not currently admitted',
      );
    }

    // 3. Get current room
    final currentRoom = patient.currentRoom!;

    // 4. Get target room
    final targetRoom = await roomRepository.getRoomById(targetRoomId);

    // 5. Check if target room has available beds
    if (!targetRoom.hasAvailableBeds) {
      throw NoAvailableBedsException(
        'Target room $targetRoomId has no available beds',
      );
    }

    // 6. Find target bed
    final targetBed = targetRoom.beds.firstWhere(
      (b) => b.bedNumber == targetBedNumber,
      orElse: () => throw BedNotFoundException(
        'Bed $targetBedNumber not found in room $targetRoomId',
      ),
    );

    // 7. Check if target bed is available
    if (!targetBed.isAvailable) {
      throw BedNotAvailableException(
        'Bed $targetBedNumber is already occupied',
      );
    }

    // 8. Discharge from current bed
    patient.discharge();

    // 9. Assign to new bed
    patient.assignToBed(targetRoom, targetBed);

    // 10. Update all records
    await patientRepository.updatePatient(patient);
    await roomRepository.updateRoom(currentRoom);
    await roomRepository.updateRoom(targetRoom);
  }
}

// Custom exceptions
class PatientNotAdmittedException implements Exception {
  final String message;
  PatientNotAdmittedException(this.message);
  @override
  String toString() => message;
}

class NoAvailableBedsException implements Exception {
  final String message;
  NoAvailableBedsException(this.message);
  @override
  String toString() => message;
}

class BedNotFoundException implements Exception {
  final String message;
  BedNotFoundException(this.message);
  @override
  String toString() => message;
}

class BedNotAvailableException implements Exception {
  final String message;
  BedNotAvailableException(this.message);
  @override
  String toString() => message;
}
