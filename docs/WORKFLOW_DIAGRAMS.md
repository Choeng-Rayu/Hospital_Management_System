# Meeting Scheduling Workflow Diagrams

## 1. Schedule Meeting Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Schedule Meeting Request                     │
│  patient.scheduleNextMeeting(doctor, meetingDate, duration)     │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ Validate Doctor     │───── NO ──► ArgumentError
                    │ is Assigned?        │
                    └─────────┬───────────┘
                              │ YES
                              ▼
                    ┌─────────────────────┐
                    │ Validate Date       │───── NO ──► ArgumentError
                    │ is in Future?       │
                    └─────────┬───────────┘
                              │ YES
                              ▼
                    ┌─────────────────────┐
                    │ Check Doctor        │
                    │ Availability        │
                    └─────────┬───────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
               YES                         NO
                │                           │
                ▼                           ▼
    ┌───────────────────────┐    ┌────────────────────┐
    │ Remove Old Meeting    │    │  ArgumentError:    │
    │ (if rescheduling)     │    │ "Doctor not        │
    └───────────┬───────────┘    │  available"        │
                │                 └────────────────────┘
                ▼
    ┌───────────────────────┐
    │ Update Patient:       │
    │ • hasNextMeeting=true │
    │ • nextMeetingDate     │
    │ • nextMeetingDoctor   │
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │ Update Doctor:        │
    │ Add to schedule Map   │
    │ ["2025-11-02"]→[10:00]│
    └───────────┬───────────┘
                │
                ▼
         ┌─────────────┐
         │   Success   │
         └─────────────┘
```

## 2. Availability Check Algorithm

```
┌─────────────────────────────────────────────────────────────┐
│  isDoctorAvailable(doctor, requestedTime, durationMinutes)  │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │ Get Schedule Key        │
              │ "YYYY-MM-DD"            │
              └───────────┬─────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │ Get Doctor's Schedule   │
              │ for that date           │
              └───────────┬─────────────┘
                          │
                ┌─────────┴──────────┐
                │                    │
           Empty List           Has Appointments
                │                    │
                ▼                    ▼
         ┌────────────┐    ┌────────────────────┐
         │ Available  │    │ Check Each         │
         │ (return    │    │ Appointment for    │
         │  true)     │    │ Time Overlap       │
         └────────────┘    └─────────┬──────────┘
                                     │
                           ┌─────────┴──────────┐
                           │                    │
                      No Overlap           Has Overlap
                           │                    │
                           ▼                    ▼
                    ┌────────────┐      ┌──────────────┐
                    │ Available  │      │ Not Available│
                    │ (return    │      │ (return      │
                    │  true)     │      │  false)      │
                    └────────────┘      └──────────────┘

Overlap Check Logic:
┌──────────────────────────────────────────────────────┐
│ requestedStart < existingEnd  AND                    │
│ requestedEnd > existingStart                         │
│                                                      │
│ Example:                                             │
│ Requested: [10:00 -------- 10:30]                   │
│ Existing:        [10:15 -------- 10:45]             │
│ Result: TRUE (overlap) → Not Available              │
│                                                      │
│ Requested: [10:00 -------- 10:30]                   │
│ Existing:                           [11:00 -- 11:30]│
│ Result: FALSE (no overlap) → Available              │
└──────────────────────────────────────────────────────┘
```

## 3. Suggested Time Slots Generation

```
┌─────────────────────────────────────────────────────────┐
│ getSuggestedAvailableSlots(doctor, date, hours...)     │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ Set currentSlot = startHour  │
        │ (e.g., 9:00 AM)              │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ Loop until endHour           │◄───────┐
        │ (e.g., 5:00 PM)              │        │
        └──────────────┬───────────────┘        │
                       │                        │
                       ▼                        │
        ┌──────────────────────────────┐        │
        │ Is slot in future?           │── NO ──┤
        └──────────────┬───────────────┘        │
                       │ YES                    │
                       ▼                        │
        ┌──────────────────────────────┐        │
        │ Is doctor available?         │        │
        │ (check for conflicts)        │        │
        └──────────────┬───────────────┘        │
                       │                        │
            ┌──────────┴──────────┐             │
            │                     │             │
           YES                   NO             │
            │                     │             │
            ▼                     │             │
  ┌─────────────────┐             │             │
  │ Add to          │             │             │
  │ availableSlots  │             │             │
  └─────────┬───────┘             │             │
            │                     │             │
            └──────────┬──────────┘             │
                       │                        │
                       ▼                        │
        ┌──────────────────────────────┐        │
        │ Move to next slot            │        │
        │ (currentSlot + 30 minutes)   │────────┘
        └──────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ Return availableSlots list   │
        │ [9:00, 9:30, 10:00, 11:30...]│
        └──────────────────────────────┘

