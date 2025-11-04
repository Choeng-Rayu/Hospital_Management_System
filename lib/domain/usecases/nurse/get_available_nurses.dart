import '../../entities/nurse.dart';
import '../../repositories/nurse_repository.dart';
import '../base/use_case.dart';

/// Criteria for searching available nurses
class GetAvailableNursesInput {
  final int? maxPatients;
  final int? maxRooms;
  final String? specialization;
  final DateTime? availableAt;

  GetAvailableNursesInput({
    this.maxPatients = 5,
    this.maxRooms = 4,
    this.specialization,
    this.availableAt,
  });
}

/// Use case for finding available nurses based on various criteria
/// Helps with efficient nurse assignment
class GetAvailableNurses extends UseCase<GetAvailableNursesInput, List<Nurse>> {
  final NurseRepository nurseRepository;

  GetAvailableNurses({required this.nurseRepository});

  @override
  Future<List<Nurse>> execute(GetAvailableNursesInput input) async {
    // Get all available nurses (with capacity)
    final availableNurses = await nurseRepository.getAvailableNurses();

    // Apply filters
    List<Nurse> filteredNurses = availableNurses;

    // Filter by maximum patients
    if (input.maxPatients != null) {
      filteredNurses = filteredNurses
          .where((nurse) => nurse.assignedPatients.length < input.maxPatients!)
          .toList();
    }

    // Filter by maximum rooms
    if (input.maxRooms != null) {
      filteredNurses = filteredNurses
          .where((nurse) => nurse.assignedRooms.length < input.maxRooms!)
          .toList();
    }

    // Filter by schedule availability at specific time
    if (input.availableAt != null) {
      filteredNurses = filteredNurses.where((nurse) {
        final dateKey =
            '${input.availableAt!.year}-${input.availableAt!.month.toString().padLeft(2, '0')}-${input.availableAt!.day.toString().padLeft(2, '0')}';

        // Check if nurse has a schedule for this date
        return nurse.schedule.containsKey(dateKey);
      }).toList();
    }

    // Sort by workload (ascending - least busy first)
    filteredNurses.sort((a, b) {
      final aLoad = a.assignedPatients.length + a.assignedRooms.length;
      final bLoad = b.assignedPatients.length + b.assignedRooms.length;
      return aLoad.compareTo(bLoad);
    });

    return filteredNurses;
  }
}
