# Domain & Data Layer - Quick Start Guide

**For**: Developers implementing presentation layer or extending the system  
**Status**: Complete & Verified ✅  
**Last Updated**: November 2, 2025

---

## 🚀 Quick Navigation

### For Presentations Layer Developers

**To get data:**
```dart
// Inject repositories into your controllers
final patientRepository = PatientRepositoryImpl(...);
final appointmentRepository = AppointmentRepositoryImpl(...);

// Call repository methods (they return domain entities)
final patient = await patientRepository.getPatientById("P001");
final appointments = await appointmentRepository.getAppointmentsByPatient("P001");

// Use domain entities with all relationships
print("Doctor: ${patient.assignedDoctors.first.name}");
print("Appointments: ${appointments.length}");
```

### For System Extension

**To add a new query:**
1. Add method to domain `XyzRepository` interface
2. Add method to `XyzLocalDataSource` class
3. Implement in `XyzRepositoryImpl` class
4. Create use case if needed
5. Inject into presentation controller

---

## 📦 Entity Reference

### Core Entities

| Entity | Key Properties | Key Methods |
|--------|---|---|
| **Patient** | patientID, name, bloodType, emergencyContact | addMedicalRecord(), assignDoctor(), discharge() |
| **Doctor** | staffID, name, specialization, department | addPatient(), getScheduleFor() |
| **Room** | roomId, number, roomType, status | addEquipment(), assignPatient() |
| **Appointment** | id, dateTime, duration, patient, doctor, status | updateStatus() |
| **Prescription** | id, medications, prescribedBy, prescribedTo | isRecent(), isActive() |
| **Equipment** | equipmentId, name, status, lastServiceDate, nextServiceDate | (Read-only through Room) |
| **Nurse** | staffID, name, department, maxPatients | assignPatient(), assignToRoom() |
| **Bed** | bedNumber, bedType, status, currentPatient | assignPatient(), removePatient() |

---

## 🔌 Repository Methods Quick Reference

### PatientRepository
```dart
getPatientById(String patientId)              // → Patient
getAllPatients()                               // → List<Patient>
savePatient(Patient)                          // → void
updatePatient(Patient)                        // → void
deletePatient(String patientId)               // → void
searchPatientsByName(String name)             // → List<Patient>
getPatientsByBloodType(String bloodType)      // → List<Patient>
getPatientsByDoctorId(String doctorId)        // → List<Patient>
patientExists(String patientId)               // → bool
getPatientsWithUpcomingMeetings()             // → List<Patient>
getPatientsWithOverdueMeetings()              // → List<Patient>
```

### AppointmentRepository
```dart
getAppointmentById(String appointmentId)      // → Appointment
getAllAppointments()                           // → List<Appointment>
saveAppointment(Appointment)                  // → void
updateAppointment(Appointment)                // → void
deleteAppointment(String appointmentId)       // → void
getAppointmentsByPatient(String patientId)    // → List<Appointment>
getAppointmentsByDoctor(String doctorId)      // → List<Appointment>
getAppointmentsByDate(DateTime date)          // → List<Appointment>
getAppointmentsByDoctorAndDate(String doctorId, DateTime date)  // → List<Appointment>
getAppointmentsByStatus(AppointmentStatus)    // → List<Appointment>
getUpcomingAppointments()                     // → List<Appointment>
appointmentExists(String appointmentId)       // → bool
hasDoctorConflict(String doctorId, DateTime startTime, int duration)  // → bool
```

### RoomRepository
```dart
getRoomById(String roomId)                    // → Room
getAllRooms()                                  // → List<Room>
saveRoom(Room)                                // → void
updateRoom(Room)                              // → void
deleteRoom(String roomId)                     // → void
getRoomsByType(RoomType type)                 // → List<Room>
getRoomsByStatus(RoomStatus status)           // → List<Room>
getAvailableRooms()                           // → List<Room>
getRoomByNumber(String number)                // → Room
getRoomPatients(String roomId)                // → List<Patient>
getRoomBeds(String roomId)                    // → List<Bed>
roomExists(String roomId)                     // → bool
```

### DoctorRepository
```dart
getDoctorById(String staffId)                 // → Doctor
getAllDoctors()                                // → List<Doctor>
saveDoctors(Doctor)                           // → void
updateDoctor(Doctor)                          // → void
deleteDoctor(String staffId)                  // → void
searchDoctorsByName(String name)              // → List<Doctor>
getDoctorsBySpecialization(String spec)      // → List<Doctor>
doctorExists(String staffId)                  // → bool
```

