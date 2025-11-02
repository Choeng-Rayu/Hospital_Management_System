import '../../repositories/nurse_repository.dart';
import '../base/use_case.dart';

/// Output for nurse workload information
class NurseWorkload {
  final String nurseId;
  final String nurseName;
  final int assignedPatientsCount;
  final int assignedRoomsCount;
  final double workloadPercentage;
  final bool isOverloaded;
  final bool isAvailable;
  final List<String> assignedPatientNames;
  final List<String> assignedRoomNumbers;

  NurseWorkload({
    required this.nurseId,
    required this.nurseName,
    required this.assignedPatientsCount,
    required this.assignedRoomsCount,
    required this.workloadPercentage,
    required this.isOverloaded,
    required this.isAvailable,
    required this.assignedPatientNames,
    required this.assignedRoomNumbers,
  });

  @override
  String toString() {
    return '''
Nurse: $nurseName
Patients: $assignedPatientsCount
Rooms: $assignedRoomsCount
Workload: ${workloadPercentage.toStringAsFixed(1)}%
Status: ${isOverloaded ? '⚠️ OVERLOADED' : isAvailable ? '✅ AVAILABLE' : '⏳ BUSY'}
''';
  }
}

/// Use case for getting a nurse's workload information
/// Helps with nurse scheduling and assignment decisions
class GetNurseWorkload extends UseCase<String, NurseWorkload> {
  final NurseRepository nurseRepository;

  static const int maxPatientsPerNurse = 5;
  static const int maxRoomsPerNurse = 4;

  GetNurseWorkload({required this.nurseRepository});

  @override
  Future<bool> validate(String nurseId) async {
    final exists = await nurseRepository.nurseExists(nurseId);
    if (!exists) {
      throw EntityNotFoundException('Nurse', nurseId);
    }
    return true;
  }

  @override
  Future<NurseWorkload> execute(String nurseId) async {
    // Get nurse
    final nurse = await nurseRepository.getNurseById(nurseId);

    // Calculate workload metrics
    final patientsCount = nurse.assignedPatients.length;
    final roomsCount = nurse.assignedRooms.length;

    // Calculate workload percentage (weighted: 70% patients, 30% rooms)
    final patientLoad = (patientsCount / maxPatientsPerNurse) * 0.7;
    final roomLoad = (roomsCount / maxRoomsPerNurse) * 0.3;
    final workloadPercentage = (patientLoad + roomLoad) * 100;

    // Determine status
    final isOverloaded =
        patientsCount > maxPatientsPerNurse || roomsCount > maxRoomsPerNurse;
    final isAvailable =
        patientsCount < maxPatientsPerNurse && roomsCount < maxRoomsPerNurse;

    return NurseWorkload(
      nurseId: nurse.staffID,
      nurseName: nurse.name,
      assignedPatientsCount: patientsCount,
      assignedRoomsCount: roomsCount,
      workloadPercentage: workloadPercentage,
      isOverloaded: isOverloaded,
      isAvailable: isAvailable,
      assignedPatientNames: nurse.assignedPatients.map((p) => p.name).toList(),
      assignedRoomNumbers: nurse.assignedRooms.map((r) => r.number).toList(),
    );
  }
}
