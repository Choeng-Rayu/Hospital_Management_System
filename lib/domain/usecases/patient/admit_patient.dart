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
    final exists = await patientRepository.patientExists(patient.patientID);
    if (exists) {
      throw PatientAlreadyExistsException(
        'Patient with ID ${patient.patientID} already exists',
      );
    }

    final room = await roomRepository.getRoomById(roomId);

    if (!room.hasAvailableBeds) {
      throw NoAvailableBedsException(
        'Room $roomId has no available beds',
      );
    }

    final bed = room.beds.firstWhere(
      (b) => b.bedNumber == bedNumber,
      orElse: () => throw BedNotFoundException(
        'Bed $bedNumber not found in room $roomId',
      ),
    );

    if (!bed.isAvailable) {
      throw BedNotAvailableException(
        'Bed $bedNumber is already occupied',
      );
    }

    patient.assignToBed(room, bed);

    await patientRepository.savePatient(patient);

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
