# Data Flow Diagram (DFD) — SmartRoutine (EdTE Scheduler)

## Project Context

SmartRoutine is a Flutter-based university schedule management application for the Department of Educational Technology and Engineering at the University of Frontier Technology, Bangladesh. It uses Supabase (PostgreSQL) as its cloud backend and Provider for state management.

---

## Level 0 — Context Diagram

The system has four external entities interacting with a single process (SmartRoutine System):

### External Entities
1. **Super Admin** — Full system control; manages all master data and schedules.
2. **Teacher Admin** — A teacher with elevated privileges to manage schedules and classes.
3. **Regular Teacher** — Views and manages their own class schedule.
4. **Student** — Views batch-specific schedules, free rooms, and personal profile.

### Single Process
- **SmartRoutine System** — The central application handling authentication, data management, schedule operations, and PDF export.

### Data Store
- **Supabase (PostgreSQL Cloud Database)** — Persistent storage for all entities.
- **SharedPreferences (Local Storage)** — Session persistence and caching on the device.

### Level 0 Data Flows

| Source | → | Destination | Data Description |
|---|---|---|---|
| Super Admin | → | SmartRoutine System | Login credentials, CRUD operations on batches/students/teachers/rooms/courses, timetable entries, import files (JSON/CSV) |
| SmartRoutine System | → | Super Admin | Dashboard analytics, timetable PDFs, confirmation messages, entity lists |
| Teacher Admin | → | SmartRoutine System | Login credentials, class cancellation/reschedule requests, room change requests |
| SmartRoutine System | → | Teacher Admin | Daily/weekly schedule, teacher lists, confirmation messages |
| Regular Teacher | → | SmartRoutine System | Login credentials, password change, profile updates |
| SmartRoutine System | → | Regular Teacher | Daily/weekly schedule, class details (course, batch, room, time), PDF downloads |
| Student | → | SmartRoutine System | Login credentials (email + password), password change |
| SmartRoutine System | → | Student | Daily/weekly batch schedule, free room list, room schedule, profile info |
| SmartRoutine System | ↔ | Supabase Database | All CRUD operations via Supabase Flutter SDK (REST API over HTTPS) |
| SmartRoutine System | ↔ | SharedPreferences | Session tokens (admin/teacher/student JSON), cached entity data |

---

## Level 1 — Major Process Decomposition

The single "SmartRoutine System" process from Level 0 breaks down into the following sub-processes:

### Process 1.0 — Authentication & Session Management
- **Input**: Username/email + password from any user role.
- **Processing**: Queries `admins`, `teachers`, or `students` table in Supabase. Compares credentials. On success, serializes user object to JSON and stores in SharedPreferences for session persistence.
- **Output**: Authenticated user object (Admin, Teacher, or Student). Redirects to appropriate portal screen.
- **Data Stores Used**: Supabase (`admins`, `teachers`, `students` tables), SharedPreferences (session cache).

### Process 2.0 — Master Data Management (Super Admin Only)
- **Input**: Super Admin CRUD requests for Batches, Courses, Rooms, Teachers, and Students.
- **Processing**: Validates input, calls SupabaseService methods (e.g., `addBatch()`, `updateTeacher()`, `deleteRoom()`). Each operation hits the corresponding Supabase table.
- **Output**: Updated entity lists, success/error messages.
- **Sub-flows**:
  - 2.1 Batch Management: `batches` table (name, session).
  - 2.2 Course Management: `courses` table (code, title).
  - 2.3 Room Management: `rooms` table (name).
  - 2.4 Teacher Management: `teachers` table (name, initial, designation, phone, email, department, profile_pic, password).
  - 2.5 Student Management: `students` table (student_id, name, batch_id, email, password).
  - 2.6 Credential Setting: Super Admin sets initial email + password for teachers and students. After user changes password, `has_changed_password` flag is set to true.

### Process 3.0 — Timetable Management
- **Input**: Schedule entry data (day, batch, teacher_initial, course_code, type, group, room, mode, start_time, end_time).
- **Processing**: DataRepository coordinates with SupabaseService. Validates foreign key references (batch exists, teacher initial valid, course code valid, room exists). Inserts or updates `timetable_entries` table.
- **Output**: Updated timetable views, confirmation.
- **Sub-flows**:
  - 3.1 Add/Edit Schedule Entry: Through `AddEditScheduleScreen`.
  - 3.2 Cancel Class: Sets `is_cancelled = true` and `cancellation_reason` on the entry.
  - 3.3 Reschedule Class: Updates day/time fields on the entry.
  - 3.4 Change Room: Updates `room_id` on the entry.

