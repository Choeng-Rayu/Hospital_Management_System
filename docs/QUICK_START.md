# 🚀 Quick Start Guide

<div align="center">

**Get Up and Running in 5 Minutes**

*Installation | Setup | First Run | Common Tasks*

[![Dart](https://img.shields.io/badge/Dart-3.0+-blue?style=for-the-badge&logo=dart)]()
[![Platform](https://img.shields.io/badge/Platform-Cross--Platform-green?style=for-the-badge)]()

</div>

---

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [First Run](#-first-run)
- [Common Tasks](#-common-tasks)
- [Troubleshooting](#-troubleshooting)
- [Next Steps](#-next-steps)

---

## ✅ Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| **Dart SDK** | 3.0+ | Programming language |
| **Git** | Latest | Version control |
| **Terminal/Shell** | Any | Run commands |

### Check Your Installation

```bash
# Check Dart version
dart --version
# Should show: Dart SDK version: 3.0.0 or higher

# Check Git
git --version
# Should show: git version 2.x.x
```

### Install Dart (if needed)

**macOS:**
```bash
brew install dart
```

**Linux:**
```bash
sudo apt-get update
sudo apt-get install apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
sudo apt-get update
sudo apt-get install dart
```

**Windows:**
```powershell
choco install dart-sdk
```

Or download from: https://dart.dev/get-dart

---

## 📥 Installation

### Step 1: Clone the Repository

```bash
# Clone the project
git clone https://github.com/Choeng-Rayu/Hospital_Management_System.git

# Navigate to project directory
cd Hospital_Management_System
```

### Step 2: Install Dependencies

```bash
# Get all Dart dependencies
dart pub get
```

**Expected Output:**
```
Resolving dependencies...
Got dependencies!
```

### Step 3: Verify Installation

```bash
# Check project structure
ls -la

# Should see:
# - lib/          (Source code)
# - data/         (JSON files)
# - test/         (Tests)
# - docs/         (Documentation)
# - pubspec.yaml  (Dependencies)
```

---

## 🎮 First Run

### Run the Application

```bash
# Start the hospital management system
dart run lib/main.dart
```

**You should see:**

```
╔════════════════════════════════════════════╗
║   HOSPITAL MANAGEMENT SYSTEM               ║
║   Version 1.0.0                            ║
╚════════════════════════════════════════════╝

═══════════════════════════════════════════
  MAIN MENU
═══════════════════════════════════════════

  1. Patient Management
  2. Doctor Management
  3. Appointment Management
  4. Prescription Management
  5. Room Management
  6. Nurse Management
  7. Search Operations
  8. Emergency Operations
  0. Back / Exit

═══════════════════════════════════════════

Enter your choice (0-8):
```

### Quick Tour

**Try these actions:**

1. **View existing patients**
   - Enter `1` (Patient Management)
   - Enter `8` (View All Patients)
   - Press `0` to go back

2. **View all doctors**
   - Enter `2` (Doctor Management)
   - Enter `5` (List All Doctors)
   - Press `0` to go back

3. **Search for a patient**
   - Enter `7` (Search Operations)
   - Enter `1` (Search Patients)
   - Enter a name (e.g., "Sok")
   - Press `0` to go back

4. **Exit the application**
   - Enter `0` from main menu

---

## 🎯 Common Tasks

### Task 1: Register a New Patient

```
Main Menu → 1. Patient Management → 1. Register New Patient

Follow the prompts:
1. Enter patient name: Sok Pisey
2. Enter date of birth (YYYY-MM-DD): 1985-03-15
3. Enter address: Phnom Penh, Cambodia
4. Enter phone number: 012345678
5. Enter blood type: O+
6. Enter emergency contact: 012999888

✅ Patient P042 registered successfully!
```

### Task 2: Schedule an Appointment

```
Main Menu → 3. Appointment Management → 1. Schedule New Appointment

Follow the prompts:
1. Enter patient ID (PXXX): P001
2. Enter doctor ID (DXXX): D005
3. Enter appointment date (YYYY-MM-DD): 2025-11-15
4. Enter appointment time (HH:MM): 10:00
5. Enter duration in minutes (15-240): 30
6. Enter appointment reason: Regular checkup

✅ Appointment A127 scheduled successfully!
```

### Task 3: Search for Patients

```
Main Menu → 7. Search Operations → 1. Search Patients

Enter search term: Sok

Results:
─────────────────────────────────────────
ID      Name             Age    Status
─────────────────────────────────────────
P001    Sok Pisey        40     Admitted
P005    Sok Chantha      35     Outpatient
─────────────────────────────────────────
```

### Task 4: View Doctor Schedule

```
Main Menu → 2. Doctor Management → 3. View Doctor Schedule

1. Enter doctor ID (DXXX): D005
2. Enter date (YYYY-MM-DD): 2025-11-15

Dr. Sopheak Chan - Cardiology
Working Hours: 08:00 - 17:00
Break: 12:00 - 13:00

Scheduled Appointments:
  10:00 - 10:30: Sok Pisey (P001)
  14:00 - 14:45: Chea Sokha (P002)

Available Slots:
  08:00 - 10:00
  10:30 - 12:00
  13:00 - 14:00
  14:45 - 17:00
```

### Task 5: Emergency Admission

```
Main Menu → 8. Emergency Operations → 1. Admit Emergency Patient

Follow the prompts (simplified for speed):
1. Enter patient name: Emergency Patient
2. Enter age: 45
3. Enter emergency contact: 012888999
4. Enter emergency level (1-4): 1 (Critical)
5. Enter emergency reason: Cardiac arrest

✅ Emergency patient P043 admitted to ICU!
✅ Assigned to Room R201, Bed B201-1
✅ Doctor D005 notified
✅ Nurse N003 assigned
```

---

## 🧪 Run Tests

### Run All Tests

```bash
# Run all 137 tests
dart test

# Expected output:
# 00:02 +137: All tests passed!
```

### Run Specific Test File

```bash
# Test specific component
dart test test/domain/entities/patient_test.dart
dart test test/data/repositories/patient_repository_impl_test.dart
dart test test/presentation/menus/patient_menu_test.dart
```

### Run Tests with Coverage

```bash
# Install coverage package
dart pub global activate coverage

# Run tests with coverage
dart test --coverage=coverage

# Generate HTML report
dart pub global run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --report-on=lib

# View coverage (requires lcov tool)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔧 Development Workflow

### Make Code Changes

1. **Modify code** in `lib/` directory
2. **Run tests** to verify changes
3. **Test manually** with `dart run lib/main.dart`
4. **Commit changes** with Git

### Add New Feature

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes
# - Add entity in lib/domain/entities/
# - Add repository in lib/domain/repositories/
# - Add use case in lib/domain/usecases/
# - Add model in lib/data/models/
# - Add data source in lib/data/datasources/
# - Add repository impl in lib/data/repositories/
# - Add menu option in lib/presentation/menus/

# 3. Run tests
dart test

# 4. Commit changes
git add .
git commit -m "Add new feature"

# 5. Push to repository
git push origin feature/new-feature
```

---

## 🐛 Troubleshooting

### Issue: "dart: command not found"

**Solution**: Dart SDK not installed or not in PATH

```bash
# Check if Dart is installed
which dart

# If not found, install Dart (see Prerequisites section)
# Or add Dart to PATH:
export PATH="$PATH:/usr/lib/dart/bin"
```

### Issue: "pub get failed"

**Solution**: Network or dependency issue

```bash
# Clear pub cache
dart pub cache repair

# Try again
dart pub get

# If still fails, check internet connection
ping pub.dev
```

### Issue: "File not found: patients.json"

**Solution**: JSON files missing

```bash
# Verify data directory exists
ls data/jsons/

# If missing, create directory and files
mkdir -p data/jsons
echo '[]' > data/jsons/patients.json
echo '[]' > data/jsons/doctors.json
echo '[]' > data/jsons/nurses.json
echo '[]' > data/jsons/appointments.json
echo '[]' > data/jsons/prescriptions.json
echo '[]' > data/jsons/medications.json
echo '[]' > data/jsons/rooms.json
echo '[]' > data/jsons/equipment.json
echo '[]' > data/jsons/administrative.json
```

### Issue: "Tests failing"

**Solution**: Check test environment

```bash
# Run tests with verbose output
dart test --reporter expanded

# Run specific failing test
dart test test/path/to/failing_test.dart

# Check test logs for details
```

### Issue: "Port already in use" (if running server)

**Solution**: Kill existing process

```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>

# Or use different port
# (Not applicable for this console app)
```

### Issue: "Permission denied" on Linux/macOS

**Solution**: Fix file permissions

```bash
# Make script executable
chmod +x run.sh

# Or run with dart directly
dart run lib/main.dart
```

---

## 📚 Next Steps

### Learn the Architecture

1. **Read Documentation**
   - [Architecture Overview](ARCHITECTURE_OVERVIEW.md)
   - [Domain Layer](DOMAIN_LAYER.md)
   - [Data Layer](DATA_LAYER.md)
   - [Presentation Layer](PRESENTATION_LAYER.md)
   - [Layer Interactions](LAYER_INTERACTIONS.md)

2. **Explore the Code**
   - Start with `lib/domain/entities/`
   - Then `lib/domain/usecases/`
   - Then `lib/data/repositories/`
   - Finally `lib/presentation/menus/`

3. **Run Tests**
   - Understand test patterns
   - See how components are tested
   - Learn mocking strategies

### Customize the System

1. **Add New Entity**
   - Create entity in `lib/domain/entities/`
   - Add repository interface
   - Add use cases
   - Create model, data source, repository impl
   - Add menu options

2. **Modify Existing Features**
   - Find relevant use case
   - Modify business logic
   - Update tests
   - Test manually

3. **Change Storage**
   - Create new repository implementation
   - Keep domain and presentation unchanged
   - Demonstrates Clean Architecture flexibility

### Deploy

For a console application, deployment options:

1. **Compile to Native**
   ```bash
   dart compile exe lib/main.dart -o hospital_management
   ./hospital_management
   ```

2. **Docker Container**
   ```dockerfile
   FROM dart:stable
   WORKDIR /app
   COPY . .
   RUN dart pub get
   CMD ["dart", "run", "lib/main.dart"]
   ```

3. **Package as Executable**
   - Create standalone executable
   - Package with data files
   - Distribute to users

---

## 🎓 Learning Resources

### Official Documentation

- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Dart Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Project Documentation

- [README.md](../README.md) - Project overview
- [DOMAIN_LAYER.md](DOMAIN_LAYER.md) - Domain layer guide
- [DATA_LAYER.md](DATA_LAYER.md) - Data layer guide
- [PRESENTATION_LAYER.md](PRESENTATION_LAYER.md) - Presentation guide
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Testing guide

### Design Patterns

- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Use Case Pattern](https://www.baeldung.com/cs/use-case-vs-user-story)
- [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection)

---

## 💬 Get Help

### Issues?

- Check [Troubleshooting](#-troubleshooting) section
- Search existing issues on GitHub
- Create new issue with details:
  - Dart version (`dart --version`)
  - Operating system
  - Error message
  - Steps to reproduce

### Questions?

- Read the comprehensive documentation
- Check code comments
- Look at test examples
- Ask in project discussions

---

<div align="center">

**[⬆ Back to Top](#-quick-start-guide)**

Made with ❤️ for Hospital Management System

**Ready to start? Run `dart run lib/main.dart` now! 🚀**

</div>