Example Output:
┌────────────────────────────────────────┐
│ Working Hours: 9 AM - 5 PM             │
│ Doctor has appointment at 10:00       │
│                                        │
│ Available Slots:                       │
│ ✓ 09:00                                │
│ ✓ 09:30                                │
│ ✗ 10:00 (busy)                         │
│ ✓ 10:30                                │
│ ✓ 11:00                                │
│ ✓ 11:30                                │
│ ... continues until 5:00 PM            │
└────────────────────────────────────────┘
```

## 4. Complete Scheduling Lifecycle

```
                    ┌─────────────────┐
                    │  Initial State  │
                    │ No Meeting      │
                    └────────┬────────┘
                             │
                             │ scheduleNextMeeting()
                             ▼
                    ┌─────────────────┐
                    │  Meeting        │
                    │  Scheduled      │
                    └────┬───────┬────┘
                         │       │
        rescheduleNextMeeting()  cancelNextMeeting()
                         │       │
                         │       ▼
                         │  ┌─────────────────┐
                         │  │  No Meeting     │◄──┐
                         │  └─────────────────┘   │
                         │                        │
                         ▼                        │
                    ┌─────────────────┐           │
                    │  New Meeting    │           │
                    │  Scheduled      │           │
                    └────────┬────────┘           │
                             │                    │
                             └────────────────────┘

Patient State Changes:
┌────────────────────────────────────────────────┐
│ Initial:                                       │
│ • hasNextMeeting = false                       │
│ • nextMeetingDate = null                       │
│ • nextMeetingDoctor = null                     │
└────────────────────────────────────────────────┘
                    │
                    │ scheduleNextMeeting()
                    ▼
┌────────────────────────────────────────────────┐
│ After Schedule:                                │
│ • hasNextMeeting = true                        │
│ • nextMeetingDate = DateTime(...)              │
│ • nextMeetingDoctor = Doctor(...)              │
└────────────────────────────────────────────────┘
                    │
                    │ cancelNextMeeting()
                    ▼
┌────────────────────────────────────────────────┐
│ After Cancel:                                  │
│ • hasNextMeeting = false                       │
│ • nextMeetingDate = null                       │
│ • nextMeetingDoctor = null                     │
└────────────────────────────────────────────────┘

Doctor Schedule Changes:
┌────────────────────────────────────────────────┐
│ Before: schedule = {}                          │
└────────────────────────────────────────────────┘
                    │
                    │ Patient schedules meeting
                    ▼
┌────────────────────────────────────────────────┐
│ After: schedule = {                            │
│   "2025-11-02": [DateTime(2025,11,2,10,0)]     │
│ }                                              │
└────────────────────────────────────────────────┘
                    │
                    │ Patient cancels meeting
                    ▼
┌────────────────────────────────────────────────┐
│ After Cancel: schedule = {                     │
│   "2025-11-02": []  // Empty list              │
│ }                                              │
└────────────────────────────────────────────────┘
```

## 5. Error Handling Flow

```
                    ┌─────────────────────────┐
                    │  Schedule Request       │
                    └───────────┬─────────────┘
                                │
                    ┌───────────▼──────────────┐
                    │ try {                    │
                    │   scheduleNextMeeting()  │
                    │ }                        │
                    └───────────┬──────────────┘
                                │
                    ┌───────────┴────────────┐
                    │                        │
                 Success                  Error
                    │                        │
                    ▼                        ▼
         ┌──────────────────┐    ┌─────────────────────────┐
         │ Meeting Created  │    │ catch(ArgumentError e)   │
         │ • Update Patient │    └────────────┬────────────┘
         │ • Update Doctor  │                 │
         └──────────────────┘                 │
                                              ▼
                                   ┌──────────────────────┐
                                   │ Check Error Type:    │
                                   └──────────┬───────────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
        ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
        │ "Doctor not      │     │ "Meeting date    │     │ "Doctor not      │
        │  assigned"       │     │  must be in      │     │  available"      │
        └────────┬─────────┘     │  future"         │     └────────┬─────────┘
                 │                └────────┬─────────┘              │
                 ▼                         ▼                        ▼
        ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
        │ Action: Call     │     │ Action: Choose   │     │ Action: Get      │
        │ assignDoctor()   │     │ future date      │     │ available slots  │
        └──────────────────┘     └──────────────────┘     └──────────────────┘
```

## 6. Data Relationships

```
                    Patient
        ┌────────────────────────────┐
        │ _hasNextMeeting: bool      │
        │ _nextMeetingDate: DateTime?│────────┐
        │ _nextMeetingDoctor: Doctor?│───────┐│
        │ _assignedDoctors: List     │──────┐││
        └────────────────────────────┘      │││
                                            │││
                ┌───────────────────────────┘││
                │  ┌─────────────────────────┘│
                │  │  ┌──────────────────────┘
                ▼  ▼  ▼
                Doctor
        ┌────────────────────────────┐
        │ _schedule: Map             │
        │   {                        │
        │     "2025-11-02": [        │
        │       DateTime(10:00),     │◄──── Meeting times
        │       DateTime(14:00)      │      stored here
        │     ],                     │
        │     "2025-11-03": [...]    │
        │   }                        │
        └────────────────────────────┘

Synchronization:
┌────────────────────────────────────────────────────┐
│ When patient.scheduleNextMeeting() is called:      │
│                                                    │
│ 1. Patient updated:                                │
│    • _hasNextMeeting = true                        │
│    • _nextMeetingDate = DateTime                   │
│    • _nextMeetingDoctor = Doctor reference         │
│                                                    │
│ 2. Doctor updated (automatically):                 │
│    • doctor._schedule["date"].add(DateTime)        │
│                                                    │
│ 3. Both remain synchronized:                       │
│    • Patient knows meeting details                 │
│    • Doctor knows time is occupied                 │
└────────────────────────────────────────────────────┘
```

These diagrams illustrate the complete workflow and logic of the meeting scheduling system!
