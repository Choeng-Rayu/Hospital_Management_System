# 🧪 Missing Test Cases - Detailed Checklist

This document lists **every specific test case** needed to achieve comprehensive coverage of all UI console features.

---

## 1️⃣ PATIENT MENU - Missing Tests

### ✅ Already Tested (29 tests)
- ✅ Load all patients (4 tests)
- ✅ Admit patient with AUTO ID (2 tests)
- ✅ Patient meeting scheduling (23 tests)

### ❌ Still Needed (10 tests)

#### Update Patient Operations (3 tests)
```dart
test('Should update patient name', () async {
  // Given: existing patient
  // When: update name
  // Then: name changed, other fields unchanged
});

test('Should update multiple patient fields', () async {
  // Given: existing patient
  // When: update name, address, phone, emergency contact
  // Then: all fields updated correctly
});

test('Should fail to update non-existent patient', () async {
  // Given: invalid patient ID
  // When: attempt update
  // Then: throws PatientNotFoundException
});
```

#### Discharge Patient Operations (2 tests)
```dart
test('Should discharge patient from room', () async {
  // Given: patient assigned to room/bed
  // When: discharge patient
  // Then: patient.currentRoom = null, bed available
});

test('Should fail to discharge patient not in room', () async {
  // Given: patient not assigned to room
  // When: attempt discharge
  // Then: throws appropriate error
});
```

#### Assign Doctor Operations (2 tests)
```dart
test('Should assign doctor to patient', () async {
  // Given: patient and doctor exist
  // When: assign doctor
  // Then: doctor in patient.assignedDoctors list
});

test('Should prevent duplicate doctor assignment', () async {
  // Given: doctor already assigned
  // When: assign same doctor again
  // Then: doctor appears only once in list
});
```

#### View/Filter Operations (3 tests)
```dart
test('Should view patients by specific doctor', () async {
  // Given: patients assigned to doctor D001
  // When: filter by D001
  // Then: only patients with D001 returned
});

test('Should view patients with upcoming meetings', () async {
  // Given: some patients have scheduled meetings
  // When: filter upcoming meetings
  // Then: only patients with future meetings returned
});

test('Should handle empty filter results', () async {
  // Given: no patients match filter
  // When: apply filter
  // Then: empty list returned, no errors
});
```

---

## 2️⃣ DOCTOR MENU - Missing Tests (20 tests needed)

### ❌ View Operations (3 tests)
```dart
test('Should view all doctors', () async {
  // Given: doctors in database
  // When: get all doctors
  // Then: all doctors returned with details
});

test('Should view doctor details', () async {
  // Given: valid doctor ID
  // When: get doctor details
  // Then: full doctor info including patients, schedule
});

test('Should fail to view invalid doctor', () async {
  // Given: non-existent doctor ID
  // When: get doctor
  // Then: throws DoctorNotFoundException
});
```

### ❌ Search Operations (4 tests)
```dart
test('Should search doctor by exact name', () async {
  // Given: doctor "John Smith"
  // When: search "John Smith"
  // Then: doctor found
});

test('Should search doctor by partial name', () async {
  // Given: doctor "John Smith"
  // When: search "john"
  // Then: doctor found (case-insensitive)
});

test('Should search doctor by ID', () async {
  // Given: doctor D001
  // When: search by D001
  // Then: exact doctor returned
});

test('Should return empty for no matches', () async {
  // Given: no doctors match
  // When: search "nonexistent"
  // Then: empty list, no errors
});
```

### ❌ Filter Operations (5 tests)
```dart
test('Should filter doctors by specialization', () async {
  // Given: multiple specializations
  // When: filter by "Cardiology"
  // Then: only cardiologists returned
});

test('Should view available doctors', () async {
  // Given: doctors with different schedules
  // When: check availability for date/time
  // Then: only available doctors returned
});

test('Should filter by working hours', () async {
  // Given: doctors with different schedules
  // When: check specific time
  // Then: only doctors working at that time
});

test('Should view doctors with capacity', () async {
  // Given: doctors with different patient loads
  // When: filter by patient count < max
  // Then: only doctors with capacity returned
});

test('Should filter available by date', () async {
  // Given: doctors with appointments
  // When: check specific date
  // Then: doctors without conflicts on that date
});
```

