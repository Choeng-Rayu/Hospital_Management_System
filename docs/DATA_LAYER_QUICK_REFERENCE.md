# Data Layer Implementation - Quick Reference Guide

## 🎯 What Was Implemented

This document provides a quick reference for the newly implemented data layer components.

---

## 📋 NEW Repository Implementations

### 1. RoomRepositoryImpl
**Location**: `lib/data/repositories/room_repository_impl.dart`

**Methods Implemented**:
```dart
Future<Room> getRoomById(String roomId)
Future<List<Room>> getAllRooms()
Future<void> saveRoom(Room room)
Future<void> updateRoom(Room room)
Future<void> deleteRoom(String roomId)
Future<List<Room>> getRoomsByType(RoomType type)
Future<List<Room>> getRoomsByStatus(RoomStatus status)
Future<List<Room>> getAvailableRooms()
Future<Room> getRoomByNumber(String number)
Future<List<Patient>> getRoomPatients(String roomId)
Future<List<Bed>> getRoomBeds(String roomId)
Future<bool> roomExists(String roomId)
```

**Usage Example**:
```dart
final roomRepo = RoomRepositoryImpl(
  roomDataSource: RoomLocalDataSource(),
  bedDataSource: BedLocalDataSource(),
  equipmentDataSource: EquipmentLocalDataSource(),
  patientDataSource: PatientLocalDataSource(),
);

// Get available rooms
final availableRooms = await roomRepo.getAvailableRooms();

// Get room by number
final room = await roomRepo.getRoomByNumber("ICU-101");
```

---

### 2. NurseRepositoryImpl
**Location**: `lib/data/repositories/nurse_repository_impl.dart`

**Methods Implemented**:
```dart
Future<Nurse> getNurseById(String staffId)
Future<List<Nurse>> getAllNurses()
Future<void> saveNurse(Nurse nurse)
Future<void> updateNurse(Nurse nurse)
Future<void> deleteNurse(String staffId)
Future<List<Nurse>> searchNursesByName(String name)
Future<List<Nurse>> getNursesByRoom(String roomId)
Future<List<Nurse>> getAvailableNurses()
Future<List<Patient>> getNursePatients(String nurseId)
Future<List<Room>> getNurseRooms(String nurseId)
Future<bool> nurseExists(String staffId)
```

**Usage Example**:
```dart
final nurseRepo = NurseRepositoryImpl(
  nurseDataSource: NurseLocalDataSource(),
  patientDataSource: PatientLocalDataSource(),
  roomDataSource: RoomLocalDataSource(),
  bedDataSource: BedLocalDataSource(),
  equipmentDataSource: EquipmentLocalDataSource(),
);

// Get available nurses
final availableNurses = await nurseRepo.getAvailableNurses();

// Get nurses for a specific room
final roomNurses = await nurseRepo.getNursesByRoom("ICU-101");
```

---

### 3. AdministrativeRepositoryImpl
**Location**: `lib/data/repositories/administrative_repository_impl.dart`

**Methods Implemented**:
```dart
Future<Administrative> getAdministrativeById(String staffId)
Future<List<Administrative>> getAllAdministrative()
Future<void> saveAdministrative(Administrative administrative)
Future<void> updateAdministrative(Administrative administrative)
Future<void> deleteAdministrative(String staffId)
Future<List<Administrative>> searchAdministrativeByName(String name)
Future<List<Administrative>> getAdministrativeByResponsibility(String responsibility)
Future<bool> administrativeExists(String staffId)
```

**Usage Example**:
```dart
final adminRepo = AdministrativeRepositoryImpl(
  administrativeDataSource: AdministrativeLocalDataSource(),
);

// Search by responsibility
final receptionists = await adminRepo.getAdministrativeByResponsibility("Reception");

// Get by ID
final admin = await adminRepo.getAdministrativeById("ADM001");
```

---

### 4. PrescriptionRepositoryImpl
**Location**: `lib/data/repositories/prescription_repository_impl.dart`

**Methods Implemented**:
```dart
Future<Prescription> getPrescriptionById(String prescriptionId)
Future<List<Prescription>> getAllPrescriptions()
Future<void> savePrescription(Prescription prescription)
Future<void> updatePrescription(Prescription prescription)
Future<void> deletePrescription(String prescriptionId)
Future<List<Prescription>> getPrescriptionsByPatient(String patientId)
Future<List<Prescription>> getPrescriptionsByDoctor(String doctorId)
Future<List<Prescription>> getRecentPrescriptions()
Future<List<Prescription>> getActivePrescriptionsByPatient(String patientId)
Future<bool> prescriptionExists(String prescriptionId)
```

