# Data Layer Quick Reference

## Overview Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Entities    │  │ Repositories │  │  Use Cases   │          │
│  │ (Business    │  │ (Interfaces) │  │ (Business    │          │
│  │  Objects)    │  │              │  │  Logic)      │          │
│  └──────┬───────┘  └──────▲───────┘  └──────────────┘          │
│         │                  │                                      │
└─────────┼──────────────────┼──────────────────────────────────────┘
          │                  │
          │                  │ implements
          │                  │
┌─────────┼──────────────────┼──────────────────────────────────────┐
│         │                  │            DATA LAYER                 │
│         │                  │                                       │
│    converts to        ┌────┴─────────────┐                       │
│         │             │  Repository      │                       │
│         │             │  Implementations │                       │
│         │             └────┬─────────────┘                       │
│         │                  │ uses                                 │
│    ┌────▼─────┐       ┌───▼──────┐       ┌─────────────┐       │
│    │  Models  │◄──────│   Data   │◄──────│ JsonData    │       │
│    │  (DTOs)  │ reads │  Sources │ uses  │ Source<T>   │       │
│    └────┬─────┘       └───┬──────┘       └─────────────┘       │
│         │                  │                                       │
└─────────┼──────────────────┼───────────────────────────────────────┘
          │                  │
          │ serializes       │ reads/writes
          │                  │
┌─────────▼──────────────────▼───────────────────────────────────────┐
│                       JSON FILES (data/)                            │
│  patients.json, doctors.json, nurses.json, rooms.json, etc.        │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

### JsonDataSource<T> (Base Class)
**Purpose**: Generic CRUD operations for any model type

**Key Methods**:
- `readAll()` - Load all records
- `writeAll()` - Save all records
- `findById()` - Get single record
- `findWhere()` - Query with predicate
- `add/update/delete()` - Modify records

**Example**:
```dart
class PatientLocalDataSource extends JsonDataSource<PatientModel> {
  PatientLocalDataSource() : super(
    fileName: 'patients.json',
    fromJson: PatientModel.fromJson,
  );
}
```

### Models (DTOs)
**Purpose**: Bridge between domain entities and JSON storage

**Key Methods**:
- `fromEntity()` - Entity → Model (for saving)
- `toEntity()` - Model → Entity (for loading)
- `fromJson()` - JSON → Model
- `toJson()` - Model → JSON

**Example**:
```dart
// Saving
final model = PatientModel.fromEntity(patient);
await dataSource.add(model, (m) => m.patientID, (m) => m.toJson());

// Loading
final model = await dataSource.findById(id, ...);
final patient = model.toEntity(assignedDoctor: doctor, ...);
```

### Data Sources
**Purpose**: Specialized queries for each entity type

**Example**:
```dart
class PatientLocalDataSource extends JsonDataSource<PatientModel> {
  Future<List<PatientModel>> findPatientsWithUpcomingMeetings() async {
    return findWhere((patient) {
      if (!patient.hasNextMeeting) return false;
      final meetingDate = DateTime.parse(patient.nextMeetingDate!);
      return meetingDate.isAfter(DateTime.now());
    });
  }
}
```

### Repository Implementations
**Purpose**: Coordinate data sources and resolve relationships

**Pattern**:
```dart
class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource _dataSource;
  final DoctorLocalDataSource _doctorDataSource;
  // ... other data sources
  
  @override
  Future<Patient?> findById(String id) async {
    final model = await _dataSource.findByPatientID(id);
    if (model == null) return null;
    
    // Resolve relationships
    final doctor = await _doctorDataSource.findByStaffID(model.assignedDoctorId);
    final nurse = await _nurseDataSource.findByStaffID(model.assignedNurseId);
    
    return model.toEntity(
      assignedDoctor: doctor?.toEntity(),
      assignedNurse: nurse?.toEntity(),
    );
  }
}
```

## Data Flow