### ❌ Schedule Operations (4 tests)
```dart
test('Should view doctor schedule', () async {
  // Given: doctor with appointments
  // When: get schedule
  // Then: all appointments listed chronologically
});

test('Should get available time slots', () async {
  // Given: doctor working hours and existing appointments
  // When: get available slots for date
  // Then: only free slots returned
});

test('Should detect schedule conflicts', () async {
  // Given: appointment at 10:00 AM
  // When: check 10:30 AM slot
  // Then: slot marked as unavailable
});

test('Should handle weekend availability', () async {
  // Given: doctor doesn't work weekends
  // When: check Saturday slots
  // Then: no available slots
});
```

### ❌ Patient List Operations (2 tests)
```dart
test('Should view all patients for doctor', () async {
  // Given: doctor assigned to patients
  // When: get doctor patients
  // Then: all assigned patients returned
});

test('Should show patient count', () async {
  // Given: doctor with 5 patients
  // When: get doctor details
  // Then: patientCount = 5
});
```

### ❌ Workload Operations (2 tests)
```dart
test('Should calculate doctor workload', () async {
  // Given: doctor with appointments and patients
  // When: calculate workload
  // Then: accurate count of commitments
});

test('Should identify overworked doctors', () async {
  // Given: doctors with various patient loads
  // When: filter by high workload
  // Then: doctors above threshold
});
```

---

## 3️⃣ APPOINTMENT MENU - Missing Tests (25 tests needed)

### ❌ Create Operations (6 tests)
```dart
test('Should schedule new appointment', () async {
  // Given: valid patient, doctor, date/time
  // When: create appointment
  // Then: appointment saved with AUTO ID
});

test('Should fail scheduling conflicting appointment', () async {
  // Given: appointment at 10:00 AM with doctor
  // When: schedule another at 10:30 AM same doctor
  // Then: throws AppointmentConflictException
});

test('Should fail scheduling outside working hours', () async {
  // Given: doctor works 9-5
  // When: schedule at 7 PM
  // Then: throws OutsideWorkingHoursException
});

test('Should fail scheduling on weekend', () async {
  // Given: doctor doesn't work weekends
  // When: schedule on Saturday
  // Then: throws DoctorUnavailableException
});

test('Should fail with invalid patient', () async {
  // Given: non-existent patient ID
  // When: create appointment
  // Then: throws PatientNotFoundException
});

test('Should fail with invalid doctor', () async {
  // Given: non-existent doctor ID
  // When: create appointment
  // Then: throws DoctorNotFoundException
});
```

### ❌ View Operations (5 tests)
```dart
test('Should view all appointments', () async {
  // Given: appointments in database
  // When: get all
  // Then: all appointments with details
});

test('Should view upcoming appointments only', () async {
  // Given: past and future appointments
  // When: get upcoming
  // Then: only future appointments returned
});

test('Should view appointment details', () async {
  // Given: valid appointment ID
  // When: get details
  // Then: full info including patient, doctor, status
});

test('Should handle empty appointment list', () async {
  // Given: no appointments
  // When: get all
  // Then: empty list, no errors
});

test('Should fail viewing invalid appointment', () async {
  // Given: non-existent appointment ID
  // When: get details
  // Then: throws AppointmentNotFoundException
});
```

### ❌ Update Operations (4 tests)
```dart
test('Should reschedule appointment to new time', () async {
  // Given: existing appointment
  // When: change to different time (no conflict)
  // Then: appointment updated with new time
});

test('Should fail rescheduling to conflicting time', () async {
  // Given: appointment A at 10:00, B at 11:00
  // When: reschedule A to 11:00
  // Then: throws AppointmentConflictException
});

test('Should update appointment status', () async {
  // Given: appointment with SCHEDULED status
  // When: update to COMPLETED
  // Then: status changed
});

test('Should prevent invalid status transitions', () async {
  // Given: COMPLETED appointment
  // When: update to SCHEDULED
  // Then: throws InvalidStatusTransitionException
});
```

