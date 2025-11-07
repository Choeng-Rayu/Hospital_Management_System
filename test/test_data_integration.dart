import '../lib/data/datasources/doctor_local_data_source.dart';
import '../lib/data/datasources/patient_local_data_source.dart';
import '../lib/data/repositories/patient_repository_impl.dart';

void main() async {
  print('Testing real data integration...');
  
  try {
    // Test doctor data source with new schedule format
    final doctorDataSource = DoctorLocalDataSource();
    final doctors = await doctorDataSource.readAll();
    
    print('\n=== Doctors Loaded ===');
    print('Total doctors: ${doctors.length}');
    
    for (final doctor in doctors) {
      print('- ${doctor.name} (${doctor.staffID}): ${doctor.schedule.keys.length} working days');
      
      // Convert to entity to test the integration
      final entity = doctor.toEntity();
      final mondaySchedule = entity.getScheduleFor('Monday');
      if (mondaySchedule.isNotEmpty) {
        print('  Monday: ${mondaySchedule.first} to ${mondaySchedule.last}');
      }
    }
    
    // Test finding available doctors
    final availableDoctors = await doctorDataSource.findAvailableDoctors(DateTime(2025, 11, 4));
    print('\nDoctors available on 2025-11-04: ${availableDoctors.length}');
    
    // Test patient repository integration
    final patientDataSource = PatientLocalDataSource();
    final patientRepo = PatientRepositoryImpl(
      patientDataSource: patientDataSource,
      doctorDataSource: doctorDataSource,
    );
    
    final patients = await patientRepo.getAllPatients();
    print('\n=== Patients Loaded ===');
    print('Total patients: ${patients.length}');
    
    for (final patient in patients) {
      print('- ${patient.name} (${patient.patientID}): ${patient.assignedDoctors.length} assigned doctors');
    }
    
    print('\n✅ All integrations working correctly!');
    
  } catch (e, stackTrace) {
    print('❌ Integration test failed: $e');
    print('Stack trace: $stackTrace');
  }
}