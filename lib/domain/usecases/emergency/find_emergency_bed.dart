import '../../entities/enums/emergency_level.dart';
import '../../entities/room.dart';
import '../../entities/bed.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Room score for emergency bed selection
class _RoomScore {
  final num score;
  final Room room;
  final Bed bed;
  final double distance;
  final int responseTime;

  _RoomScore({
    required this.score,
    required this.room,
    required this.bed,
    required this.distance,
    required this.responseTime,
  });
}

/// Input for finding emergency bed
class FindEmergencyBedInput {
  final EmergencyLevel emergencyLevel;
  final bool requiresICU;
  final List<String>? requiredFeatures;
  final String? preferredFloor;

  FindEmergencyBedInput({
    required this.emergencyLevel,
    this.requiresICU = false,
    this.requiredFeatures,
    this.preferredFloor,
  });
}

/// Emergency bed assignment result
class EmergencyBedAssignment {
  final String bedId;
  final String bedNumber;
  final String roomId;
  final String roomNumber;
  final String roomType;
  final double distanceFromER; // in meters
  final int responseTime; // in seconds
  final List<String> availableEquipment;

  EmergencyBedAssignment({
    required this.bedId,
    required this.bedNumber,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.distanceFromER,
    required this.responseTime,
    required this.availableEquipment,
  });

  @override
  String toString() {
    return 'Room $roomNumber - Bed $bedNumber ($roomType) - ${responseTime}s response time';
  }
}

/// Use case for finding the most appropriate bed for emergency patient
/// Optimizes for proximity and required equipment
class FindEmergencyBed
    extends UseCase<FindEmergencyBedInput, EmergencyBedAssignment> {
  final RoomRepository roomRepository;

  FindEmergencyBed({required this.roomRepository});

  @override
  Future<bool> validate(FindEmergencyBedInput input) async {
    // No validation needed - emergency situations override normal rules
    return true;
  }

  @override
  Future<EmergencyBedAssignment> execute(FindEmergencyBedInput input) async {
    // Get all available rooms
    final allRooms = await roomRepository.getAvailableRooms();

    if (allRooms.isEmpty) {
      throw BusinessRuleViolationException(
        'No available rooms for emergency admission',
        'ALL_ROOMS_OCCUPIED',
      );
    }

    // Filter by ICU requirement
    List<Room> candidateRooms = allRooms;
    if (input.requiresICU) {
      candidateRooms = allRooms
          .where((room) => room.roomType.toString().contains('ICU'))
          .toList();

      if (candidateRooms.isEmpty) {
        throw BusinessRuleViolationException(
          'No ICU beds available for critical patient',
          'ICU_CAPACITY_FULL',
        );
      }
    }

    // Score each room based on emergency criteria
    final scoredRooms = <_RoomScore>[];

    for (final room in candidateRooms) {
      // Find available beds
      final availableBeds = room.beds.where((bed) => bed.isAvailable).toList();

      if (availableBeds.isEmpty) continue;

      for (final bed in availableBeds) {
        num score = 0;

        // Priority 1: Room type matches emergency level
        if (input.emergencyLevel == EmergencyLevel.CRITICAL &&
            room.roomType.toString().contains('ICU')) {
          score += 100;
        }

        // Priority 2: Required features available
        if (input.requiredFeatures != null) {
          final roomEquipmentIds = room.equipment.map((e) => e.name).toSet();
          final matchingFeatures = input.requiredFeatures!
              .where((feature) => roomEquipmentIds.contains(feature))
              .length;
          score += matchingFeatures * 20;
        }

        // Priority 3: Bed features
        score += (bed.features.length * 10).toInt();

        // Priority 4: Proximity to ER (simulated based on room number)
        final roomNum =
            int.tryParse(room.number.replaceAll(RegExp(r'[^0-9]'), '')) ?? 100;
        final proximityScore =
            100 - (roomNum % 100); // Lower room numbers = closer
        score += proximityScore;

        scoredRooms.add(_RoomScore(
          score: score,
          room: room,
          bed: bed,
          distance: roomNum.toDouble() * 5, // Simulate distance in meters
          responseTime: (roomNum % 50) + 30, // 30-80 seconds
        ));
      }
    }

    if (scoredRooms.isEmpty) {
      throw BusinessRuleViolationException(
        'No suitable beds available for emergency criteria',
        'NO_MATCHING_BEDS',
      );
    }

    // Sort by score (highest first)
    scoredRooms.sort((a, b) => b.score.compareTo(a.score));

    // Select best option
    final best = scoredRooms.first;

    return EmergencyBedAssignment(
      bedId: best.bed.bedNumber, // Bed uses bedNumber as identifier
      bedNumber: best.bed.bedNumber,
      roomId: best.room.roomId,
      roomNumber: best.room.number,
      roomType: best.room.roomType.toString(),
      distanceFromER: best.distance,
      responseTime: best.responseTime,
      availableEquipment: best.room.equipment.map((e) => e.name).toList(),
    );
  }

  @override
  @override
  Future<void> onSuccess(
      EmergencyBedAssignment result, FindEmergencyBedInput input) async {
    print(
        '🚨 Emergency bed assigned: ${result.roomNumber} - ${result.bedNumber}');
    print('   Response time: ${result.responseTime}s');
  }
}