### ❌ Cancel Operations (2 tests)
```dart
test('Should cancel appointment', () async {
  // Given: scheduled appointment
  // When: cancel
  // Then: status = CANCELLED
});

test('Should fail cancelling already cancelled', () async {
  // Given: cancelled appointment
  // When: cancel again
  // Then: throws AlreadyCancelledException
});
```

### ❌ Filter Operations (6 tests)
```dart
test('Should view patient appointments', () async {
  // Given: patient with multiple appointments
  // When: filter by patient ID
  // Then: only that patient's appointments
});

test('Should view doctor appointments', () async {
  // Given: doctor with multiple appointments
  // When: filter by doctor ID
  // Then: only that doctor's appointments
});

test('Should filter by specific date', () async {
  // Given: appointments on various dates
  // When: filter by 2024-01-15
  // Then: only appointments on that date
});

test('Should filter by date range', () async {
  // Given: appointments across multiple weeks
  // When: filter by week range
  // Then: appointments within that week
});

test('Should filter by status', () async {
  // Given: various appointment statuses
  // When: filter by SCHEDULED
  // Then: only scheduled appointments
});

test('Should combine multiple filters', () async {
  // Given: various appointments
  // When: filter by doctor + date + status
  // Then: appointments matching all criteria
});
```

### ❌ Validation Operations (2 tests)
```dart
test('Should detect time conflicts', () async {
  // Given: appointments for same doctor
  // When: check for conflicts
  // Then: overlapping appointments identified
});

test('Should validate appointment duration', () async {
  // Given: appointment start and end times
  // When: validate duration
  // Then: ensure reasonable duration (e.g., 15-120 min)
});
```

---

## 4️⃣ PRESCRIPTION MENU - Missing Tests (18 tests needed)

### ❌ Create Operations (5 tests)
```dart
test('Should create prescription with single medication', () async {
  // Given: patient, doctor, medication
  // When: create prescription
  // Then: prescription saved with AUTO ID
});

test('Should create prescription with multiple medications', () async {
  // Given: 3 medications
  // When: create prescription
  // Then: all medications in prescription
});

test('Should auto-generate prescription ID', () async {
  // Given: existing prescriptions RX001-RX050
  // When: create new prescription
  // Then: ID = RX051
});

test('Should fail with invalid patient', () async {
  // Given: non-existent patient
  // When: create prescription
  // Then: throws PatientNotFoundException
});

test('Should fail with invalid doctor', () async {
  // Given: non-existent doctor
  // When: create prescription
  // Then: throws DoctorNotFoundException
});
```

### ❌ View Operations (4 tests)
```dart
test('Should view all prescriptions', () async {
  // Given: prescriptions in database
  // When: get all
  // Then: all prescriptions with medications
});

test('Should view prescription details', () async {
  // Given: valid prescription ID
  // When: get details
  // Then: full info including medications, patient, doctor
});

test('Should view patient prescriptions', () async {
  // Given: patient with multiple prescriptions
  // When: filter by patient
  // Then: only that patient's prescriptions
});

test('Should view doctor prescriptions', () async {
  // Given: doctor who prescribed medications
  // When: filter by doctor
  // Then: only that doctor's prescriptions
});
```

### ❌ Refill Operations (3 tests)
```dart
test('Should refill prescription', () async {
  // Given: existing prescription
  // When: refill
  // Then: new prescription created with same medications
});

test('Should track refill count', () async {
  // Given: prescription refilled twice
  // When: check refill count
  // Then: count = 2
});

test('Should prevent excessive refills', () async {
  // Given: prescription with max refills reached
  // When: attempt refill
  // Then: throws MaxRefillsExceededException
});
```

### ❌ Medication Operations (4 tests)
```dart
test('Should add medication with side effects', () async {
  // Given: medication with 3 side effects
  // When: add to prescription
  // Then: all side effects recorded
});

test('Should track medication dosage', () async {
  // Given: medication with specific dosage
  // When: create prescription
  // Then: dosage accurately recorded
});

test('Should include medication instructions', () async {
  // Given: medication with instructions
  // When: create prescription
  // Then: instructions attached
});

test('Should handle medication manufacturer', () async {
  // Given: medication with manufacturer
  // When: add to prescription
  // Then: manufacturer recorded
});
```