### PrescriptionRepository
```dart
getPrescriptionById(String prescriptionId)    // → Prescription
getAllPrescriptions()                          // → List<Prescription>
savePrescription(Prescription)                // → void
updatePrescription(Prescription)              // → void
deletePrescription(String prescriptionId)     // → void
getPrescriptionsByPatient(String patientId)   // → List<Prescription>
getPrescriptionsByDoctor(String doctorId)     // → List<Prescription>
getRecentPrescriptions()                      // → List<Prescription> (last 30 days)
getActivePrescriptionsByPatient(String patientId)  // → List<Prescription>
prescriptionExists(String prescriptionId)     // → bool
```

### NurseRepository
```dart
getNurseById(String staffId)                  // → Nurse
getAllNurses()                                 // → List<Nurse>
saveNurse(Nurse)                              // → void
updateNurse(Nurse)                            // → void
deleteNurse(String staffId)                   // → void
searchNursesByName(String name)               // → List<Nurse>
getNursesByRoom(String roomId)                // → List<Nurse>
getAvailableNurses()                          // → List<Nurse>
getNursePatients(String nurseId)              // → List<Patient>
getNurseRooms(String nurseId)                 // → List<Room>
nurseExists(String staffId)                   // → bool
```

### AdministrativeRepository
```dart
getAdministrativeById(String staffId)         // → Administrative
getAllAdministrative()                         // → List<Administrative>
saveAdministrative(Administrative)            // → void
updateAdministrative(Administrative)          // → void
deleteAdministrative(String staffId)          // → void
searchAdministrativeByName(String name)       // → List<Administrative>
getAdministrativeByResponsibility(String resp)  // → List<Administrative>
administrativeExists(String staffId)          // → bool
```

---

## 🎯 Common Use Cases

### Get Patient with All Information
```dart
final patient = await patientRepository.getPatientById("P001");

// Access all related entities
print("Name: ${patient.name}");
print("Doctors: ${patient.assignedDoctors.map((d) => d.name).join(', ')}");
print("Current Room: ${patient.currentRoom?.number}");
print("Prescriptions: ${patient.prescriptions.length}");
print("Meeting with: ${patient.nextMeetingDoctor?.name}");
```

### Get Doctor's Full Schedule
```dart
final appointments = await appointmentRepository.getAppointmentsByDoctor("D001");

appointments.forEach((apt) {
  print("${apt.dateTime}: ${apt.patient.name} - ${apt.reason}");
});
```

### Check for Appointment Conflicts
```dart
final hasConflict = await appointmentRepository.hasDoctorConflict(
  "D001",
  DateTime(2025, 11, 5, 10, 0),  // Start time
  30,  // Duration in minutes
);

if (!hasConflict) {
  // Safe to schedule appointment
}
```

### Find Available Rooms
```dart
final availableRooms = await roomRepository.getAvailableRooms();

availableRooms.forEach((room) {
  print("Room ${room.number}: ${room.beds.length} beds available");
});
```

### Get Active Prescriptions for Patient
```dart
final activePrescriptions = await prescriptionRepository
  .getActivePrescriptionsByPatient("P001");

activePrescriptions.forEach((rx) {
  print("${rx.medications.join(', ')} - Active until ${rx.expiryDate}");
});
```

### Search by Name
```dart
// Search patients
final patients = await patientRepository.searchPatientsByName("John");

// Search doctors
final doctors = await doctorRepository.searchDoctorsByName("Smith");

// Search nurses
final nurses = await nurseRepository.searchNursesByName("Mary");
```

---

## 🔄 Data Flow Patterns

### Save New Entity
```dart
// 1. Create entity in domain
final newPatient = Patient(
  patientID: "P999",
  name: "Jane Doe",
  dateOfBirth: "1990-01-01",
  address: "123 Main St",
  tel: "555-1234",
  bloodType: "O+",
  medicalRecords: [],
  allergies: [],
  emergencyContact: "Emergency Person",
);

// 2. Save through repository
await patientRepository.savePatient(newPatient);

// 3. Repository converts to model and saves to JSON
// DATA LAYER handles: entity → model → JSON file
```

### Update Entity
```dart
// 1. Get entity
final patient = await patientRepository.getPatientById("P001");

// 2. Modify it
patient.addAllergy("Penicillin");

// 3. Save it back
await patientRepository.updatePatient(patient);

// Repository updates in JSON file
```

