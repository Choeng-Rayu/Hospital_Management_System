import '../../repositories/room_repository.dart';
import '../base/use_case.dart';
import '../room/get_available_icu_beds.dart';

/// Output for ICU capacity check
class ICUCapacityStatus {
  final ICUBedAvailability bedAvailability;
  final int onCallStaff;
  final int ventilatorAvailability;
  final bool canAcceptCriticalPatients;
  final String capacityLevel; // 'NORMAL', 'WARNING', 'CRITICAL', 'FULL'
  final String recommendations;

  ICUCapacityStatus({
    required this.bedAvailability,
    required this.onCallStaff,
    required this.ventilatorAvailability,
    required this.canAcceptCriticalPatients,
    required this.capacityLevel,
    required this.recommendations,
  });

  @override
  String toString() {
    final emoji = _getCapacityEmoji(capacityLevel);
    return '''
$emoji ICU CAPACITY STATUS: $capacityLevel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${bedAvailability.toString()}
Ventilators Available: $ventilatorAvailability
On-Call Staff: $onCallStaff
Can Accept Critical: ${canAcceptCriticalPatients ? 'YES ✓' : 'NO ✗'}

📋 Recommendations:
$recommendations
''';
  }

  String _getCapacityEmoji(String level) {
    switch (level) {
      case 'NORMAL':
        return '🟢';
      case 'WARNING':
        return '🟡';
      case 'CRITICAL':
        return '🟠';
      case 'FULL':
        return '🔴';
      default:
        return '⚪';
    }
  }
}

/// Use case for getting comprehensive ICU capacity status
/// Critical for emergency department and transfer decisions
class GetAvailableICUCapacity extends NoInputUseCase<ICUCapacityStatus> {
  final RoomRepository roomRepository;

  GetAvailableICUCapacity({required this.roomRepository});

  @override
  Future<ICUCapacityStatus> execute() async {
    final getICUBedsUseCase =
        GetAvailableICUBeds(roomRepository: roomRepository);
    final bedAvailability = await getICUBedsUseCase.call();

    final allRooms = await roomRepository.getAllRooms();
    final icuRooms = allRooms
        .where((room) => room.roomType.toString().contains('ICU'))
        .toList();

    int ventilatorCount = 0;
    for (final room in icuRooms) {
      ventilatorCount += room.equipment
          .where((eq) =>
              eq.name.toLowerCase().contains('ventilator') &&
              eq.status.toString().contains('AVAILABLE'))
          .length;
    }

    // Simulate on-call staff count (in real impl, query staff repository)
    final onCallStaff = 8; // Typical ICU staffing

    final occupancyPercent = bedAvailability.occupancyPercentage;
    String capacityLevel;
    bool canAcceptCriticalPatients;

    if (occupancyPercent >= 95) {
      capacityLevel = 'FULL';
      canAcceptCriticalPatients = false;
    } else if (occupancyPercent >= 85) {
      capacityLevel = 'CRITICAL';
      canAcceptCriticalPatients = ventilatorCount > 0;
    } else if (occupancyPercent >= 70) {
      capacityLevel = 'WARNING';
      canAcceptCriticalPatients = true;
    } else {
      capacityLevel = 'NORMAL';
      canAcceptCriticalPatients = true;
    }

    final recommendations = _generateRecommendations(
      bedAvailability,
      ventilatorCount,
      capacityLevel,
    );

    return ICUCapacityStatus(
      bedAvailability: bedAvailability,
      onCallStaff: onCallStaff,
      ventilatorAvailability: ventilatorCount,
      canAcceptCriticalPatients: canAcceptCriticalPatients,
      capacityLevel: capacityLevel,
      recommendations: recommendations,
    );
  }

  String _generateRecommendations(
    ICUBedAvailability bedAvailability,
    int ventilatorCount,
    String capacityLevel,
  ) {
    final recommendations = <String>[];

    switch (capacityLevel) {
      case 'FULL':
        recommendations.add('⚠️ ICU AT FULL CAPACITY - Consider:');
        recommendations.add('  • Transfer stable patients to step-down units');
        recommendations.add('  • Contact nearby hospitals for transfers');
        recommendations.add('  • Activate surge capacity protocol');
        recommendations.add('  • Alert hospital administration');
        break;

      case 'CRITICAL':
        recommendations.add('🔴 ICU CAPACITY CRITICAL - Actions needed:');
        recommendations.add('  • Prepare for possible diversions');
        recommendations.add('  • Review patients for step-down eligibility');
        recommendations.add('  • Alert charge nurse');
        if (ventilatorCount < 2) {
          recommendations
              .add('  • Low ventilator availability - prepare alternatives');
        }
        break;

      case 'WARNING':
        recommendations.add('🟡 ICU CAPACITY ELEVATED - Monitor closely:');
        recommendations.add('  • Track admission trends');
        recommendations.add('  • Ensure on-call staff readiness');
        recommendations.add('  • Review discharge planning');
        break;

      case 'NORMAL':
        recommendations.add('🟢 ICU CAPACITY NORMAL - Maintain:');
        recommendations.add('  • Continue standard protocols');
        recommendations.add('  • Available for emergency admissions');
        recommendations
            .add('  • ${bedAvailability.availableICUBeds} beds ready');
        break;
    }

    return recommendations.join('\n');
  }
}
