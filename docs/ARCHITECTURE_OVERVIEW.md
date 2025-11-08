# 🏗️ Architecture Overview

<div align="center">

**Clean Architecture Implementation**

*Modular | Testable | Maintainable*

[![Architecture](https://img.shields.io/badge/Architecture-Clean-blue?style=for-the-badge)]()
[![Pattern](https://img.shields.io/badge/Pattern-Repository-green?style=for-the-badge)]()
[![Principles](https://img.shields.io/badge/Principles-SOLID-orange?style=for-the-badge)]()

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Clean Architecture](#-clean-architecture)
- [Project Structure](#-project-structure)
- [Design Patterns](#-design-patterns)
- [SOLID Principles](#-solid-principles)
- [Key Design Decisions](#-key-design-decisions)

---

## 🌟 Overview

This Hospital Management System is built using **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability.

### Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     CLEAN ARCHITECTURE                       │
│                                                              │
│   ┌──────────────────────────────────────────────────┐       │
│   │         PRESENTATION LAYER (Outer)               │       │
│   │                                                  │       │
│   │  • Console Menus (8 menus)                       │       │
│   │  • Input Validation                              │       │
│   │  • UI Formatting                                 │       │
│   │  • Main Controller                               │       │
│   │                                                  │       │
│   │  Dependencies: Domain                            │       │
│   └────────────────────┬─────────────────────────────┘       │
│                        │ depends on                          │
│   ┌────────────────────▼─────────────────────────────┐       │
│   │          DOMAIN LAYER (Core)                     │       │
│   │                                                  │       │
│   │  • Entities (12)                                 │       │
│   │  • Repository Interfaces (8)                     │       │
│   │  • Use Cases (50+)                               │       │
│   │  • Business Rules                                │       │
│   │  • Enumerations (6)                              │       │
│   │                                                  │       │
│   │  Dependencies: NONE ✨                           │       │
│   └────────────────────▲─────────────────────────────┘       │
│                        │ implements                          │
│   ┌────────────────────┴─────────────────────────────┐       │
│   │           DATA LAYER (Outer)                     │       │
│   │                                                  │       │
│   │  • Models/DTOs (10)                              │       │
│   │  • Repository Implementations (8)                │       │
│   │  • Data Sources (9)                              │       │
│   │  • JSON File I/O                                 │       │
│   │  • AUTO ID Generation                            │       │
│   │                                                  │       │
│   │  Dependencies: Domain                            │       │
│   └──────────────────────────────────────────────────┘       │
│                                                              │
└──────────────────────────────────────────────────────────────┘

                    ┌─────────────┐
                    │ JSON Files  │
                    │   (Storage) │
                    └─────────────┘
```

### Technology Stack

| Layer | Technologies | Purpose |
|-------|-------------|---------|
| **Presentation** | Dart Console I/O | User interaction |
| **Domain** | Pure Dart | Business logic |
| **Data** | Dart File I/O, JSON | Data persistence |
| **Testing** | Dart Test Package | Unit & integration tests |

---

## 🎯 Clean Architecture

### The Four Circles

```
┌─────────────────────────────────────────────────────────┐
│  1. Entities (innermost - most stable)                  │
│     Business objects with rules                         │
│                                                         │
│  2. Use Cases                                           │
│     Application-specific business rules                 │
│                                                         │
│  3. Interface Adapters (Controllers, Presenters)        │
│     Convert data between use cases and external systems │
│                                                         │
│  4. Frameworks & Drivers (outermost - most volatile)    │
│     Database, UI, External interfaces                   │
└─────────────────────────────────────────────────────────┘
```

### The Dependency Rule

**Key Principle**: Dependencies point inward. Inner circles know nothing about outer circles.

```
Presentation ──depends on──► Domain
Data ────────depends on──► Domain
Domain ──────depends on──► NOTHING! ✨
```

### Benefits

✅ **Independent of Frameworks** - Business logic doesn't depend on libraries  
✅ **Testable** - Domain can be tested without UI or database  
✅ **Independent of UI** - Swap console → web → mobile without changing domain  
✅ **Independent of Database** - Swap JSON → SQL → NoSQL easily  
✅ **Independent of External Services** - Business rules don't know about external systems  

---

## 📁 Project Structure

```
hospital_management_system/
│
├── lib/
│   ├── domain/                    # 🎯 CORE BUSINESS LOGIC
│   │   ├── entities/              # Business objects
│   │   │   ├── person.dart
│   │   │   ├── staff.dart
│   │   │   ├── patient.dart
│   │   │   ├── doctor.dart
│   │   │   ├── nurse.dart
│   │   │   ├── appointment.dart
│   │   │   ├── prescription.dart
│   │   │   ├── medication.dart
│   │   │   ├── room.dart
│   │   │   ├── bed.dart
│   │   │   ├── equipment.dart
│   │   │   ├── administrative.dart
│   │   │   └── enums/             # Type-safe enums
│   │   │
│   │   ├── repositories/          # Data access contracts
│   │   │   ├── patient_repository.dart
│   │   │   ├── doctor_repository.dart
│   │   │   ├── nurse_repository.dart
│   │   │   ├── appointment_repository.dart
│   │   │   ├── prescription_repository.dart
│   │   │   ├── room_repository.dart
│   │   │   ├── equipment_repository.dart
│   │   │   └── administrative_repository.dart
│   │   │
│   │   └── usecases/              # Business operations
│   │       ├── base/
│   │       ├── patient/           # 7 use cases
│   │       ├── doctor/            # 1 use case
│   │       ├── nurse/             # 6 use cases
│   │       ├── appointment/       # 8 use cases
│   │       ├── prescription/      # 7 use cases
│   │       ├── room/              # 6 use cases
│   │       ├── equipment/         # 6 use cases
│   │       ├── emergency/         # 5 use cases
│   │       └── search/            # 6 use cases
│   │
│   ├── data/                      # 💾 DATA LAYER
│   │   ├── models/                # DTOs for JSON
│   │   │   ├── patient_model.dart
│   │   │   ├── doctor_model.dart
│   │   │   ├── nurse_model.dart
│   │   │   ├── appointment_model.dart
│   │   │   ├── prescription_model.dart
│   │   │   ├── medication_model.dart
│   │   │   ├── room_model.dart
│   │   │   ├── bed_model.dart
│   │   │   ├── equipment_model.dart
│   │   │   └── administrative_model.dart
│   │   │
│   │   ├── datasources/           # JSON file operations
│   │   │   ├── patient_local_data_source.dart
│   │   │   ├── doctor_local_data_source.dart
│   │   │   ├── nurse_local_data_source.dart
│   │   │   ├── appointment_local_data_source.dart
│   │   │   ├── prescription_local_data_source.dart
│   │   │   ├── room_local_data_source.dart
│   │   │   ├── bed_local_data_source.dart
│   │   │   ├── equipment_local_data_source.dart
│   │   │   ├── medication_local_data_source.dart
│   │   │   └── id_generator.dart  # AUTO ID system
│   │   │
│   │   └── repositories/          # Repository implementations
│   │       ├── patient_repository_impl.dart
│   │       ├── doctor_repository_impl.dart
│   │       ├── nurse_repository_impl.dart
│   │       ├── appointment_repository_impl.dart
│   │       ├── prescription_repository_impl.dart
│   │       ├── room_repository_impl.dart
│   │       ├── equipment_repository_impl.dart
│   │       └── administrative_repository_impl.dart
│   │
│   ├── presentation/              # 🖥️ PRESENTATION LAYER
│   │   ├── menus/                 # Console menus
│   │   │   ├── base_menu.dart
│   │   │   ├── patient_menu.dart
│   │   │   ├── doctor_menu.dart
│   │   │   ├── nurse_menu.dart
│   │   │   ├── appointment_menu.dart
│   │   │   ├── prescription_menu.dart
│   │   │   ├── room_menu.dart
│   │   │   ├── search_menu.dart
│   │   │   └── emergency_menu.dart
│   │   │
│   │   ├── controllers/
│   │   │   └── main_menu_controller.dart
│   │   │
│   │   └── utils/
│   │       ├── input_validator.dart
│   │       └── ui_helper.dart
│   │
│   └── main.dart                  # Application entry point
│
├── data/
│   └── jsons/                     # 📄 JSON Storage
│       ├── patients.json
│       ├── doctors.json
│       ├── nurses.json
│       ├── administrative.json
│       ├── appointments.json
│       ├── prescriptions.json
│       ├── medications.json
│       ├── rooms.json
│       └── equipment.json
│
├── test/                          # ✅ Tests (137 tests)
│   ├── domain/
│   ├── data/
│   └── presentation/
│
├── docs/                          # 📚 Documentation
│   ├── DOMAIN_LAYER.md
│   ├── DATA_LAYER.md
│   ├── PRESENTATION_LAYER.md
│   ├── LAYER_INTERACTIONS.md
│   ├── ARCHITECTURE_OVERVIEW.md
│   └── QUICK_START.md
│
├── pubspec.yaml                   # Dependencies
└── README.md                      # Project overview
```

---

## 🎨 Design Patterns

### 1. Repository Pattern

**Purpose**: Abstract data access

```dart
// Domain defines interface (contract)
abstract class PatientRepository {
  Future<Patient> getById(String id);
  Future<void> save(Patient patient);
}

// Data implements interface
class PatientRepositoryImpl implements PatientRepository {
  @override
  Future<Patient> getById(String id) {
    // JSON implementation
  }
}

// Presentation uses interface (not implementation!)
class PatientMenu {
  final PatientRepository repository;  // Interface!
}
```

**Benefits**:
- Swap storage (JSON → SQL → API) without changing business logic
- Easy to mock for testing
- Clear contract between layers

### 2. Use Case Pattern

**Purpose**: Single Responsibility for business operations

```dart
// Each business operation is its own class
class ScheduleAppointment extends UseCase<Input, Output> {
  Future<Appointment> execute(Input input) {
    // Complex business logic here
  }
}

// Not a god class with 50 methods!
```

**Benefits**:
- Easy to find and modify specific operations
- Testable in isolation
- Clear inputs and outputs

### 3. Entity Pattern

**Purpose**: Rich domain models with behavior

```dart
class Patient extends Person {
  // Not just data!
  void admit(Room room, Bed bed) { ... }
  void discharge() { ... }
  void scheduleNextMeeting(Doctor doctor, DateTime time) { ... }
  
  // Business rules in the entity
  bool get isAdmitted => currentRoom != null && currentBed != null;
}
```

**Benefits**:
- Behavior with data (not anemic models)
- Business rules colocated with data
- Self-validating

### 4. DTO Pattern (Data Transfer Object)

**Purpose**: Transfer data between layers

```dart
// Model (DTO) for JSON conversion
class PatientModel {
  final String patientID;
  final List<String> assignedDoctorIds;  // IDs, not objects!
  
  Map<String, dynamic> toJson() { ... }
  factory PatientModel.fromJson(Map json) { ... }
}

// Entity for business logic
class Patient extends Person {
  final List<Doctor> assignedDoctors;  // Full objects!
  
  // Business methods
  void assignDoctor(Doctor doctor) { ... }
}
```

**Benefits**:
- Clean separation between persistence and domain
- Support multiple data formats
- Backward compatibility

### 5. Dependency Injection Pattern

**Purpose**: Provide dependencies from outside

```dart
// Bad: Create dependencies inside
class PatientMenu {
  final repository = PatientRepositoryImpl();  // ❌
}

// Good: Inject dependencies
class PatientMenu {
  final PatientRepository repository;  // ✅
  
  PatientMenu({required this.repository});
}

// Usage
final menu = PatientMenu(
  repository: PatientRepositoryImpl(...),
);
```

**Benefits**:
- Easy to test (inject mocks)
- Flexible configuration
- Loose coupling

---

## 🔧 SOLID Principles

### S - Single Responsibility Principle

✅ **Applied**: Each class has one reason to change

```dart
// One responsibility: Patient data and behavior
class Patient { ... }

// One responsibility: Schedule appointments
class ScheduleAppointment extends UseCase { ... }

// One responsibility: Validate input
class InputValidator { ... }
```

### O - Open/Closed Principle

✅ **Applied**: Open for extension, closed for modification

```dart
// Base menu - closed for modification
abstract class BaseMenu {
  Future<void> show() { ... }
}

// Extend with new functionality
class PatientMenu extends BaseMenu { ... }
class DoctorMenu extends BaseMenu { ... }
```

### L - Liskov Substitution Principle

✅ **Applied**: Subtypes can replace parent types

```dart
// Any Staff can be used where Staff is expected
Staff staff1 = Doctor(...);
Staff staff2 = Nurse(...);
Staff staff3 = Administrative(...);

print(staff1.yearsOfService);  // Works for all!
```

### I - Interface Segregation Principle

✅ **Applied**: Specific interfaces, not fat interfaces

```dart
// Not one giant interface with 100 methods
// Instead: Specific repository per entity

abstract class PatientRepository { ... }
abstract class DoctorRepository { ... }
abstract class NurseRepository { ... }
```

### D - Dependency Inversion Principle

✅ **Applied**: Depend on abstractions, not concretions

```dart
// ✅ Good: Depend on interface
class PatientMenu {
  final PatientRepository repository;  // Abstract!
}

// ❌ Bad: Depend on implementation
class PatientMenu {
  final PatientRepositoryImpl repository;  // Concrete!
}
```

---

## 🚀 Key Design Decisions

### Why Console UI?

**Decision**: Use console-based interface instead of GUI

**Reasons**:
- ✅ Focus on architecture, not UI frameworks
- ✅ Easy to demonstrate Clean Architecture
- ✅ Fast development and testing
- ✅ Clear separation of concerns
- ✅ Easy to port to any UI later (web, mobile, desktop)

### Why JSON Storage?

**Decision**: Use JSON files instead of database

**Reasons**:
- ✅ No database setup required
- ✅ Human-readable data
- ✅ Version control friendly
- ✅ Cross-platform compatibility
- ✅ Easy to inspect and debug
- ✅ Demonstrates Repository pattern (easy to swap later)

### Why AUTO ID Generation?

**Decision**: Auto-generate IDs instead of user input

**Reasons**:
- ✅ Prevents duplicate IDs
- ✅ Consistent format (P001, D001, etc.)
- ✅ Sequential and predictable
- ✅ No user error
- ✅ Simpler user experience

### Why No Database ORM?

**Decision**: Manual JSON parsing instead of ORM

**Reasons**:
- ✅ Full control over serialization
- ✅ Clear transformation logic
- ✅ No magic or hidden behavior
- ✅ Educational value
- ✅ Lightweight solution

### Why Use Cases?

**Decision**: Use Case pattern instead of services

**Reasons**:
- ✅ Single Responsibility Principle
- ✅ Easy to test independently
- ✅ Clear inputs and outputs
- ✅ Scalable (add new use cases easily)
- ✅ Business logic organization

### Why Repository Interface?

**Decision**: Interface in domain, implementation in data

**Reasons**:
- ✅ Domain independence
- ✅ Easy to mock for testing
- ✅ Flexibility to change implementation
- ✅ Clean Architecture compliance
- ✅ Dependency Inversion Principle

---

## 📊 Metrics

### Project Statistics

| Metric | Count | Notes |
|--------|-------|-------|
| **Total Lines of Code** | ~15,000 | Including tests and docs |
| **Entities** | 12 | Core business objects |
| **Use Cases** | 50+ | Business operations |
| **Repositories** | 8 | Data access interfaces |
| **Menus** | 8 | User interface screens |
| **Tests** | 137 | 100% passing |
| **Test Coverage** | ~85% | High coverage |
| **Documentation** | 10+ files | Comprehensive docs |

### Code Distribution

```
Domain Layer:   40% (Pure business logic)
Data Layer:     35% (Persistence & conversion)
Presentation:   25% (User interface)
```

---

## 🎯 Architecture Goals Achieved

✅ **Maintainability** - Clear structure, easy to modify  
✅ **Testability** - High test coverage, easy to test  
✅ **Scalability** - Easy to add features  
✅ **Flexibility** - Swap components easily  
✅ **Readability** - Well-organized, documented  
✅ **Reusability** - Domain logic reusable across platforms  

---

<div align="center">

**[⬆ Back to Top](#-architecture-overview)**

Made with ❤️ for Hospital Management System

</div>
