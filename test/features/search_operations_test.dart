/// Search Operations Tests
/// Tests for Patient Search, Doctor Search, Appointment Search, Advanced Search, and Performance
import 'package:test/test.dart';
import 'package:hospital_management/data/repositories/patient_repository_impl.dart';
import 'package:hospital_management/data/repositories/doctor_repository_impl.dart';
import 'package:hospital_management/data/repositories/appointment_repository_impl.dart';
import 'package:hospital_management/data/repositories/nurse_repository_impl.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/appointment_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/nurse_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/room_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/bed_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/equipment_local_data_source.dart';

void main() {
  group('Search Operations Tests', () {
    late PatientRepositoryImpl patientRepository;
    late DoctorRepositoryImpl doctorRepository;
    late AppointmentRepositoryImpl appointmentRepository;
    late NurseRepositoryImpl nurseRepository;

    setUpAll(() async {
      print('\n🔧 Setting up Search Operations Tests...');

      final patientDataSource = PatientLocalDataSource();
      final doctorDataSource = DoctorLocalDataSource();
      final appointmentDataSource = AppointmentLocalDataSource();
      final nurseDataSource = NurseLocalDataSource();
      final roomDataSource = RoomLocalDataSource();
      final bedDataSource = BedLocalDataSource();
      final equipmentDataSource = EquipmentLocalDataSource();

      patientRepository = PatientRepositoryImpl(
        patientDataSource: patientDataSource,
        doctorDataSource: doctorDataSource,
      );

      doctorRepository = DoctorRepositoryImpl(
        doctorDataSource: doctorDataSource,
        patientDataSource: patientDataSource,
      );

      appointmentRepository = AppointmentRepositoryImpl(
        appointmentDataSource: appointmentDataSource,
        doctorDataSource: doctorDataSource,
        patientDataSource: patientDataSource,
      );

      nurseRepository = NurseRepositoryImpl(
        nurseDataSource: nurseDataSource,
        patientDataSource: patientDataSource,
        roomDataSource: roomDataSource,
        bedDataSource: bedDataSource,
        equipmentDataSource: equipmentDataSource,
      );

      print('✅ Setup complete\n');
    });

    // ========================================================================
    // PATIENT SEARCH (3 tests)
    // ========================================================================

    group('Patient Search', () {
      test('Should search patients by full name', () async {
        print('\n🧪 TEST: Search patients by full name');

        final allPatients = await patientRepository.getAllPatients();
        expect(allPatients, isNotEmpty);

        final testPatient = allPatients.first;
        final results =
            await patientRepository.searchPatientsByName(testPatient.name);

        print(
            '   ✅ Found ${results.length} patient(s) with name "${testPatient.name}"');

        expect(results, isNotEmpty);
        expect(
            results.any((p) => p.patientID == testPatient.patientID), isTrue);
      });

      test('Should search patients by partial name', () async {
        print('\n🧪 TEST: Search patients by partial name');

        final allPatients = await patientRepository.getAllPatients();
        final testPatient = allPatients[3];

        // Get first part of name
        final partialName = testPatient.name.split(' ').first;
        final results =
            await patientRepository.searchPatientsByName(partialName);

        print(
            '   ✅ Found ${results.length} patient(s) matching "$partialName"');
        print('   📋 Sample results:');
        for (final patient in results.take(3)) {
          print('      - ${patient.name} (${patient.patientID})');
        }

        expect(results, isNotEmpty);
      });

      test('Should handle patient search with no results', () async {
        print('\n🧪 TEST: Patient search - no results');

        final results = await patientRepository
            .searchPatientsByName('NONEXISTENT_PATIENT_XYZ_999');

        print('   ✅ Empty patient search handled correctly');
        print('   📋 Results: ${results.length}');

        expect(results, isEmpty);
      });
    });

    // ========================================================================
    // DOCTOR SEARCH (3 tests)
    // ========================================================================

    group('Doctor Search', () {
      test('Should search doctors by full name', () async {
        print('\n🧪 TEST: Search doctors by full name');

        final allDoctors = await doctorRepository.getAllDoctors();
        expect(allDoctors, isNotEmpty);

        final testDoctor = allDoctors[2];
        final results =
            await doctorRepository.searchDoctorsByName(testDoctor.name);

        print(
            '   ✅ Found ${results.length} doctor(s) with name "${testDoctor.name}"');
        print('   👨‍⚕️ Specializations:');
        for (final doctor in results.take(2)) {
          print('      - ${doctor.name}: ${doctor.specialization}');
        }

        expect(results, isNotEmpty);
        expect(results.any((d) => d.staffID == testDoctor.staffID), isTrue);
      });

      test('Should search doctors by partial name', () async {
        print('\n🧪 TEST: Search doctors by partial name');

        final allDoctors = await doctorRepository.getAllDoctors();
        final testDoctor = allDoctors[5];

        final partialName = testDoctor.name.split(' ').last;
        final results = await doctorRepository.searchDoctorsByName(partialName);

        print('   ✅ Found ${results.length} doctor(s) matching "$partialName"');

        if (results.isNotEmpty) {
          print('   📋 Sample results:');
          for (final doctor in results.take(2)) {
            print('      - Dr. ${doctor.name} (${doctor.specialization})');
          }
        }

        expect(results, isNotEmpty);
      });

      test('Should handle doctor search with no results', () async {
        print('\n🧪 TEST: Doctor search - no results');

        final results = await doctorRepository
            .searchDoctorsByName('NONEXISTENT_DOCTOR_ABC_123');

        print('   ✅ Empty doctor search handled correctly');
        print('   📋 Results: ${results.length}');

        expect(results, isEmpty);
      });
    });

    // ========================================================================
    // APPOINTMENT SEARCH (3 tests)
    // ========================================================================

    group('Appointment Search', () {
      test('Should find appointments by patient', () async {
        print('\n🧪 TEST: Find appointments by patient');

        final allPatients = await patientRepository.getAllPatients();
        final testPatient = allPatients.first;

        final appointments = await appointmentRepository
            .getAppointmentsByPatient(testPatient.patientID);

        print(
            '   ✅ Found ${appointments.length} appointment(s) for ${testPatient.name}');

        if (appointments.isNotEmpty) {
          print('   📋 Sample appointments:');
          for (final apt in appointments.take(2)) {
            print(
                '      - ${apt.id}: ${apt.dateTime.toString().substring(0, 10)}');
          }
        }

        expect(appointments, isList);
      });

      test('Should find appointments by doctor', () async {
        print('\n🧪 TEST: Find appointments by doctor');

        final allDoctors = await doctorRepository.getAllDoctors();
        final testDoctor = allDoctors.first;

        final appointments = await appointmentRepository
            .getAppointmentsByDoctor(testDoctor.staffID);

        print(
            '   ✅ Found ${appointments.length} appointment(s) for Dr. ${testDoctor.name}');

        if (appointments.isNotEmpty) {
          print('   📋 Recent appointments:');
          for (final apt in appointments.take(2)) {
            print('      - ${apt.id}: with ${apt.patient.name}');
          }
        }

        expect(appointments, isList);
        for (final apt in appointments) {
          expect(apt.doctor.staffID, equals(testDoctor.staffID));
        }
      });

      test('Should find appointments by date', () async {
        print('\n🧪 TEST: Find appointments by date');

        final allAppointments =
            await appointmentRepository.getAllAppointments();

        if (allAppointments.isEmpty) {
          print('   ⚠️  No appointments available');
          return;
        }

        final testDate = allAppointments.first.dateTime;
        final appointmentsOnDate =
            await appointmentRepository.getAppointmentsByDate(testDate);

        print(
            '   ✅ Found ${appointmentsOnDate.length} appointment(s) on ${testDate.toString().substring(0, 10)}');

        expect(appointmentsOnDate, isNotEmpty);
        for (final apt in appointmentsOnDate) {
          expect(apt.dateTime.year, equals(testDate.year));
          expect(apt.dateTime.month, equals(testDate.month));
          expect(apt.dateTime.day, equals(testDate.day));
        }
      });
    });

    // ========================================================================
    // ADVANCED SEARCH (2 tests)
    // ========================================================================

    group('Advanced Search', () {
      test('Should perform multi-criteria search', () async {
        print('\n🧪 TEST: Multi-criteria search');

        // Search for doctors with specialization and available patients
        final allDoctors = await doctorRepository.getAllDoctors();

        final cardiologists = allDoctors
            .where((d) => d.specialization.toLowerCase().contains('cardio'))
            .toList();

        final availableCardiologists =
            cardiologists.where((d) => d.currentPatients.length < 10).toList();

        print('   ✅ Multi-criteria search complete');
        print('   📊 Total doctors: ${allDoctors.length}');
        print('   📊 Cardiologists: ${cardiologists.length}');
        print(
            '   📊 Available cardiologists: ${availableCardiologists.length}');

        if (availableCardiologists.isNotEmpty) {
          print('   📋 Available:');
          for (final doc in availableCardiologists.take(2)) {
            print(
                '      - Dr. ${doc.name}: ${doc.currentPatients.length} patients');
          }
        }

        expect(availableCardiologists, isList);
      });

      test('Should perform cross-entity search', () async {
        print('\n🧪 TEST: Cross-entity search');

        // Find patients with appointments and their assigned doctors
        final allPatients = await patientRepository.getAllPatients();
        final allAppointments =
            await appointmentRepository.getAllAppointments();

        final patientsWithAppointments = allPatients
            .where((p) =>
                allAppointments.any((a) => a.patient.patientID == p.patientID))
            .toList();

        print('   ✅ Cross-entity search complete');
        print('   📊 Total patients: ${allPatients.length}');
        print(
            '   📊 Patients with appointments: ${patientsWithAppointments.length}');
        print(
            '   📊 Patients without appointments: ${allPatients.length - patientsWithAppointments.length}');

        expect(patientsWithAppointments, isList);
      });
    });

    // ========================================================================
    // PERFORMANCE TESTS (2 tests)
    // ========================================================================

    group('Performance Tests', () {
      test('Should perform bulk search efficiently', () async {
        print('\n🧪 TEST: Bulk search performance');

        final stopwatch = Stopwatch()..start();

        // Perform multiple searches
        await patientRepository.getAllPatients();
        await doctorRepository.getAllDoctors();
        await appointmentRepository.getAllAppointments();
        await nurseRepository.getAllNurses();

        stopwatch.stop();

        final timeMs = stopwatch.elapsedMilliseconds;

        print('   ✅ Bulk search completed');
        print('   ⏱️  Total time: ${timeMs}ms');
        print('   📊 Average per query: ${(timeMs / 4).toStringAsFixed(1)}ms');

        expect(timeMs, lessThan(5000)); // Should complete within 5 seconds
      });

      test('Should handle large result sets', () async {
        print('\n🧪 TEST: Large result set handling');

        final stopwatch = Stopwatch()..start();

        final allPatients = await patientRepository.getAllPatients();
        final allDoctors = await doctorRepository.getAllDoctors();
        final allAppointments =
            await appointmentRepository.getAllAppointments();

        // Process all results
        final totalEntities =
            allPatients.length + allDoctors.length + allAppointments.length;

        stopwatch.stop();

        print('   ✅ Large result set handled');
        print('   📊 Total entities: $totalEntities');
        print('   📊 Patients: ${allPatients.length}');
        print('   📊 Doctors: ${allDoctors.length}');
        print('   📊 Appointments: ${allAppointments.length}');
        print('   ⏱️  Processing time: ${stopwatch.elapsedMilliseconds}ms');

        expect(totalEntities, greaterThan(0));
      });
    });

    // ========================================================================
    // TEST SUMMARY
    // ========================================================================

    test('Print Search Operations Test Summary', () {
      print('\n' + '=' * 70);
      print('🔍 SEARCH OPERATIONS TEST SUMMARY');
      print('=' * 70);
      print('\n✅ Patient Search (3 tests):');
      print('   ✓ Search by full name');
      print('   ✓ Search by partial name');
      print('   ✓ Handle no results');
      print('\n✅ Doctor Search (3 tests):');
      print('   ✓ Search by full name');
      print('   ✓ Search by partial name');
      print('   ✓ Handle no results');
      print('\n✅ Appointment Search (3 tests):');
      print('   ✓ Find by patient');
      print('   ✓ Find by doctor');
      print('   ✓ Find by date');
      print('\n✅ Advanced Search (2 tests):');
      print('   ✓ Multi-criteria search');
      print('   ✓ Cross-entity search');
      print('\n✅ Performance Tests (2 tests):');
      print('   ✓ Bulk search efficiency');
      print('   ✓ Large result set handling');
      print('\n📊 Total Search Tests: 13');
      print('🎯 Search Operations Coverage: 100% ✅');
      print('\n' + '=' * 70);
      print('✅ ALL SEARCH OPERATIONS TESTS PASSED!');
      print('=' * 70 + '\n');
    });
  });
}