### Saving an Entity
```
User Code
   │
   ▼
Use Case (schedulePatientMeeting)
   │
   ▼
Domain Entity (Patient)
   │ patient.scheduleNextMeeting(...)
   ▼
Repository Interface (PatientRepository)
   │
   ▼
Repository Impl (PatientRepositoryImpl)
   │ PatientModel.fromEntity(patient)
   ▼
Data Model (PatientModel)
   │ model.toJson()
   ▼
Data Source (PatientLocalDataSource)
   │ writeAll()
   ▼
JsonDataSource<PatientModel>
   │ json.encode()
   ▼
File System (data/patients.json)
```

### Loading an Entity
```
User Code
   │
   ▼
Use Case (getPatientsWithUpcomingMeetings)
   │
   ▼
Repository Interface (PatientRepository)
   │
   ▼
Repository Impl (PatientRepositoryImpl)
   │ findPatientsWithUpcomingMeetings()
   ▼
Data Source (PatientLocalDataSource)
   │ findWhere(predicate)
   ▼
JsonDataSource<PatientModel>
   │ readAll() + fromJson()
   ▼
Data Models (List<PatientModel>)
   │ Resolve relationships
   │ (load doctors, nurses, etc.)
   ▼
Domain Entities (List<Patient>)
   │
   ▼
User Code
```

## Meeting Schedule Data Flow

### Scheduling a Meeting

```
1. Use Case: SchedulePatientMeeting
   ↓
2. Patient Entity: patient.scheduleNextMeeting(date, doctor)
   ↓
3. PatientRepositoryImpl: save(patient)
   ↓
4. PatientModel.fromEntity(patient) → extracts:
   - hasNextMeeting: true
   - nextMeetingDate: "2024-02-15T10:00:00.000Z"
   - nextMeetingDoctorId: "D123"
   ↓
5. PatientLocalDataSource: update(id, model, ...)
   ↓
6. JsonDataSource<PatientModel>: writeAll()
   ↓
7. JSON File:
   {
     "patientID": "P001",
     "hasNextMeeting": true,
     "nextMeetingDate": "2024-02-15T10:00:00.000Z",
     "nextMeetingDoctorId": "D123",
     ...
   }
```

### Querying Upcoming Meetings

```
1. Use Case: GetMeetingReminders
   ↓
2. PatientRepositoryImpl: findPatientsWithUpcomingMeetings()
   ↓
3. PatientLocalDataSource: findPatientsWithUpcomingMeetings()
   ↓
4. JsonDataSource: findWhere(predicate)
   - Reads all patients from JSON
   - Filters where hasNextMeeting == true
   - Parses nextMeetingDate
   - Checks if date > now
   ↓
5. Returns List<PatientModel>
   ↓
6. For each model:
   - Resolve doctor: doctorDataSource.findById(nextMeetingDoctorId)
   - Convert: model.toEntity(doctor: resolvedDoctor)
   ↓
7. Returns List<Patient> with full meeting information
```

## JSON File Formats

### patients.json
```json
[
  {
    "patientID": "P001",
    "name": "John Doe",
    "dateOfBirth": "1990-01-15",
    "gender": "Male",
    "address": "123 Main St",
    "tel": "555-0100",
    "email": "john@example.com",
    "emergencyContact": "Jane Doe: 555-0101",
    "bloodGroup": "O+",
    "assignedDoctorId": "D101",
    "assignedNurseId": "N201",
    "roomId": "R301",
    "bedId": "B301A",
    "admissionDate": "2024-01-10T14:00:00.000Z",
    "dischargeDate": null,
    "hasNextMeeting": true,
    "nextMeetingDate": "2024-02-15T10:00:00.000Z",
    "nextMeetingDoctorId": "D101"
  }
]
```