### ❌ Drug Interaction Operations (2 tests)
```dart
test('Should detect drug interactions', () async {
  // Given: medications with known interactions
  // When: check interactions
  // Then: conflicts identified
});

test('Should allow safe medication combinations', () async {
  // Given: medications with no interactions
  // When: check interactions
  // Then: no conflicts, prescription valid
});
```

---

## 5️⃣ ROOM MENU - Missing Tests (15 tests needed)

### ❌ Create Operations (3 tests)
```dart
test('Should add new room with beds', () async {
  // Given: room details with 3 beds
  // When: create room
  // Then: room and beds saved
});

test('Should auto-generate room ID', () async {
  // Given: existing rooms R001-R100
  // When: create new room
  // Then: ID = R101
});

test('Should validate room type', () async {
  // Given: invalid room type
  // When: create room
  // Then: throws InvalidRoomTypeException
});
```

### ❌ View Operations (3 tests)
```dart
test('Should view all rooms', () async {
  // Given: rooms in database
  // When: get all
  // Then: all rooms with bed details
});

test('Should view room details', () async {
  // Given: valid room ID
  // When: get details
  // Then: full info including beds, patients, status
});

test('Should view available rooms only', () async {
  // Given: some rooms occupied
  // When: filter available
  // Then: only rooms with available beds
});
```

### ❌ Update Operations (2 tests)
```dart
test('Should update room details', () async {
  // Given: existing room
  // When: update status, type
  // Then: changes saved
});

test('Should fail updating non-existent room', () async {
  // Given: invalid room ID
  // When: update
  // Then: throws RoomNotFoundException
});
```

### ❌ Delete Operations (1 test)
```dart
test('Should delete empty room', () async {
  // Given: room with no patients
  // When: delete
  // Then: room removed from database
});
```

### ❌ Bed Operations (4 tests)
```dart
test('Should assign patient to bed', () async {
  // Given: patient and available bed
  // When: assign
  // Then: bed.patientId = patient.id, bed.available = false
});

test('Should fail assigning to occupied bed', () async {
  // Given: bed with existing patient
  // When: assign different patient
  // Then: throws BedOccupiedException
});

test('Should discharge patient from bed', () async {
  // Given: patient in bed
  // When: discharge
  // Then: bed.patientId = null, bed.available = true
});

test('Should check bed availability', () async {
  // Given: room with 3 beds (2 occupied)
  // When: check availability
  // Then: 1 bed available
});
```

### ❌ Capacity Operations (2 tests)
```dart
test('Should calculate room capacity', () async {
  // Given: room with 4 beds
  // When: get capacity
  // Then: total = 4, available = X
});

test('Should prevent over-assignment', () async {
  // Given: room at full capacity
  // When: assign another patient
  // Then: throws RoomFullException
});
```

---

## 6️⃣ NURSE MENU - Missing Tests (18 tests needed)

### ❌ Create Operations (3 tests)
```dart
test('Should add new nurse', () async {
  // Given: nurse details
  // When: create nurse
  // Then: nurse saved with AUTO ID
});

test('Should auto-generate nurse ID', () async {
  // Given: existing nurses N001-N050
  // When: create new nurse
  // Then: ID = N051
});

test('Should validate required fields', () async {
  // Given: nurse missing required field
  // When: create
  // Then: throws ValidationException
});
```

### ❌ View Operations (3 tests)
```dart
test('Should view all nurses', () async {
  // Given: nurses in database
  // When: get all
  // Then: all nurses with details
});

test('Should view nurse details', () async {
  // Given: valid nurse ID
  // When: get details
  // Then: full info including schedule, patients
});

test('Should view nurse schedule', () async {
  // Given: nurse with shifts
  // When: get schedule
  // Then: shift details returned
});
```