**Usage Example**:
```dart
final prescriptionRepo = PrescriptionRepositoryImpl(
  prescriptionDataSource: PrescriptionLocalDataSource(),
  patientDataSource: PatientLocalDataSource(),
  doctorDataSource: DoctorLocalDataSource(),
  medicationDataSource: MedicationLocalDataSource(),
);

// Get patient's active prescriptions
final activePrescriptions = await prescriptionRepo
    .getActivePrescriptionsByPatient("P001");

// Get recent prescriptions (last 30 days)
final recentPrescriptions = await prescriptionRepo.getRecentPrescriptions();
```

---

## 📋 NEW Data Source Implementations

### 1. RoomLocalDataSource
**Location**: `lib/data/datasources/room_local_data_source.dart`

**Specialized Queries**:
- `findByRoomId()` - Find room by ID
- `findByRoomNumber()` - Find by room number
- `findRoomsByType()` - Filter by type (ICU, General Ward, etc.)
- `findRoomsByStatus()` - Filter by status
- `findAvailableRooms()` - Get available rooms
- `roomExists()` - Check existence

---

### 2. NurseLocalDataSource
**Location**: `lib/data/datasources/nurse_local_data_source.dart`

**Specialized Queries**:
- `findByStaffId()` - Find nurse by ID
- `findNursesByName()` - Search by name
- `findNursesByRoomId()` - Filter by room
- `findNursesByPatientId()` - Filter by patient
- `findAvailableNurses()` - Get nurses with capacity (< 5 patients)
- `findNursesAvailableAt()` - Schedule-based availability
- `nurseExists()` - Check existence

---

### 3. AdministrativeLocalDataSource
**Location**: `lib/data/datasources/administrative_local_data_source.dart`

**Specialized Queries**:
- `findByStaffId()` - Find by ID
- `findAdministrativeByName()` - Search by name
- `findAdministrativeByResponsibility()` - Filter by responsibility
- `findAdministrativeAvailableAt()` - Schedule-based availability
- `findAdministrativeHiredAfter()` - Hire date filtering
- `administrativeExists()` - Check existence

---

### 4. PrescriptionLocalDataSource
**Location**: `lib/data/datasources/prescription_local_data_source.dart`

**Specialized Queries**:
- `findByPrescriptionId()` - Find by ID
- `findPrescriptionsByPatientId()` - Patient prescriptions
- `findPrescriptionsByDoctorId()` - Doctor prescriptions
- `findRecentPrescriptions()` - Last 30 days
- `findActivePrescriptionsByPatientId()` - Last 90 days for patient
- `findPrescriptionsByDate()` - Specific date
- `findPrescriptionsBetweenDates()` - Date range
- `prescriptionExists()` - Check existence

---

### 5. BedLocalDataSource
**Location**: `lib/data/datasources/bed_local_data_source.dart`

**Specialized Queries**:
- `findByBedNumber()` - Find by bed number
- `findBedsByIds()` - Batch retrieval
- `findOccupiedBeds()` - Occupied beds only
- `findAvailableBeds()` - Available beds only
- `findBedByPatientId()` - Find patient's bed
- `findBedsByType()` - Filter by type
- `bedExists()` - Check existence

---

### 6. EquipmentLocalDataSource
**Location**: `lib/data/datasources/equipment_local_data_source.dart`

**Specialized Queries**:
- `findByEquipmentId()` - Find by ID
- `findEquipmentByIds()` - Batch retrieval
- `findEquipmentByType()` - Filter by type
- `findEquipmentByStatus()` - Filter by status
- `findEquipmentNeedingService()` - Maintenance alerts
- `findEquipmentByName()` - Search by name
- `equipmentExists()` - Check existence

---

### 7. MedicationLocalDataSource
**Location**: `lib/data/datasources/medication_local_data_source.dart`

**Specialized Queries**:
- `findByMedicationId()` - Find by ID
- `findMedicationsByIds()` - Batch retrieval
- `findMedicationsByName()` - Search by name
- `findMedicationsByManufacturer()` - Filter by manufacturer
- `findMedicationsWithSideEffect()` - Side effect search
- `medicationExists()` - Check existence

---

## 🔧 How to Use These Implementations

### Step 1: Initialize Data Sources
```dart
// Create data sources
final roomDataSource = RoomLocalDataSource();
final nurseDataSource = NurseLocalDataSource();
final adminDataSource = AdministrativeLocalDataSource();
final prescriptionDataSource = PrescriptionLocalDataSource();
final bedDataSource = BedLocalDataSource();
final equipmentDataSource = EquipmentLocalDataSource();
final medicationDataSource = MedicationLocalDataSource();
```

