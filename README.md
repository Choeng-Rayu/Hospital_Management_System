# Hospital Management System

A comprehensive hospital management system built with Dart, following Clean Architecture principles.

## 🎯 Project Status

### ✅ Domain Layer - COMPLETE
- **12 Domain Entities** - All implemented with private encapsulation and validation
- **7 Repository Interfaces** - Extended with comprehensive data operation methods
- **28 Use Cases** - Complete business logic implementation across:
  - **Appointment Management** (8 use cases):
    - `ScheduleAppointment` - Create new appointments
    - `GetAppointmentHistory` - Retrieve appointment history with status analysis
    - `GetAppointmentsByDoctor` - Doctor's daily schedule and availability
    - `GetAppointmentsByPatient` - Patient's all appointments with statistics
    - `GetUpcomingAppointments` - List upcoming appointments with countdown
    - `RescheduleAppointment` - Reschedule with conflict validation
    - `UpdateAppointmentStatus` - Update appointment status through lifecycle
    - `CancelAppointment` - Cancel appointments
  
  - **Prescription Management** (7 use cases):
    - `CheckDrugInteractions` - Verify medication compatibility
    - `GetPrescriptionHistory` - Retrieve prescription history
    - `GetMedicationSchedule` - Generate medication adherence schedule
    - `PrescribeMedication` - Create new prescriptions
    - `RefillPrescription` - Refill existing prescriptions
    - `GetActivePrescriptions` - List active prescriptions
    - `DiscontinuePrescription` - Discontinue medications
  
  - **Equipment Management** (6 use cases):
    - `GetEquipmentStatus` - Comprehensive equipment status
    - `TransferEquipmentBetweenRooms` - Move equipment with logging
    - `GetMaintenanceDueEquipment` - List maintenance-due equipment
    - `ScheduleEquipmentMaintenance` - Schedule maintenance
    - `AssignEquipmentToRoom` - Assign equipment to rooms
    - `ReportEquipmentIssue` - Report equipment issues
  
  - **Search Operations** (6 use cases):
    - `SearchAppointments` - Advanced appointment search
    - `SearchPrescriptions` - Prescription search with filters
    - `SearchRooms` - Room availability search
    - `SearchDoctors` - Doctor search with specialization filters
    - `SearchPatients` - Patient search with multiple criteria
    - `SearchMedicalRecords` - Medical records search
  
  - **Additional Use Cases** (1 base class):
    - `UseCase<Input, Output>` - Base class for all use cases with lifecycle hooks
    - Smart validation, execution, and success/error handling

- **Comprehensive Entity Relationships** - All entities properly linked:
  - Bidirectional patient-doctor relationships
  - Room and bed management with occupancy tracking
  - Equipment inventory management
  - Prescription and medication associations
  - Appointment scheduling with status tracking
  - Meeting scheduling with conflict prevention

- **Smart Meeting Scheduling** - Intelligent availability checking and conflict prevention
- **Zero Compilation Errors** - All use cases fully verified and tested ✅

### 🔄 In Progress
- Data Layer - Repository implementations and data sources
- Presentation Layer - Flutter UI and controllers

## 📁 Project Structure

