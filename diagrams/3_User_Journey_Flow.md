# User Journey Flow — SmartRoutine (EdTE Scheduler)

## Project Context

SmartRoutine serves four distinct user roles. Each user enters through a unified login screen and is routed to their specific portal. This document traces every user journey from app launch to task completion.

---

## Entry Point: App Launch

1. App starts → `main()` initializes Supabase SDK with project URL and anon key.
2. `RoutineScrapperApp` widget builds MaterialApp with dark theme.
3. Home widget is `AuthCheck` — a stateful widget that:
   - Calls `SupabaseService.initialize()` (restores admin, student, and teacher sessions from SharedPreferences).
   - Shows loading spinner while initializing.
   - Once initialized, checks: Is there a saved session?
     - **Yes**: Automatically routes to the correct portal (no re-login needed).
     - **No**: Shows `UnifiedLoginScreen`.

---

## Journey 1: Super Admin

### 1.1 Login
- **Screen**: UnifiedLoginScreen
- **Action**: Enters username (e.g., superadmin@edte.com) and password.
- **Backend**: `SupabaseService.authenticateAdmin()` queries `admins` table.
- **Result**: On success → navigates to `SuperAdminPortalScreenNew`.

### 1.2 Dashboard (Home Tab)
- **Screen**: SuperAdminPortalScreenNew
- **What they see**: Analytics dashboard with cards showing:
  - Total batches count
  - Total students count
  - Total teachers count
  - Total scheduled classes count
  - Quick action buttons
- **Navigation**: Bottom navigation bar with tabs for different management areas.

### 1.3 Manage Batches
- **Screen**: ManageBatchesScreen
- **Actions available**:
  - View list of all batches (name + session).
  - Tap "Add Batch" → dialog to enter batch name and session → calls `SupabaseService.addBatch()`.
  - Tap a batch → Edit dialog → update name/session → calls `SupabaseService.updateBatch()`.
  - Swipe/delete a batch → confirmation → calls `SupabaseService.deleteBatch()` (cascades to students and timetable entries).
- **Data flow**: Changes immediately reflected in Supabase, UI refreshes via `notifyListeners()`.

### 1.4 Manage Students
- **Screen**: StudentScreen (within admin portal)
- **Actions available**:
  - View all students grouped by batch.
  - Add student: Enter student_id, name, select batch from dropdown, optional email/phone.
  - Set login credentials: Assign email + initial password for a student.
  - Edit student details.
  - Delete student.
- **Credential flow**: Admin sets email + password → student logs in → student changes password → `has_changed_password` = true → credentials locked (admin can see but not change).

### 1.5 Manage Teachers
- **Screen**: ManageTeachersScreen
- **Actions available**:
  - View all teachers with cards showing name, initial, designation, department.
  - Add teacher: Name, initial (unique), designation, phone, email, department.
  - Edit teacher profile.
  - Set teacher login credentials (email + password).
  - Delete teacher (cascades to their timetable entries).
  - Upload/change teacher profile picture (Supabase Storage).

### 1.6 Manage Rooms
- **Screen**: ManageRoomsScreen
- **Actions available**:
  - View all rooms (classrooms and labs).
  - Add room (name like "1001" or "2701 (LAB)").
  - Edit room name.
  - Delete room (sets timetable room_id to NULL).

### 1.7 Manage Timetable / Schedule
- **Screen**: AddEditScheduleScreen
- **Actions available**:
  - Create new schedule entry:
    1. Select day (Sun–Sat).
    2. Select batch (dropdown from batches table).
    3. Select teacher (dropdown showing initials).
    4. Select course (dropdown from courses table).
    5. Select type (Lecture/Tutorial/Sessional/Online).
    6. Optionally set group (G-1, G-2).
    7. Select room (dropdown, optional for online).
    8. Set mode (Onsite/Online).
    9. Set start time and end time.
  - Edit existing entry.
  - Cancel a class (set is_cancelled + reason).
  - Delete schedule entry.
- **Validation**: Checks for time conflicts within the same batch, teacher, or room.

### 1.8 Import Timetable
- **Utility**: TimetableExportImport
- **Actions available**:
  - Import from JSON file: Opens file picker → selects .json file → parses data → batch inserts into Supabase.
  - Import from CSV file: Opens file picker → selects .csv file → parses rows → maps to TimetableEntry → inserts.
- **Template files**: `assets/timetable_template.json` and `assets/timetable_template.csv` available as reference.

### 1.9 Export Timetable as PDF
- **Actions available**:
  - Export complete timetable: Generates a professional PDF with all batches' schedules.
  - Export per-batch: PDF for a specific batch.
  - Export per-teacher: PDF for a specific teacher's schedule.
