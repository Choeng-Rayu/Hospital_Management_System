# Meeting Scheduling System Documentation

## Overview
The Hospital Management System includes an intelligent meeting scheduling feature that prevents conflicts and ensures efficient doctor-patient appointment management. This system automatically checks doctor availability, prevents double-booking, and maintains synchronized schedules between patients and doctors.

## Architecture

### Core Components

1. **Patient Entity** (`lib/domain/entities/patient.dart`)
   - Manages patient's next meeting information
   - Validates scheduling constraints
   - Provides availability checking methods

2. **Doctor Entity** (`lib/domain/entities/doctor.dart`)
   - Maintains schedule as `Map<String, List<DateTime>>`
   - Schedule key format: "YYYY-MM-DD"
   - Supports adding/removing schedule entries

3. **Staff Entity** (`lib/domain/entities/staff.dart`)
   - Base class for all staff (including doctors)
   - Provides schedule management infrastructure

## Features

### 1. Availability Checking
Check if a doctor is available at a specific date and time before scheduling.

```dart
bool isAvailable = patient.isDoctorAvailableAt(
  doctor: myDoctor,
  dateTime: DateTime(2025, 11, 5, 10, 0),
  durationMinutes: 30, // Default is 30 minutes
);
```

**How it works:**
- Checks doctor's schedule for the requested date
- Verifies no time overlap with existing appointments
- Considers appointment duration for conflict detection
- Returns `true` if doctor is free, `false` if busy

### 2. Schedule a Meeting
Schedule a new meeting with automatic availability validation.

```dart
try {
  patient.scheduleNextMeeting(
    doctor: myDoctor,
    meetingDate: DateTime(2025, 11, 5, 10, 0),
    durationMinutes: 45,
  );
  print('Meeting scheduled successfully!');
} catch (e) {
  print('Failed to schedule: $e');
}
```

**Validations:**
- ✅ Doctor must be assigned to the patient
- ✅ Meeting date must be in the future
- ✅ Doctor must be available at requested time
- ✅ Automatically adds meeting to doctor's schedule

**Throws ArgumentError if:**
- Doctor is not assigned to patient
- Meeting date is in the past
- Doctor has a conflicting appointment

### 3. Cancel a Meeting
Cancel a scheduled meeting and update both schedules.

```dart
patient.cancelNextMeeting();
```

**Effects:**
- Removes meeting from patient record
- Removes meeting from doctor's schedule
- Resets all meeting-related fields

### 4. Reschedule a Meeting
Change the meeting time with automatic validation.

```dart
try {
  patient.rescheduleNextMeeting(
    DateTime(2025, 11, 5, 14, 0),
    durationMinutes: 30,
  );
  print('Meeting rescheduled successfully!');
} catch (e) {
  print('Failed to reschedule: $e');
}
```

**Behavior:**
- Removes old meeting from doctor's schedule
- Validates new time is available
- Adds new meeting to doctor's schedule
- Updates patient's meeting information

### 5. Get Available Time Slots
Retrieve a list of available time slots for a specific date.

```dart
List<DateTime> slots = patient.getSuggestedAvailableSlots(
  doctor: myDoctor,
  date: DateTime(2025, 11, 5),
  durationMinutes: 30,
  startHour: 9,    // Default: 8 AM
  endHour: 17,     // Default: 5 PM
);

print('Available slots:');
for (var slot in slots) {
  print('  ${slot.hour}:${slot.minute.toString().padLeft(2, '0')}');
}
```

**Parameters:**
- `doctor` - The doctor to check availability for
- `date` - The date to check
- `durationMinutes` - Meeting duration (default: 30)
- `startHour` - Start of working hours (default: 8)
- `endHour` - End of working hours (default: 17)

**Returns:**
- List of available DateTime objects
- Only includes future times
- Slots are generated every 30 minutes
- Excludes times with conflicts

### 6. View Doctor's Schedule
Get all scheduled appointments for a specific date.

```dart
List<DateTime> schedule = patient.getDoctorScheduleForDate(
  doctor: myDoctor,
  date: DateTime(2025, 11, 5),
);

print('Doctor has ${schedule.length} appointments on this date');
```

### 7. Meeting Status Checks
Check the status of the scheduled meeting.

```dart
// Check if patient has a meeting scheduled
if (patient.hasNextMeeting) {
  // Check if meeting is soon (within 7 days)
  if (patient.isNextMeetingSoon) {
    print('Meeting is coming up soon!');
  }
  
  // Check if meeting is overdue
  if (patient.isNextMeetingOverdue) {
    print('Meeting date has passed!');
  }
  
  // Get formatted meeting information
  print(patient.nextMeetingInfo);
  // Output: "Next meeting with Dr. John Smith on 2025-11-05 10:00"
}
```

## Data Structure

### Patient Meeting Fields
```dart
class Patient {
  bool _hasNextMeeting;           // Whether a meeting is scheduled
  DateTime? _nextMeetingDate;     // When the meeting is scheduled
  Doctor? _nextMeetingDoctor;     // Which doctor the meeting is with
  
  // Getters
  bool get hasNextMeeting;
  DateTime? get nextMeetingDate;
  Doctor? get nextMeetingDoctor;
}
```