```
hospital_management/
├── lib/
│   ├── domain/              # Business logic layer
│   │   ├── entities/        # Core business entities
│   │   │   ├── enums/       # Enumeration types
│   │   │   ├── person.dart
│   │   │   ├── staff.dart
│   │   │   ├── patient.dart
│   │   │   ├── doctor.dart
│   │   │   ├── nurse.dart
│   │   │   ├── administrative.dart
│   │   │   ├── room.dart
│   │   │   ├── bed.dart
│   │   │   ├── equipment.dart
│   │   │   ├── medication.dart
│   │   │   ├── prescription.dart
│   │   │   └── appointment.dart
│   │   ├── repositories/    # Repository interfaces
│   │   │   ├── patient_repository.dart
│   │   │   ├── doctor_repository.dart
│   │   │   ├── nurse_repository.dart
│   │   │   ├── room_repository.dart
│   │   │   ├── prescription_repository.dart
│   │   │   ├── equipment_repository.dart
│   │   │   └── appointment_repository.dart
│   │   └── usecases/        # Business use cases (28 total)
│   │       ├── base/
│   │       │   └── use_case.dart         # Base UseCase class with lifecycle
│   │       ├── appointment/              # 8 appointment use cases
│   │       │   ├── schedule_appointment.dart
│   │       │   ├── get_appointment_history.dart
│   │       │   ├── get_appointments_by_doctor.dart
│   │       │   ├── get_appointments_by_patient.dart
│   │       │   ├── get_upcoming_appointments.dart
│   │       │   ├── reschedule_appointment.dart
│   │       │   ├── update_appointment_status.dart
│   │       │   └── cancel_appointment.dart
│   │       ├── prescription/             # 7 prescription use cases
│   │       │   ├── prescribe_medication.dart
│   │       │   ├── check_drug_interactions.dart
│   │       │   ├── get_prescription_history.dart
│   │       │   ├── get_medication_schedule.dart
│   │       │   ├── get_active_prescriptions.dart
│   │       │   ├── refill_prescription.dart
│   │       │   └── discontinue_prescription.dart
│   │       ├── equipment/                # 6 equipment use cases
│   │       │   ├── assign_equipment_to_room.dart
│   │       │   ├── get_equipment_status.dart
│   │       │   ├── transfer_equipment_between_rooms.dart
│   │       │   ├── get_maintenance_due_equipment.dart
│   │       │   ├── schedule_equipment_maintenance.dart
│   │       │   └── report_equipment_issue.dart
│   │       ├── search/                   # 6 search use cases
│   │       │   ├── search_appointments.dart
│   │       │   ├── search_prescriptions.dart
│   │       │   ├── search_rooms.dart
│   │       │   ├── search_doctors.dart
│   │       │   ├── search_patients.dart
│   │       │   └── search_medical_records.dart
│   │       ├── patient/                  # Patient use cases
│   │       ├── doctor/                   # Doctor use cases
│   │       ├── nurse/                    # Nurse use cases
│   │       └── room/                     # Room use cases
│   │
│   ├── data/                # Data handling layer
│   │   ├── datasources/     # Data sources (local/remote)
│   │   │   ├── local/       # Local storage (JSON, SQLite, etc.)
│   │   │   └── remote/      # API calls (if needed)
│   │   ├── models/          # Data models (DTOs)
│   │   │   ├── patient_model.dart
│   │   │   ├── doctor_model.dart
│   │   │   ├── nurse_model.dart
│   │   │   ├── room_model.dart
│   │   │   └── ...
│   │   └── repositories/    # Repository implementations
│   │       ├── patient_repository_impl.dart
│   │       ├── doctor_repository_impl.dart
│   │       └── ...
│   │
│   └── presentation/        # User interface layer
│       ├── console/         # Console-based UI
│       │   ├── menus/       # Menu screens
│       │   │   ├── main_menu.dart
│       │   │   ├── patient_menu.dart
│       │   │   ├── doctor_menu.dart
│       │   │   ├── nurse_menu.dart
│       │   │   ├── room_menu.dart
│       │   │   └── appointment_menu.dart
│       │   └── utils/       # UI utilities
│       │       ├── input_validator.dart
│       │       └── display_formatter.dart
│       └── controllers/     # Business logic controllers
│           ├── patient_controller.dart
│           ├── doctor_controller.dart
│           └── ...
│
├── test/                    # Unit and integration tests
│   ├── domain/
│   ├── data/
│   └── presentation/
│
└── bin/
    └── main.dart           # Application entry point
```

## 📚 Layer Descriptions

### 🎯 Domain Layer (`lib/domain/`)
**Purpose**: Contains the core business logic and rules. This layer is independent of any external frameworks or libraries.

#### `entities/`
- **What**: Pure business objects representing real-world concepts
- **Why**: These are the heart of your application, defining what your system is about
- **Examples**: Patient, Doctor, Room, Prescription
- **Rules**: 
  - No dependencies on other layers
  - Contains only business logic
  - Immutable where possible with private fields

#### `repositories/`
- **What**: Abstract interfaces defining data operations
- **Why**: Allows the domain layer to define what data operations it needs without knowing how they're implemented
- **Examples**: `PatientRepository`, `DoctorRepository`
- **Rules**:
  - Only interfaces/abstract classes
  - No implementation details
  - Uses domain entities, not data models

#### `usecases/`
- **What**: Specific business use cases or actions
- **Why**: Encapsulates single pieces of business logic that orchestrate entities
- **Examples**: `AdmitPatient`, `ScheduleAppointment`, `PrescribeMedication`
- **Rules**:
  - One class per use case
  - Uses repositories to get/save data
  - Contains business validation logic

### 💾 Data Layer (`lib/data/`)
**Purpose**: Handles all data operations - storage, retrieval, and API calls. Implements the repository interfaces defined in the domain layer.