- **Technology**: `pdf` package generates the document, `printing` package handles preview/download/share.

### 1.10 Logout
- **Action**: Tap logout → `SupabaseService.logout()` clears SharedPreferences (admin, student, teacher sessions) → clears cached data → navigates back to `UnifiedLoginScreen`.

---

## Journey 2: Teacher Admin

### 2.1 Login
- **Screen**: UnifiedLoginScreen
- **Action**: Enters teacher admin email + password.
- **Backend**: `SupabaseService.authenticateAdmin()` finds admin with `type = 'teacher_admin'`.
- **Result**: Navigates to `TeacherAdminPortalScreen` (receives DataRepository + Admin object).

### 2.2 Dashboard
- **Screen**: TeacherAdminPortalScreen
- **What they see**:
  - Their own daily class schedule (filtered by their `teacher_initial` from admin record).
  - Quick actions for schedule management.
  - Navigation to manage classes.

### 2.3 Schedule Management
- **Actions available**:
  - View their own teaching schedule (daily + weekly).
  - Cancel a class: Select entry → set is_cancelled = true → provide cancellation reason.
  - Reschedule a class: Select entry → change day/time → save.
  - Change room: Select entry → pick new room → save.
- **Limitation**: Cannot manage other teachers' schedules or master data (batches, courses, students).

### 2.4 View Teachers List
- **Screen**: TeacherScreen
- **Actions**: View all teachers and their schedules. Read-only for teacher admin.

### 2.5 Profile & Password
- **Screen**: TeacherProfileScreen
- **Actions**: View own profile, change password.
- **Flow**: Enter current password → enter new password → confirm → `SupabaseService.updateTeacherPassword()`.

### 2.6 Logout
- Same as Super Admin logout flow.

---

## Journey 3: Regular Teacher

### 3.1 Login
- **Screen**: UnifiedLoginScreen
- **Action**: Enters teacher email + password.
- **Backend**: `SupabaseService.authenticateTeacher()` queries `teachers` table by email.
- **Result**: Navigates to `TeacherPortalScreen`.

### 3.2 Daily Schedule
- **Screen**: TeacherPortalScreen (default view)
- **What they see**:
  - Today's classes listed chronologically.
  - Each card shows: course name, course code, batch name, room number, time slot, mode (Online/Onsite badge), cancellation status.
  - Color-coded cards (different colors for Online vs Onsite).

### 3.3 Weekly Schedule
- **Action**: Switch to weekly view tab.
- **What they see**: All classes for the week grouped by day (Sunday through Thursday, Friday is day off).

### 3.4 Class Details
- **Action**: Tap on a class card.
- **What they see**: Detailed view with course title, batch info, room location, timing, class type (Lecture/Tutorial/Sessional).

### 3.5 Profile Management
- **Screen**: TeacherProfileScreen
- **Actions**:
  - View profile (name, initial, designation, department, contact).
  - Change password.
  - Update profile picture (image_picker → Supabase Storage upload).

### 3.6 PDF Export
- **Action**: Export own schedule as PDF.
- **Result**: Professional PDF generated and available for download/share.

### 3.7 Logout
- Same flow as other roles.

---

## Journey 4: Student

### 4.1 Login
- **Screen**: UnifiedLoginScreen
- **Action**: Enters student email + password (set initially by Super Admin).
- **Backend**: `SupabaseService.authenticateStudent()` queries `students` table by email, compares password.
- **Result**: Navigates to `MainNavigationScreen` (bottom navigation with multiple tabs).

### 4.2 First-time Password Change
- If logging in with admin-set credentials:
  - Prompted to change password on first login.
  - After change: `has_changed_password = true` → credentials locked from admin modification.

### 4.3 Daily Schedule (Home Tab)
- **Screen**: StudentPortalScreen
- **What they see**:
  - Today's classes for their batch.
  - Cards showing course name, teacher name/initial, room, time, mode.
  - Cancelled classes shown with visual indicator + reason.

### 4.4 Weekly Schedule
- **Action**: Switch to weekly view.
- **What they see**: Full week schedule grouped by day, filtered by batch_id.

### 4.5 Room Information
- **Screen**: RoomScreen
- **Actions**:
  - View list of all rooms.
  - Tap a room → see all classes scheduled in that room for the week.
  - Identify room types (classroom vs lab).

### 4.6 Free Rooms
- **Screen**: FreeRoomsScreen
- **Actions**:
  - Select a day and time.
  - System calls `get_free_rooms()` PostgreSQL function.
  - Shows list of all rooms that are NOT occupied at that day/time.
  - Useful for finding available study spaces or alternative rooms.

### 4.7 Student Profile
- **Screen**: StudentProfileScreen
- **What they see**: Name, student ID, batch name, email.
- **Actions**: Change password.

