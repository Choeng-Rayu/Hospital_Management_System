import '../../entities/bed.dart';
import '../../entities/room.dart';
import '../../repositories/room_repository.dart';
import '../../repositories/patient_repository.dart';
import '../base/use_case.dart';

/// Input for reserving a bed
class ReserveBedInput {
  final String bedId;
  final String roomId;
  final String patientId;
  final DateTime reservationDate;
  final String? notes;

  ReserveBedInput({
    required this.bedId,
    required this.roomId,
    required this.patientId,
    required this.reservationDate,
    this.notes,
  });
}

/// Output for bed reservation
class BedReservationResult {
  final Bed reservedBed;
  final String roomId;
  final String patientId;
  final DateTime reservationDate;
  final String confirmationNumber;

  BedReservationResult({
    required this.reservedBed,
    required this.roomId,
    required this.patientId,
    required this.reservationDate,
    required this.confirmationNumber,
  });

  @override
  String toString() {
    return 'Bed ${reservedBed.bedNumber} reserved for patient $patientId on ${reservationDate.toString().split(' ')[0]} (Confirmation: $confirmationNumber)';
  }
}

/// Use case for reserving a bed for future patient admission
/// Ensures beds can be pre-allocated for scheduled procedures
class ReserveBed extends UseCase<ReserveBedInput, BedReservationResult> {
  final RoomRepository roomRepository;
  final PatientRepository patientRepository;

  ReserveBed({
    required this.roomRepository,
    required this.patientRepository,
  });

  @override
  Future<bool> validate(ReserveBedInput input) async {
    // Validate reservation date is not in the past
    final now = DateTime.now();
    if (input.reservationDate
        .isBefore(now.subtract(const Duration(hours: 1)))) {
      throw UseCaseValidationException(
        'Reservation date cannot be in the past',
      );
    }

    // Validate reservation is not too far in the future (max 30 days)
    final maxDate = now.add(const Duration(days: 30));
    if (input.reservationDate.isAfter(maxDate)) {
      throw UseCaseValidationException(
        'Cannot reserve bed more than 30 days in advance',
      );
    }
    return true;
  }

  @override
  Future<BedReservationResult> execute(ReserveBedInput input) async {
    // Get the room to verify bed existence
    final room = await roomRepository.getRoomById(input.roomId);

    // Find the specific bed
    final bed = room.beds.firstWhere(
      (b) => b.bedNumber == input.bedId,
      orElse: () => throw EntityNotFoundException(
        'Bed',
        input.bedId,
      ),
    );

    // Check if bed is available
    if (!bed.isAvailable) {
      throw EntityConflictException(
        'Bed is already occupied or reserved',
      );
    }

    // Create updated bed with reservation
    // Create a patient for the bed
    final patient = await patientRepository.getPatientById(input.patientId);
    final updatedBed = Bed(
      bedNumber: bed.bedNumber,
      bedType: bed.bedType,
      isOccupied: true,
      patient: patient,
      features: bed.features.toList(),
    );

    // Update the room with the reserved bed
    final updatedBeds = room.beds.map((b) {
      return b.bedNumber == input.bedId ? updatedBed : b;
    }).toList();

    // Create a new room with updated beds
    final updatedRoom = Room(
      roomId: room.roomId,
      number: room.number,
      roomType: room.roomType,
      status: room.status,
      equipment: room.equipment.toList(),
      beds: updatedBeds,
    );
    await roomRepository.updateRoom(updatedRoom);

    // Generate confirmation number
    final confirmationNumber =
        'BR-${input.roomId.substring(0, 4)}-${input.bedId.substring(0, 4)}-${DateTime.now().millisecondsSinceEpoch % 10000}';

    return BedReservationResult(
      reservedBed: updatedBed,
      roomId: input.roomId,
      patientId: input.patientId,
      reservationDate: input.reservationDate,
      confirmationNumber: confirmationNumber,
    );
  }

  @override
  @override
  Future<void> onSuccess(
      BedReservationResult result, ReserveBedInput input) async {
    // Could trigger notifications, update scheduling system, etc.
    print('✅ Bed reserved: ${result.confirmationNumber}');
  }
}