### ❌ Search Operations (2 tests)
```dart
test('Should search nurse by name', () async {
  // Given: nurse "Jane Smith"
  // When: search "jane"
  // Then: nurse found (case-insensitive)
});

test('Should search nurse by ID', () async {
  // Given: nurse N001
  // When: search N001
  // Then: exact nurse returned
});
```

### ❌ Update Operations (3 tests)
```dart
test('Should update nurse information', () async {
  // Given: existing nurse
  // When: update name, address, phone
  // Then: changes saved
});

test('Should update nurse salary', () async {
  // Given: nurse with current salary
  // When: update salary
  // Then: new salary recorded
});

test('Should fail updating non-existent nurse', () async {
  // Given: invalid nurse ID
  // When: update
  // Then: throws NurseNotFoundException
});
```

### ❌ Delete Operations (2 tests)
```dart
test('Should delete nurse', () async {
  // Given: nurse with no current assignments
  // When: delete
  // Then: nurse removed
});

test('Should fail deleting assigned nurse', () async {
  // Given: nurse assigned to patients
  // When: delete
  // Then: throws NurseStillAssignedException
});
```

### ❌ Assignment Operations (3 tests)
```dart
test('Should assign nurse to patient', () async {
  // Given: nurse and patient
  // When: assign
  // Then: nurse added to patient.assignedNurses
});

test('Should prevent duplicate nurse assignment', () async {
  // Given: nurse already assigned
  // When: assign same nurse again
  // Then: nurse appears only once
});

test('Should view nurse patients', () async {
  // Given: nurse assigned to 5 patients
  // When: get nurse patients
  // Then: 5 patients returned
});
```

### ❌ Workload Operations (2 tests)
```dart
test('Should calculate nurse workload', () async {
  // Given: nurse with patient assignments
  // When: calculate workload
  // Then: patient count returned
});

test('Should identify overworked nurses', () async {
  // Given: nurses with various patient loads
  // When: filter by high workload
  // Then: nurses above threshold
});
```

---

## 7️⃣ SEARCH MENU - Missing Tests (15 tests needed)

### ❌ Patient Search (3 tests)
```dart
test('Should search patients by exact name', () async {
  // Already partially covered
});

test('Should search patients by partial name', () async {
  // Given: patient "John Smith"
  // When: search "john"
  // Then: patient found
});

test('Should search patients by ID pattern', () async {
  // Given: patients P001-P050
  // When: search "P00"
  // Then: P001-P009 returned
});
```

### ❌ Doctor Search (3 tests)
```dart
test('Should search doctors by name', () async {
  // Given: doctor name
  // When: search
  // Then: matching doctors
});

test('Should search doctors by specialization', () async {
  // Given: specialization keyword
  // When: search
  // Then: doctors in that specialization
});

test('Should search doctors by ID', () async {
  // Given: doctor ID pattern
  // When: search
  // Then: matching doctors
});
```

### ❌ Appointment Search (3 tests)
```dart
test('Should search appointments by patient name', () async {
  // Given: patient name
  // When: search appointments
  // Then: appointments for that patient
});

test('Should search appointments by doctor name', () async {
  // Given: doctor name
  // When: search appointments
  // Then: appointments with that doctor
});

test('Should search appointments by date', () async {
  // Given: specific date
  // When: search
  // Then: appointments on that date
});
```

### ❌ Prescription Search (2 tests)
```dart
test('Should search prescriptions by patient', () async {
  // Given: patient name/ID
  // When: search
  // Then: patient prescriptions
});

test('Should search prescriptions by medication', () async {
  // Given: medication name
  // When: search
  // Then: prescriptions containing that medication
});
```

### ❌ Room Search (2 tests)
```dart
test('Should search rooms by type', () async {
  // Given: room type
  // When: search
  // Then: rooms of that type
});

test('Should search available rooms', () async {
  // Given: availability requirement
  // When: search
  // Then: only available rooms
});
```

### ❌ Nurse Search (2 tests)
```dart
test('Should search nurses by name', () async {
  // Given: nurse name
  // When: search
  // Then: matching nurses
});

test('Should search nurses by ID', () async {
  // Given: nurse ID pattern
  // When: search
  // Then: matching nurses
});
```