### 4.8 Bottom Navigation Tabs
The student portal uses `MainNavigationScreen` with bottom navigation:
1. **Schedule** — Daily class schedule
2. **Rooms** — Room information and schedules
3. **Free Rooms** — Find available rooms
4. **Profile** — Student profile and settings

### 4.9 Logout
- Same flow as other roles.

---

## Cross-Cutting Journeys

### Session Persistence Flow
1. User logs in successfully.
2. User object serialized to JSON → stored in SharedPreferences.
3. User closes app.
4. User re-opens app → `AuthCheck` widget triggers → `SupabaseService.initialize()` reads SharedPreferences.
5. Session JSON found → deserialized → user automatically routed to their portal.
6. No re-login required unless user explicitly logs out.

### Password Change Flow (All Roles)
1. User navigates to profile screen.
2. Enters current password for verification.
3. Enters new password + confirmation.
4. Backend updates password in respective table.
5. `has_changed_password` flag set to true (teachers and students).
6. Session refreshed with updated credentials.
7. For students/teachers: Admin can no longer modify their credentials.

### Error Handling Flow
1. Network error → Catch block in SupabaseService → Error message shown via SnackBar.
2. Invalid credentials → `null` returned from auth method → "Invalid credentials" message displayed.
3. Duplicate data (e.g., duplicate batch name+session) → Supabase UNIQUE constraint violation → Error caught → User-friendly message shown.

---

## Screen Navigation Map

```
App Launch
  └─→ AuthCheck
       ├─→ [Has Session] → Route to saved role's portal
       └─→ [No Session] → UnifiedLoginScreen
            ├─→ [Super Admin Login] → SuperAdminPortalScreenNew
            │    ├─→ Dashboard (analytics)
            │    ├─→ ManageBatchesScreen
            │    ├─→ StudentScreen (manage students)
            │    ├─→ ManageTeachersScreen
            │    ├─→ ManageRoomsScreen
            │    ├─→ AddEditScheduleScreen
            │    ├─→ Import/Export (TimetableExportImport utility)
            │    └─→ Logout → UnifiedLoginScreen
            ├─→ [Teacher Admin Login] → TeacherAdminPortalScreen
            │    ├─→ Dashboard (own schedule)
            │    ├─→ Schedule Management (cancel/reschedule/room change)
            │    ├─→ TeacherScreen (view all teachers)
            │    ├─→ TeacherProfileScreen
            │    └─→ Logout → UnifiedLoginScreen
            ├─→ [Teacher Login] → TeacherPortalScreen
            │    ├─→ Daily Schedule
            │    ├─→ Weekly Schedule
            │    ├─→ TeacherProfileScreen
            │    ├─→ PDF Export
            │    └─→ Logout → UnifiedLoginScreen
            └─→ [Student Login] → MainNavigationScreen
                 ├─→ StudentPortalScreen (daily/weekly schedule)
                 ├─→ RoomScreen (room info)
                 ├─→ FreeRoomsScreen (find available rooms)
                 ├─→ StudentProfileScreen
                 └─→ Logout → UnifiedLoginScreen
```

---

## User Role Permission Matrix

| Feature | Super Admin | Teacher Admin | Regular Teacher | Student |
|---|---|---|---|---|
| View Dashboard Analytics | Yes | Own stats | No | No |
| Manage Batches (CRUD) | Yes | No | No | No |
| Manage Students (CRUD) | Yes | No | No | No |
| Manage Teachers (CRUD) | Yes | No | No | No |
| Manage Rooms (CRUD) | Yes | No | No | No |
| Manage Courses (CRUD) | Yes | No | No | No |
| Create Schedule Entry | Yes | No | No | No |
| Edit Schedule Entry | Yes | Own classes | No | No |
| Cancel Class | Yes | Own classes | No | No |
| Reschedule Class | Yes | Own classes | No | No |
| Change Room | Yes | Own classes | No | No |
| View Daily Schedule | All batches | Own schedule | Own schedule | Own batch |
| View Weekly Schedule | All batches | Own schedule | Own schedule | Own batch |
| View Free Rooms | Yes | Yes | Yes | Yes |
| View Room Schedules | Yes | Yes | Yes | Yes |
| Import Timetable (JSON/CSV) | Yes | No | No | No |
| Export Timetable (PDF) | Yes (all) | Own schedule | Own schedule | No |
| Set Student Credentials | Yes | No | No | No |
| Set Teacher Credentials | Yes | No | No | No |
| Change Own Password | Yes | Yes | Yes | Yes |
| Upload Profile Picture | No | Yes | Yes | No |
| View All Teachers | Yes | Yes (read-only) | No | No |