### doctors.json
```json
[
  {
    "staffID": "D101",
    "name": "Dr. Sarah Smith",
    "dateOfBirth": "1975-08-20",
    "address": "456 Oak Ave",
    "tel": "555-0200",
    "hireDate": "2010-03-15T00:00:00.000Z",
    "salary": 120000.0,
    "schedule": {
      "Monday": [
        "2024-01-15T09:00:00.000Z",
        "2024-01-15T14:00:00.000Z"
      ],
      "Tuesday": [
        "2024-01-16T10:00:00.000Z"
      ]
    },
    "specialization": "Cardiology",
    "certifications": ["Board Certified", "ACLS"],
    "currentPatientIds": ["P001", "P002"]
  }
]
```

## Relationship Handling

### One-to-One / Many-to-One
```dart
// Model stores ID
final String? assignedDoctorId;

// Repository resolves
final doctor = await _doctorDataSource.findByStaffID(model.assignedDoctorId);
patient = model.toEntity(assignedDoctor: doctor?.toEntity());
```

### One-to-Many / Many-to-Many
```dart
// Model stores ID list
final List<String> currentPatientIds;

// Repository resolves
final patients = <Patient>[];
for (final id in model.currentPatientIds) {
  final patient = await _patientDataSource.findByPatientID(id);
  if (patient != null) patients.add(patient.toEntity());
}
doctor = model.toEntity(currentPatients: patients);
```

## Quick Start Checklist

For each new entity:

- [ ] Create Model (DTO) in `lib/data/models/`
  - [ ] fromEntity() method
  - [ ] toEntity() method  
  - [ ] fromJson() method
  - [ ] toJson() method
  - [ ] copyWith() method

- [ ] Create Data Source in `lib/data/datasources/`
  - [ ] Extend JsonDataSource<Model>
  - [ ] Add specialized query methods
  - [ ] Add findById() wrapper

- [ ] Create Repository Impl in `lib/data/repositories/`
  - [ ] Implement domain repository interface
  - [ ] Inject required data sources
  - [ ] Resolve relationships in queries
  - [ ] Convert entities ↔ models

## Common Patterns

### Date/Time Serialization
```dart
// Saving
hireDate: doctor.hireDate.toIso8601String()

// Loading
hireDate: DateTime.parse(hireDate)
```

### Optional Relationships
```dart
// Model
final String? doctorId; // Nullable

// Repository
final doctor = model.doctorId != null
    ? await _doctorDataSource.findByStaffID(model.doctorId!)
    : null;
```

### Collections
```dart
// Schedule Map
final scheduleJson = <String, List<String>>{};
doctor.schedule.forEach((date, times) {
  scheduleJson[date] = times.map((dt) => dt.toIso8601String()).toList();
});
```

### Enums
```dart
// Saving
status: appointment.status.toString()

// Loading
AppointmentStatus statusEnum;
if (status.contains('COMPLETED')) {
  statusEnum = AppointmentStatus.COMPLETED;
}
```

## Error Handling

```dart
try {
  await dataSource.add(model, idGetter, toJson);
} on DataSourceException catch (e) {
  print('Failed to save: ${e.message}');
  // Handle gracefully
} catch (e) {
  print('Unexpected error: $e');
  rethrow;
}
```

## Testing

```dart
test('saves patient with meeting', () async {
  final doctor = Doctor(...);
  final patient = Patient(...);
  patient.scheduleNextMeeting(DateTime.now().add(Duration(days: 7)), doctor);
  
  await repository.save(patient);
  
  final saved = await repository.findById(patient.patientID);
  expect(saved?.hasNextMeeting, true);
  expect(saved?.nextMeetingDate, isNotNull);
  expect(saved?.nextMeetingDoctor?.staffID, doctor.staffID);
});
```

## Performance Tips

1. **Batch Operations**: Use `writeAll()` once instead of multiple `update()` calls
2. **Lazy Loading**: Don't resolve relationships unless needed
3. **Caching**: Cache frequently accessed entities in memory
4. **Indexing**: Keep maps of ID → Entity for fast lookups
5. **Predicates**: Use efficient filter logic in `findWhere()`

---

For complete documentation, see: `docs/data_layer_documentation.md`