---

## 8️⃣ EMERGENCY MENU - Missing Tests (12 tests needed)

### ❌ Emergency Registration (3 tests)
```dart
test('Should register emergency patient quickly', () async {
  // Given: minimal patient info
  // When: emergency registration
  // Then: patient registered, ID assigned
});

test('Should prioritize emergency registration', () async {
  // Given: emergency patient
  // When: register
  // Then: bypass normal validation, fast-track
});

test('Should record emergency reason', () async {
  // Given: emergency reason/condition
  // When: register
  // Then: reason recorded in patient record
});
```

### ❌ Emergency Room Operations (3 tests)
```dart
test('Should find available emergency room', () async {
  // Given: emergency and ICU rooms
  // When: search for emergency room
  // Then: only emergency-type rooms returned
});

test('Should prioritize ICU rooms for critical', () async {
  // Given: critical condition
  // When: find room
  // Then: ICU rooms prioritized
});

test('Should fail if no emergency rooms available', () async {
  // Given: all emergency rooms occupied
  // When: find room
  // Then: throws NoEmergencyRoomsAvailableException
});
```

### ❌ Emergency Doctor Assignment (2 tests)
```dart
test('Should assign available emergency doctor', () async {
  // Given: emergency patient and available doctors
  // When: assign emergency doctor
  // Then: first available doctor assigned
});

test('Should fail if no doctors available', () async {
  // Given: all doctors busy
  // When: assign emergency doctor
  // Then: throws NoDoctorsAvailableException
});
```

### ❌ Emergency Bed Assignment (2 tests)
```dart
test('Should assign emergency bed quickly', () async {
  // Given: emergency patient and available bed
  // When: assign bed
  // Then: first available bed assigned
});

test('Should handle emergency bed overflow', () async {
  // Given: all emergency beds occupied
  // When: assign bed
  // Then: escalate to regular rooms or notify
});
```

### ❌ Emergency Status View (2 tests)
```dart
test('Should view all active emergencies', () async {
  // Given: multiple emergency patients
  // When: view emergency status
  // Then: all current emergencies listed
});

test('Should show emergency metrics', () async {
  // Given: emergency operations
  // When: view status
  // Then: metrics (count, available beds, available doctors)
});
```

---

## 📊 Test Summary

### Total Tests Needed by Menu:
1. Patient: 10 additional tests
2. Doctor: 20 new tests
3. Appointment: 25 new tests
4. Prescription: 18 new tests
5. Room: 15 new tests
6. Nurse: 18 new tests
7. Search: 15 new tests
8. Emergency: 12 new tests

**Total New Tests: 133**
**Current Tests: 91**
**Target Total: 224 tests**

---

## 🎯 Implementation Priority

### Phase 1 (Critical - Week 1-2): 57 tests
- Appointments: 25 tests
- Doctors: 20 tests
- Emergency: 12 tests

### Phase 2 (High - Week 3-4): 43 tests
- Prescriptions: 18 tests
- Patient Operations: 10 tests
- Rooms: 15 tests

### Phase 3 (Medium - Week 5-6): 33 tests
- Nurses: 18 tests
- Search: 15 tests

---

## ✅ Test Structure Recommendations

### 1. Group Related Tests
```dart
group('Create Operations', () {
  // All create tests
});

group('View Operations', () {
  // All view tests
});

group('Update Operations', () {
  // All update tests
});

group('Delete Operations', () {
  // All delete tests
});

group('Business Logic', () {
  // Feature-specific logic
});
```

### 2. Use Test Cleanup
```dart
tearDownAll(() async {
  // Remove test data
  // Restore database state
});
```

### 3. Use Descriptive Names
```dart
// ✅ GOOD
test('Should fail scheduling appointment outside working hours', () {

// ❌ BAD
test('Test appointment 3', () {
```

### 4. Test Edge Cases
- Empty inputs
- Invalid IDs
- Boundary conditions
- Concurrent operations
- Database errors

---

**Ready to start implementing? Begin with Phase 1 - Appointment Tests!** 🚀