### Delete Entity
```dart
// 1. Delete
await patientRepository.deletePatient("P001");

// 2. Entity no longer in JSON file
```

---

## ⚠️ Important Notes

### Relationship Resolution
- When you get an entity, ALL relationships are already resolved
- E.g., `Patient.assignedDoctors` contains full `Doctor` objects, not just IDs
- Repository handles all the relationship fetching automatically

### Foreign Keys in Models
- Data models use IDs to store relationships (e.g., `patientModel.assignedDoctorIds`)
- Repositories resolve these IDs to entities automatically
- You never work with IDs in the domain layer

### Error Handling
```dart
try {
  final patient = await patientRepository.getPatientById("INVALID");
} catch (e) {
  print("Error: $e");  // "Patient with ID INVALID not found"
}
```

### Existence Checks
```dart
// Always check before creating
if (!await patientRepository.patientExists("P001")) {
  await patientRepository.savePatient(newPatient);
}
```

---

## 📊 Entity Relationships Diagram

```
Patient
├─ assignedDoctors: List<Doctor>
├─ assignedNurses: List<Nurse>
├─ prescriptions: List<Prescription>
├─ currentRoom: Room?
└─ currentBed: Bed?

Doctor
├─ assignedPatients: List<Patient>
└─ (Schedule managed internally)

Room
├─ beds: List<Bed>
└─ equipment: List<Equipment>

Prescription
├─ medications: List<Medication>
├─ prescribedBy: Doctor
└─ prescribedTo: Patient

Appointment
├─ patient: Patient
├─ doctor: Doctor
└─ room: Room?
```

---

## 🔌 Injection Pattern

For controllers, inject repositories:

```dart
class AppointmentController {
  final AppointmentRepository appointmentRepository;
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;
  
  AppointmentController({
    required this.appointmentRepository,
    required this.patientRepository,
    required this.doctorRepository,
  });
  
  Future<void> scheduleAppointment(String patientId, String doctorId) async {
    // Use repositories here
    final patient = await patientRepository.getPatientById(patientId);
    final doctor = await doctorRepository.getDoctorById(doctorId);
    // ... business logic
  }
}
```

---

## ✅ Verification Checklist

Before using repositories in your code:

- [ ] All repository interfaces are in `lib/domain/repositories/`
- [ ] All repository implementations are in `lib/data/repositories/`
- [ ] All data sources are in `lib/data/datasources/`
- [ ] All models are in `lib/data/models/`
- [ ] JSON files exist in `data/` directory
- [ ] All imports use relative paths correctly
- [ ] No direct data layer imports in domain code
- [ ] Controllers import only domain entities and repositories

---

## 🎓 Learning Path

1. **Understand Entities** - Read `lib/domain/entities/*.dart`
2. **Understand Repository Interfaces** - Read `lib/domain/repositories/*.dart`
3. **Study a Repository Implementation** - Read `PatientRepositoryImpl`
4. **Study a Model** - Read `PatientModel`
5. **Study a Data Source** - Read `PatientLocalDataSource`
6. **Study a Use Case** - Read any use case in `lib/domain/usecases/`
7. **Create Controller** - Implement your presentation layer
8. **Test Flow** - Verify data flows through all layers

---

## 📞 Common Questions

**Q: How do I get a patient's doctor?**
```dart
final patient = await patientRepository.getPatientById("P001");
final doctor = patient.assignedDoctors.first; // Already loaded!
```

**Q: How do I save changes to a patient?**
```dart
patient.addAllergy("Penicillin");
await patientRepository.updatePatient(patient);
```

**Q: How do I check if a doctor has time?**
```dart
final hasConflict = await appointmentRepository.hasDoctorConflict(
  "D001", 
  DateTime(2025, 11, 5, 10, 0), 
  30
);
if (!hasConflict) {
  // Schedule appointment
}
```

**Q: How do I find available rooms?**
```dart
final rooms = await roomRepository.getAvailableRooms();
```

**Q: Can I modify returned entities?**
```dart
// YES! Returned entities are domain objects
final patient = await patientRepository.getPatientById("P001");
patient.addAllergy("Latex");  // This works!
await patientRepository.updatePatient(patient);  // Save changes
```

---

**Next**: Read `LAYER_INTEGRATION_ANALYSIS.md` for detailed architecture explanation.