#### `datasources/`
- **What**: Raw data access implementations
- **Why**: Separates the actual data access mechanism from business logic
- **local/**: File storage, JSON, SQLite, shared preferences
- **remote/**: HTTP API calls, web services
- **Examples**: `PatientLocalDataSource`, `DoctorRemoteDataSource`
- **Rules**:
  - Direct access to storage/API
  - Returns data models, not entities
  - Handles serialization/deserialization

#### `models/`
- **What**: Data Transfer Objects (DTOs) that match your storage/API structure
- **Why**: Separates data representation from business entities
- **Examples**: `PatientModel` extends or converts to `Patient` entity
- **Rules**:
  - Contains `fromJson()` and `toJson()` methods
  - Can convert to/from domain entities
  - Matches external data structure

#### `repositories/`
- **What**: Concrete implementations of repository interfaces
- **Why**: Bridges the gap between data sources and domain layer
- **Examples**: `PatientRepositoryImpl implements PatientRepository`
- **Rules**:
  - Implements domain repository interfaces
  - Uses data sources to get data
  - Converts between models and entities
  - Handles error cases

### 🖥️ Presentation Layer (`lib/presentation/`)
**Purpose**: Handles all user interaction - displaying information and capturing input.

#### `console/menus/`
- **What**: Console-based menu screens for user interaction
- **Why**: Provides the user interface for the console application
- **Examples**: Main menu, Patient management menu, Room booking menu
- **Rules**:
  - Handles user input/output
  - Calls controllers for business operations
  - No business logic here

#### `console/utils/`
- **What**: Helper utilities for the console UI
- **Why**: Reusable formatting and validation logic
- **Examples**: Input validators, table formatters, color utilities
- **Rules**:
  - Pure utility functions
  - No business logic
  - Reusable across menus

#### `controllers/`
- **What**: Coordinates between UI and use cases
- **Why**: Keeps UI code clean and testable
- **Examples**: `PatientController`, `AppointmentController`
- **Rules**:
  - Receives requests from UI
  - Calls appropriate use cases
  - Formats responses for UI

## 🔄 How Layers Interact

```
[Presentation Layer]
        ↓
    Controllers
        ↓
[Domain Layer]
    Use Cases → Repository Interfaces
        ↓
[Data Layer]
    Repository Implementations → Data Sources → Storage/API
```

### Data Flow Example: Admitting a Patient
1. **Presentation**: User inputs patient details in `PatientMenu`
2. **Presentation**: `PatientController` receives the input
3. **Domain**: Controller calls `AdmitPatient` use case
4. **Domain**: Use case validates business rules and calls `PatientRepository.save()`
5. **Data**: `PatientRepositoryImpl` converts entity to model
6. **Data**: `PatientLocalDataSource` saves to JSON/database
7. **Response flows back up** through the layers

## 🎯 Key Principles

### Dependency Rule
- **Inner layers don't know about outer layers**
- Domain doesn't know about Data or Presentation
- Data knows about Domain but not Presentation
- Presentation knows about Domain and Data

### Separation of Concerns
- Each layer has a single responsibility
- Business logic stays in Domain
- Data access stays in Data
- UI logic stays in Presentation

### Testability
- Each layer can be tested independently
- Mock repositories for testing use cases
- Mock data sources for testing repositories
- Test business logic without UI or database

## 🚀 Getting Started

### Prerequisites
- Dart SDK 3.0.0 or higher

### Installation
```bash
# Install dependencies
dart pub get

# Run the application
dart run bin/main.dart

# Run tests
dart test
```

## 📝 Development Workflow

1. **Start with Domain**: Define entities and their relationships
2. **Define Repositories**: Create interfaces for data operations needed
3. **Create Use Cases**: Implement business logic using entities and repositories
4. **Implement Data Layer**: Create models and repository implementations
5. **Build Presentation**: Create menus and controllers
6. **Test**: Write tests for each layer

## ✨ Key Features

### ✅ Zero Compilation Errors
- All 28 use case files verified and error-free
- Proper entity property references throughout
- Correct enum usage with direct comparisons
- UseCase base class with proper lifecycle hooks (validate, execute, onSuccess, onError)
- Comprehensive imports and dependency management

### 🗓️ Smart Meeting Scheduling
The system includes an intelligent meeting scheduling feature with doctor availability checking:

- **Automatic Availability Checking**: Prevents double-booking by validating doctor's schedule
- **Conflict Detection**: Identifies time conflicts with existing appointments
- **Schedule Management**: Automatically updates both patient and doctor schedules
- **Availability Queries**: Check if a doctor is free at a specific time
- **Smart Suggestions**: Get list of available time slots for any date
- **Flexible Rescheduling**: Move meetings with automatic schedule updates

#### Example Usage:
```dart
// Check if doctor is available
bool isAvailable = patient.isDoctorAvailableAt(
  doctor: doctor,
  dateTime: DateTime(2025, 11, 2, 10, 0),
  durationMinutes: 30,
);

// Get available time slots
List<DateTime> slots = patient.getSuggestedAvailableSlots(
  doctor: doctor,
  date: DateTime.now().add(Duration(days: 1)),
  startHour: 9,
  endHour: 17,
);

// Schedule meeting (with automatic availability check)
patient.scheduleNextMeeting(
  doctor: doctor,
  meetingDate: DateTime(2025, 11, 2, 10, 0),
  durationMinutes: 45,
);

// Reschedule (automatically updates both schedules)
patient.rescheduleNextMeeting(
  DateTime(2025, 11, 2, 14, 0),
  durationMinutes: 30,
);
```

**Key Benefits:**
- ✅ Prevents scheduling conflicts
- ✅ Real-time availability checking
- ✅ Automatic bidirectional schedule updates
- ✅ User-friendly time slot suggestions
- ✅ Validates doctor assignment before scheduling

## 🏗️ Domain Use Case Architecture

### UseCase Base Class
All use cases inherit from the `UseCase<Input, Output>` base class, which provides:

```dart
abstract class UseCase<Input, Output> {
  /// Execute the use case with the given input
  Future<Output> execute(Input input);

  /// Validate input before execution (optional override)
  Future<bool> validate(Input input) async => true;

  /// Hook called when execution fails (optional override)
  Future<void> onError(Exception error, Input input) async {}

  /// Hook called when execution succeeds (optional override)
  Future<void> onSuccess(Output result, Input input) async {}

  /// Execute with full lifecycle (validation, execution, hooks)
  Future<Output> call(Input input) async { ... }
}
```

### Use Case Lifecycle
1. **Validation** - `validate()` checks input criteria
2. **Execution** - `execute()` performs business logic
3. **Success Hook** - `onSuccess()` handles successful completion
4. **Error Hook** - `onError()` handles exceptions

### Entity Properties Reference

#### Appointment
```dart
- id: String (appointment identifier)
- dateTime: DateTime (appointment scheduled time)
- duration: int (appointment duration in minutes)
- patient: Patient (not patientId - full object)
- doctor: Doctor (not doctorId - full object)
- room: Room? (optional room assignment)
- status: AppointmentStatus (enum: SCHEDULE, IN_PROGRESS, COMPLETED, CANCELLED, NO_SHOW)
- reason: String (appointment reason/notes)
```

#### Equipment
```dart
- equipmentId: String (equipment identifier)
- name: String (equipment name)
- type: String (equipment type)
- serialNumber: String (equipment serial number)
- status: EquipmentStatus (enum: OPERATIONAL, IN_MAINTENANCE, NEEDS_CALIBRATION, OUT_OF_SERVICE)
- lastServiceDate: DateTime (not lastMaintenanceDate)
- nextServiceDate: DateTime (not nextMaintenanceDate)
```

#### Patient
```dart
- patientID: String (not id - specific to patient domain)
- name: String (inherited from Person, not firstName/lastName)
- dateOfBirth: String
- address: String
- tel: String
- bloodType: String
- medicalRecords: List<String>
- allergies: List<String>
- emergencyContact: String
- assignedDoctors: List<Doctor>
- assignedNurses: List<Nurse>
- prescriptions: List<Prescription>
- currentRoom: Room?
- currentBed: Bed?
```

#### Doctor
```dart
- staffID: String (from Staff inheritance)
- name: String (from Person inheritance)
- specialization: String
- department: String
```

#### Room
```dart
- roomId: String
- number: String (not roomNumber)
- roomType: RoomType (enum: ICU, GENERAL, OPERATION_THEATRE, etc.)
- status: RoomStatus (enum: AVAILABLE, OCCUPIED, UNDER_MAINTENANCE)
- equipment: List<Equipment>
- beds: List<Bed>
```

## 🧪 Testing Strategy

- **Unit Tests**: Test individual classes and methods
- **Integration Tests**: Test interaction between layers
- **Domain Tests**: Focus on business logic validation
- **Data Tests**: Mock data sources, test repositories
- **Presentation Tests**: Test controllers and input validation

### Running Tests
```bash
# Run all tests
dart test

# Run specific test file
dart test test/domain/entities/patient_meeting_test.dart

# Run with coverage
dart test --coverage

# See the meeting scheduling example
dart run examples/meeting_scheduling_example.dart
```

## 📄 License

This project is for educational purposes.

## 👥 Contributors

- Development Team

---

**Note**: This is a console-based application following Clean Architecture principles. The structure supports easy migration to GUI (Flutter) or web interfaces in the future.