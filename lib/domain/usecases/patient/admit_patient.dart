import '../../entities/patient.dart';

import '../../repositories/patient_repository.dart';
import '../../repositories/room_repository.dart';

/// Use case for admitting a new patient to the hospital
/// Handles the complete admission process including room assignment
class AdmitPatient {
  final PatientRepository patientRepository;
  final RoomRepository roomRepository;

  AdmitPatient({
    required this.patientRepository,
    required this.roomRepository,
  });

  /// Execute the patient admission process
  ///
  /// Steps:
  /// 1. Validate patient doesn't already exist
  /// 2. Validate room and bed availability
  /// 3. Assign patient to bed
  /// 4. Save patient information
  /// 5. Update room information
  Future<Patient> execute({
    required Patient patient,
    required String roomId,
    required String bedNumber,
  }) async {
    // 1. Check if patient already exists
    final exists = await patientRepository.patientExists(patient.patientID);
    if (exists) {
      throw PatientAlreadyExistsException(
        'Patient with ID ${patient.patientID} already exists',
      );
    }

    // 2. Get the room
    final room = await roomRepository.getRoomById(roomId);

    // 3. Check if room has available beds
    if (!room.hasAvailableBeds) {
      throw NoAvailableBedsException(
        'Room $roomId has no available beds',
      );
    }

    // 4. Find the specific bed
    final bed = room.beds.firstWhere(
      (b) => b.bedNumber == bedNumber,
      orElse: () => throw BedNotFoundException(
        'Bed $bedNumber not found in room $roomId',
      ),
    );

    // 5. Check if bed is available
    if (!bed.isAvailable) {
      throw BedNotAvailableException(
        'Bed $bedNumber is already occupied',
      );
    }

    // 6. Assign patient to bed
    patient.assignToBed(room, bed);

    // 7. Save patient
    await patientRepository.savePatient(patient);

    // 8. Update room (bed assignment is already done in patient.assignToBed)
    await roomRepository.updateRoom(room);

    return patient;
  }
}

// Custom exceptions for better error handling
class PatientAlreadyExistsException implements Exception {
  final String message;
  PatientAlreadyExistsException(this.message);
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