### Process 4.0 — Schedule Viewing
- **Input**: User role + identifier (batch_id for students, teacher_initial for teachers).
- **Processing**: Queries `timetable_entries` joined with `batches`, `teachers`, `courses`, `rooms` via Supabase views (`v_timetable_complete`). Filters by day, batch, or teacher.
- **Output**: Color-coded schedule cards showing course name, teacher, room, time, mode (Online/Onsite), cancellation status.
- **Sub-flows**:
  - 4.1 Daily Schedule: Filter by current day.
  - 4.2 Weekly Schedule: Group by day of week (Sun–Thu).
  - 4.3 Free Rooms: Calls `get_free_rooms()` PostgreSQL function — returns rooms not occupied at a given day/time.
  - 4.4 Room Schedule: Shows all classes in a specific room.

### Process 5.0 — Import/Export
- **Input**: JSON or CSV file uploads (import), export trigger from UI.
- **Processing**:
  - Import: `TimetableExportImport` utility parses uploaded file, maps to `TimetableEntry` objects, batch-inserts into Supabase.
  - Export: Collects all timetable data, generates PDF using `pdf` package, triggers download/share via `printing` package.
- **Output**: Imported schedule data or downloadable PDF file.
- **Data Stores Used**: Local filesystem (file_picker for import, path_provider for temp PDF), Supabase for data.

### Process 6.0 — Profile & Password Management
- **Input**: New password, profile updates.
- **Processing**: Updates `password` field and sets `has_changed_password = true` in `teachers` or `students` table. For teachers, profile picture upload goes to Supabase Storage bucket `teacher-profiles`.
- **Output**: Updated profile, confirmation message, session refresh.

---

## Level 2 — Detailed Data Flow for Authentication (Process 1.0)

### Process 1.1 — Admin Authentication
1. User enters username + password on `UnifiedLoginScreen`.
2. `SupabaseService.authenticateAdmin()` queries `admins` table: `SELECT * FROM admins WHERE username = ? AND password_hash = ?`.
3. If match found: Creates `Admin` object, saves to SharedPreferences as JSON, sets `_currentAdmin`, calls `notifyListeners()`.
4. `AuthCheck` widget (Consumer of SupabaseService) detects `currentAdmin != null`.
5. Routes to `SuperAdminPortalScreenNew` (if `type == 'super_admin'`) or `TeacherAdminPortalScreen` (if `type == 'teacher_admin'`).

### Process 1.2 — Student Authentication
1. User enters email + password on `UnifiedLoginScreen`.
2. `SupabaseService.authenticateStudent()` queries `students` table: `SELECT * FROM students WHERE email = ?`.
3. Compares stored password with input. If match: Creates `Student` object, saves session, sets `_currentStudent`.
4. Routes to `MainNavigationScreen` (student portal with bottom navigation).

### Process 1.3 — Teacher Authentication
1. User enters email + password on `UnifiedLoginScreen`.
2. `SupabaseService.authenticateTeacher()` queries `teachers` table by email.
3. Compares password. If match: Creates `Teacher` object, saves session.
4. Routes to `TeacherPortalScreen`.

### Process 1.4 — Session Restoration (App Restart)
1. On app start, `SupabaseService.initialize()` is called.
2. Reads SharedPreferences keys: `edte_current_admin`, `student_session`, `teacher_session`.
3. If any session JSON exists, deserializes into the corresponding model object.
4. `AuthCheck` widget renders the appropriate portal without requiring re-login.

---

## Data Flow Summary Table

| Process | Input Data | Output Data | Data Stores |
|---|---|---|---|
| 1.0 Authentication | Credentials | Session token, user object | Supabase, SharedPreferences |
| 2.0 Master Data Mgmt | Entity CRUD data | Updated lists, confirmations | Supabase (all entity tables) |
| 3.0 Timetable Mgmt | Schedule entries | Updated timetable | Supabase (timetable_entries) |
| 4.0 Schedule Viewing | Role + ID filters | Schedule cards, free rooms | Supabase (views, functions) |
| 5.0 Import/Export | JSON/CSV files | Imported data / PDF files | Supabase, Local filesystem |
| 6.0 Profile Mgmt | Password, profile data | Updated profile | Supabase (teachers/students), Storage |

---

## Technology Stack in Data Flow

| Layer | Technology | Role in Data Flow |
|---|---|---|
| Presentation | Flutter Widgets (Screens, Widgets) | User input collection, data display |
| State Management | Provider (ChangeNotifierProvider) | Reactive state propagation across widgets |
| Service Layer | SupabaseService (ChangeNotifier) | API calls, authentication, caching, session management |
| Repository Layer | DataRepository | Coordinates data loading, aggregates multiple service calls |
| Network | Supabase Flutter SDK (REST over HTTPS) | Client-server communication |
| Backend | Supabase (PostgreSQL + Storage + RLS) | Persistent data storage, SQL views, stored functions |
| Local Storage | SharedPreferences | Session persistence, offline caching |
| File I/O | file_picker, path_provider, pdf, printing | Import/export operations |
