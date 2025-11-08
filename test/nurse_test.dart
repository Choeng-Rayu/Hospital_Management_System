import 'package:test/test.dart';
import 'package:hospital_management/data/repositories/nurse_repository_impl.dart';
import 'package:hospital_management/data/datasources/local/nurse_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/room_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/bed_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/equipment_local_data_source.dart';
import 'package:hospital_management/domain/entities/nurse.dart';

void main() {
  late NurseRepositoryImpl nurseRepo;
  final testIds = <String>[];

  setUp(() {
    nurseRepo = NurseRepositoryImpl(
      nurseDataSource: NurseLocalDataSource(),
      patientDataSource: PatientLocalDataSource(),
      roomDataSource: RoomLocalDataSource(),
      bedDataSource: BedLocalDataSource(),
      equipmentDataSource: EquipmentLocalDataSource(),
    );
  });

  tearDown(() async {
    for (var id in testIds) {
      try {
        await nurseRepo.deleteNurse(id);
      } catch (e) {}
    }
    testIds.clear();
  });

  group('Nurse Operations', () {
    test('can get all nurses', () async {
      final nurses = await nurseRepo.getAllNurses();
      expect(nurses.isNotEmpty, true);
    });

    test('can get nurse by ID', () async {
      final nurse = await nurseRepo.getNurseById('N001');
      expect(nurse.staffID, 'N001');
    });

    test('can create nurse', () async {
      final nurse = Nurse(
        name: 'Nurse Test',
        dateOfBirth: '1990-06-15',
        address: '789 Care St',
        tel: '+855-99-887-766',
        staffID: 'AUTO',
        hireDate: DateTime.now(),
        salary: 50000,
        schedule: {},
        assignedPatients: [],
        assignedRooms: [],
      );

      await nurseRepo.saveNurse(nurse);
      final all = await nurseRepo.getAllNurses();
      final created = all.firstWhere((n) => n.name == 'Nurse Test');
      testIds.add(created.staffID);

      expect(created.name, 'Nurse Test');
    });

    test('can delete nurse', () async {
      final nurse = Nurse(
        name: 'Nurse Delete',
        dateOfBirth: '1988-12-01',
        address: '321 Test Rd',
        tel: '+855-55-443-322',
        staffID: 'AUTO',
        hireDate: DateTime.now(),
        salary: 48000,
        schedule: {},
        assignedPatients: [],
        assignedRooms: [],
      );

      await nurseRepo.saveNurse(nurse);
      final all = await nurseRepo.getAllNurses();
      final created = all.firstWhere((n) => n.name == 'Nurse Delete');

      await nurseRepo.deleteNurse(created.staffID);

      expect(
        () => nurseRepo.getNurseById(created.staffID),
        throwsException,
      );
    });
  });
}