### Step 2: Initialize Repositories
```dart
// Create repositories with dependencies
final roomRepo = RoomRepositoryImpl(
  roomDataSource: roomDataSource,
  bedDataSource: bedDataSource,
  equipmentDataSource: equipmentDataSource,
  patientDataSource: PatientLocalDataSource(),
);

final nurseRepo = NurseRepositoryImpl(
  nurseDataSource: nurseDataSource,
  patientDataSource: PatientLocalDataSource(),
  roomDataSource: roomDataSource,
  bedDataSource: bedDataSource,
  equipmentDataSource: equipmentDataSource,
);

final adminRepo = AdministrativeRepositoryImpl(
  administrativeDataSource: adminDataSource,
);

final prescriptionRepo = PrescriptionRepositoryImpl(
  prescriptionDataSource: prescriptionDataSource,
  patientDataSource: PatientLocalDataSource(),
  doctorDataSource: DoctorLocalDataSource(),
  medicationDataSource: medicationDataSource,
);
```

### Step 3: Use in Your Application
```dart
// Example: Find available room and assign nurse
final availableRooms = await roomRepo.getAvailableRooms();
final availableNurses = await nurseRepo.getAvailableNurses();

if (availableRooms.isNotEmpty && availableNurses.isNotEmpty) {
  // Assign nurse to room
  final nurse = availableNurses.first;
  // Update nurse's assigned rooms...
}

// Example: Get patient prescriptions
final patientPrescriptions = await prescriptionRepo
    .getActivePrescriptionsByPatient(patientId);

for (final prescription in patientPrescriptions) {
  print('Medication: ${prescription.medications.map((m) => m.name).join(", ")}');
  print('Instructions: ${prescription.instructions}');
}
```

---

## 🎯 Common Use Cases

### Use Case 1: Room Assignment
```dart
// Find available ICU room
final icuRooms = await roomRepo.getRoomsByType(RoomType.ICU);
final availableICU = icuRooms.where((room) => 
  room.status == RoomStatus.AVAILABLE
).toList();

// Get available beds in the room
if (availableICU.isNotEmpty) {
  final room = availableICU.first;
  final beds = await roomRepo.getRoomBeds(room.roomId);
  final availableBed = beds.firstWhere((bed) => !bed.isOccupied);
  
  // Assign patient to bed...
}
```

### Use Case 2: Nurse Scheduling
```dart
// Find nurses available for night shift
final date = DateTime.now();
final nightShiftStart = DateTime(date.year, date.month, date.day, 20, 0);

final availableNurses = await nurseDataSource.findNursesAvailableAt(
  nightShiftStart,
  480, // 8 hours in minutes
);
```

### Use Case 3: Prescription Management
```dart
// Create new prescription
final prescription = Prescription(
  id: 'RX${DateTime.now().millisecondsSinceEpoch}',
  time: DateTime.now(),
  prescribedTo: patient,
  prescribedBy: doctor,
  medications: [medication1, medication2],
  instructions: 'Take twice daily with food',
);

await prescriptionRepo.savePrescription(prescription);

// Later: Get all prescriptions for patient
final allPrescriptions = await prescriptionRepo
    .getPrescriptionsByPatient(patient.patientID);
```

### Use Case 4: Equipment Maintenance
```dart
// Find equipment needing service
final needsService = await equipmentDataSource.findEquipmentNeedingService();

for (final equipment in needsService) {
  print('${equipment.name} needs service by ${equipment.nextServiceDate}');
}
```

---

## ⚠️ Important Notes

### Error Handling
All repository methods throw exceptions when entities are not found:
```dart
try {
  final room = await roomRepo.getRoomById('INVALID_ID');
} catch (e) {
  print('Error: $e'); // "Room with ID INVALID_ID not found"
}
```

### Existence Checks
Use existence checks before operations:
```dart
if (await roomRepo.roomExists(roomId)) {
  await roomRepo.updateRoom(room);
} else {
  await roomRepo.saveRoom(room);
}
```

### Related Entity Resolution
Repositories automatically fetch related entities:
```dart
// This automatically fetches beds and equipment for the room
final room = await roomRepo.getRoomById(roomId);
print('Beds: ${room.beds.length}');
print('Equipment: ${room.equipment.length}');
```

---

## 📚 Additional Resources

- **Full Alignment Report**: `DATA_LAYER_ALIGNMENT_REPORT.md`
- **Complete Structure**: `DATA_LAYER_COMPLETE_STRUCTURE.md`
- **Scheduling Conflict Resolution**: `SCHEDULING_CONFLICT_RESOLUTION_SUMMARY.md`
- **Data Layer Implementation Summary**: `docs/data_layer_implementation_summary.md`

---

## ✅ Verification Checklist

Before using these implementations:
- [x] All repository files exist
- [x] All data source files exist
- [x] All JSON data files exist
- [x] No compilation errors
- [x] All domain interfaces implemented
- [x] All relationships properly handled

---

**Status**: ✅ Ready for Production Use

All newly implemented repositories and data sources are fully functional and ready to be integrated into your Hospital Management System.