### Doctor Schedule Structure
```dart
class Doctor {
  Map<String, List<DateTime>> _schedule;
  
  // Key format: "YYYY-MM-DD"
  // Example:
  // {
  //   "2025-11-05": [
  //     DateTime(2025, 11, 5, 10, 0),
  //     DateTime(2025, 11, 5, 14, 0),
  //   ]
  // }
}
```

## Conflict Detection Algorithm

The system uses time interval overlap detection:

```
Requested Time: [10:00 -------- 10:30]
Existing Time:         [10:15 -------- 10:45]
Result: CONFLICT (overlap detected)

Requested Time: [10:00 -------- 10:30]
Existing Time:                           [11:00 -------- 11:30]
Result: NO CONFLICT (no overlap)
```

**Overlap Logic:**
```dart
bool hasConflict = (requestedStart < existingEnd) && 
                   (requestedEnd > existingStart);
```

## Best Practices

### 1. Always Check Availability First
```dart
// ✅ Good: Check before scheduling
if (patient.isDoctorAvailableAt(doctor: doc, dateTime: time)) {
  patient.scheduleNextMeeting(doctor: doc, meetingDate: time);
}

// ❌ Bad: Schedule without checking
patient.scheduleNextMeeting(doctor: doc, meetingDate: time); // Might throw error
```

### 2. Handle Scheduling Errors
```dart
try {
  patient.scheduleNextMeeting(doctor: doc, meetingDate: time);
} catch (e) {
  if (e is ArgumentError) {
    // Show user-friendly error message
    print('Cannot schedule: ${e.message}');
    // Suggest alternative times
    var alternatives = patient.getSuggestedAvailableSlots(...);
    print('Available times: $alternatives');
  }
}
```

### 3. Use Available Slots for UI
```dart
// Get available slots for date picker
final slots = patient.getSuggestedAvailableSlots(
  doctor: selectedDoctor,
  date: selectedDate,
  startHour: 9,
  endHour: 17,
);

// Display in UI
for (var slot in slots) {
  // Show as clickable option
  displayTimeOption(slot);
}
```

### 4. Validate Before Rescheduling
```dart
if (patient.hasNextMeeting) {
  try {
    patient.rescheduleNextMeeting(newTime);
  } catch (e) {
    print('Cannot reschedule to that time');
    // Show alternative slots
  }
} else {
  print('No meeting to reschedule');
}
```

## Example Workflow

### Complete Meeting Scheduling Flow
```dart
// 1. Create entities
final doctor = Doctor(...);
final patient = Patient(...);

// 2. Assign doctor to patient
patient.assignDoctor(doctor);

// 3. Get available slots
final tomorrow = DateTime.now().add(Duration(days: 1));
final availableSlots = patient.getSuggestedAvailableSlots(
  doctor: doctor,
  date: tomorrow,
);

// 4. Select a slot
final selectedSlot = availableSlots.first;

// 5. Schedule meeting
try {
  patient.scheduleNextMeeting(
    doctor: doctor,
    meetingDate: selectedSlot,
    durationMinutes: 45,
  );
  print('✓ Meeting scheduled for ${patient.nextMeetingInfo}');
} catch (e) {
  print('✗ Failed: $e');
}

// 6. Check meeting status
if (patient.isNextMeetingSoon) {
  sendReminder(patient);
}

// 7. Reschedule if needed
if (needsReschedule) {
  final newSlot = availableSlots[1];
  patient.rescheduleNextMeeting(newSlot);
}

// 8. Cancel if needed
if (needsCancel) {
  patient.cancelNextMeeting();
}
```

## Testing

The system includes comprehensive tests covering:

- ✅ Basic scheduling and cancellation
- ✅ Conflict detection
- ✅ Availability checking
- ✅ Schedule synchronization
- ✅ Rescheduling logic
- ✅ Time slot generation
- ✅ Edge cases (past dates, unassigned doctors, etc.)

Run tests:
```bash
dart test test/domain/entities/patient_meeting_test.dart
```

See example:
```bash
dart run examples/meeting_scheduling_example.dart
```

## Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| "Cannot schedule meeting with unassigned doctor" | Doctor not assigned to patient | Call `patient.assignDoctor(doctor)` first |
| "Meeting date must be in the future" | Trying to schedule in the past | Choose a future date/time |
| "Doctor [name] is not available at [time]" | Time conflict detected | Choose a different time or use `getSuggestedAvailableSlots()` |
| "No meeting scheduled to reschedule" | Trying to reschedule when no meeting exists | Schedule a meeting first |

## Future Enhancements

Potential improvements for the scheduling system:

1. **Meeting Types**: Support different types of meetings (consultation, follow-up, emergency)
2. **Recurring Meetings**: Schedule regular check-ups automatically
3. **Meeting Priorities**: Urgent meetings vs routine check-ups
4. **Notification System**: Automatic reminders via email/SMS
5. **Multi-Doctor Meetings**: Support team consultations
6. **Time Zone Support**: Handle patients and doctors in different time zones
7. **Break Management**: Respect doctor's lunch breaks and holidays
8. **Duration Estimation**: Suggest appropriate duration based on meeting type

## Summary

The meeting scheduling system provides:
- ✅ Automatic conflict prevention
- ✅ Real-time availability checking
- ✅ Bidirectional schedule updates
- ✅ Smart time slot suggestions
- ✅ Comprehensive validation
- ✅ Easy-to-use API
- ✅ Production-ready with tests

This ensures efficient doctor-patient meeting management with no double-booking and optimal schedule utilization.
