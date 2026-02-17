# Entity Relationship Diagram (ERD) — SmartRoutine (EdTE Scheduler)

## Project Context

SmartRoutine uses Supabase (PostgreSQL) as its backend database. The schema consists of 8 tables with defined relationships, constraints, and indexes. UUID is used as the primary key type across all tables.

---

## Entities and Their Attributes

### 1. ADMINS
Stores administrator accounts for system access control.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated (uuid_generate_v4) | Unique identifier |
| username | TEXT | UNIQUE, NOT NULL | Login email/username |
| password_hash | TEXT | NOT NULL | Stored password (plain text in demo, should be hashed in production) |
| type | TEXT | NOT NULL, CHECK IN ('super_admin', 'teacher_admin') | Role type |
| teacher_initial | TEXT | NULLABLE | Links teacher_admin to a teacher; NULL for super_admin |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW(), auto-updated via trigger | Last modification timestamp |

**Indexes**: `idx_admins_username` (username), `idx_admins_type` (type)

---

### 2. TEACHERS
Stores faculty member profiles and credentials.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated | Unique identifier |
| name | TEXT | NOT NULL | Full name of the teacher |
| initial | TEXT | UNIQUE, NOT NULL | Short identifier (e.g., "AZ", "FK") used as foreign key reference |
| designation | TEXT | NOT NULL | Academic title (Professor, Associate Professor, etc.) |
| phone | TEXT | NULLABLE | Contact phone number |
| email | TEXT | NULLABLE | Email address |
| home_department | TEXT | NOT NULL | Department affiliation (CSE, EEE, etc.) |
| profile_pic | TEXT | NULLABLE | URL to profile picture in Supabase Storage |
| password | TEXT | NULLABLE | Login password (set by admin, changed by teacher) |
| has_changed_password | BOOLEAN | DEFAULT FALSE | Flag indicating if teacher has changed their initial password |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW(), auto-updated via trigger | Last modification timestamp |

**Indexes**: `idx_teachers_initial` (initial), `idx_teachers_department` (home_department)

---

### 3. BATCHES
Represents student groups/sections for a given academic session.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated | Unique identifier |
| name | TEXT | NOT NULL | Batch name (e.g., "CSE-A", "EEE-A") |
| session | TEXT | NOT NULL | Academic session (e.g., "2023-2024") |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW(), auto-updated via trigger | Last modification timestamp |

**Unique Constraint**: UNIQUE(name, session) — no duplicate batch names within the same session.
**Indexes**: `idx_batches_session` (session)

---

### 4. COURSES
Stores the academic course catalog.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated | Unique identifier |
| code | TEXT | UNIQUE, NOT NULL | Course code (e.g., "CSE101", "MATH101") |
| title | TEXT | NOT NULL | Full course name |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW(), auto-updated via trigger | Last modification timestamp |

**Indexes**: `idx_courses_code` (code)

---

### 5. ROOMS
Stores classroom and lab information.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated | Unique identifier |
| name | TEXT | UNIQUE, NOT NULL | Room identifier (e.g., "1001", "2701 (LAB)") |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW(), auto-updated via trigger | Last modification timestamp |

**Indexes**: `idx_rooms_name` (name)

---

### 6. STUDENTS
Stores student records with authentication credentials.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated | Unique identifier |
| student_id | TEXT | UNIQUE, NOT NULL | University roll/registration number |
| name | TEXT | NOT NULL | Full student name |
| batch_id | UUID | NOT NULL, FOREIGN KEY → batches(id) ON DELETE CASCADE | Linked batch |
| email | TEXT | NULLABLE | Login email (set by admin) |
| phone | TEXT | NULLABLE | Contact phone |
| password | TEXT | NULLABLE | Login password |
| has_changed_password | BOOLEAN | DEFAULT FALSE | Flag for credential lock after password change |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW(), auto-updated via trigger | Last modification timestamp |

**Indexes**: `idx_students_batch` (batch_id), `idx_students_student_id` (student_id)

---

### 7. TIMETABLE_ENTRIES
The core scheduling entity — stores each individual class slot.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated | Unique identifier |
| day | TEXT | NOT NULL, CHECK IN ('Sun','Mon','Tue','Wed','Thu','Fri','Sat') | Day of week |
| batch_id | UUID | NOT NULL, FOREIGN KEY → batches(id) ON DELETE CASCADE | Which batch this class is for |
| teacher_initial | TEXT | NOT NULL, FOREIGN KEY → teachers(initial) ON DELETE CASCADE | Which teacher teaches |
| course_code | TEXT | NOT NULL, FOREIGN KEY → courses(code) ON DELETE CASCADE | Which course is taught |
| type | TEXT | NOT NULL, CHECK IN ('Lecture','Tutorial','Sessional','Online') | Class type |
| group_name | TEXT | NULLABLE | Sub-group (e.g., "G-1", "G-2") for sessionals |
| room_id | UUID | NULLABLE, FOREIGN KEY → rooms(id) ON DELETE SET NULL | Assigned room (NULL for online) |
| mode | TEXT | NOT NULL, CHECK IN ('Onsite', 'Online') | Delivery mode |
| start_time | TIME | NOT NULL | Class start time |
| end_time | TIME | NOT NULL | Class end time |
| is_cancelled | BOOLEAN | DEFAULT FALSE | Whether class is cancelled |
| cancellation_reason | TEXT | NULLABLE | Reason text if cancelled |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW(), auto-updated via trigger | Last modification timestamp |

**Indexes**: `idx_timetable_day`, `idx_timetable_batch`, `idx_timetable_teacher`, `idx_timetable_course`, `idx_timetable_room`

---

### 8. APP_METADATA
Application-level settings and versioning.

| Attribute | Data Type | Constraints | Description |
|---|---|---|---|
| **id** | UUID | PRIMARY KEY, auto-generated | Unique identifier |
| version | TEXT | NOT NULL | Application version (e.g., "1.0.0") |
| last_updated | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |
| institution_name | TEXT | NULLABLE | Name of the institution |
| academic_year | TEXT | NULLABLE | Current academic year |

---

## Relationships

### 1. Students → Batches (Many-to-One)
- **Cardinality**: Many students belong to one batch.
- **Foreign Key**: `students.batch_id` → `batches.id`
- **On Delete**: CASCADE — deleting a batch removes all its students.
- **Notation**: Students (M) ——— (1) Batches

### 2. Timetable_Entries → Batches (Many-to-One)
- **Cardinality**: Many timetable entries exist for one batch.
- **Foreign Key**: `timetable_entries.batch_id` → `batches.id`
- **On Delete**: CASCADE — deleting a batch removes all its schedule entries.
- **Notation**: Timetable_Entries (M) ——— (1) Batches

### 3. Timetable_Entries → Teachers (Many-to-One)
- **Cardinality**: Many timetable entries reference one teacher.
- **Foreign Key**: `timetable_entries.teacher_initial` → `teachers.initial`
- **On Delete**: CASCADE — deleting a teacher removes all their schedule entries.
- **Notation**: Timetable_Entries (M) ——— (1) Teachers

### 4. Timetable_Entries → Courses (Many-to-One)
- **Cardinality**: Many timetable entries reference one course.
- **Foreign Key**: `timetable_entries.course_code` → `courses.code`
- **On Delete**: CASCADE — deleting a course removes all related schedule entries.
- **Notation**: Timetable_Entries (M) ——— (1) Courses

### 5. Timetable_Entries → Rooms (Many-to-One, Optional)
- **Cardinality**: Many timetable entries may reference one room. Room is NULLABLE (online classes have no room).
- **Foreign Key**: `timetable_entries.room_id` → `rooms.id`
- **On Delete**: SET NULL — deleting a room sets timetable room_id to NULL.
- **Notation**: Timetable_Entries (M) ——— (0..1) Rooms

### 6. Admins → Teachers (Implicit Link)
- **Cardinality**: A teacher_admin record links to a teacher via `teacher_initial`.
- **No formal FK constraint** in schema, but logically: `admins.teacher_initial` should match `teachers.initial`.
- **Notation**: Admins (0..1) - - - (1) Teachers (for teacher_admin type only)

---

## Relationship Summary Matrix

| Entity A | Relationship | Entity B | FK Column | Cardinality | Delete Rule |
|---|---|---|---|---|---|
| Students | belongs to | Batches | students.batch_id | M : 1 | CASCADE |
| Timetable_Entries | scheduled for | Batches | timetable_entries.batch_id | M : 1 | CASCADE |
| Timetable_Entries | taught by | Teachers | timetable_entries.teacher_initial | M : 1 | CASCADE |
| Timetable_Entries | covers | Courses | timetable_entries.course_code | M : 1 | CASCADE |
| Timetable_Entries | held in | Rooms | timetable_entries.room_id | M : 0..1 | SET NULL |
| Admins (teacher_admin) | linked to | Teachers | admins.teacher_initial | 0..1 : 1 | (no FK) |

---

## Database Views (Virtual Entities)

### v_timetable_complete
A denormalized view joining timetable_entries with all related entities for easy querying:
- Joins: `timetable_entries` + `batches` + `teachers` + `courses` + LEFT JOIN `rooms`
- Returns: All timetable fields + batch_name, batch_session, teacher_name, teacher_designation, course_title, room_name

### v_students_with_batch
A view joining students with their batch information:
- Joins: `students` + `batches`
- Returns: Student details + batch_name, batch_session

---

## Stored Functions

### get_teacher_schedule(teacher_initial, day)
Returns all classes for a given teacher on a given day. Joins timetable_entries → courses, batches, rooms.

### get_batch_schedule(batch_id, day)
Returns all classes for a given batch on a given day. Joins timetable_entries → courses, teachers, rooms.

### get_free_rooms(day, time)
Returns all rooms NOT occupied at a specific day and time. Excludes rooms with active (non-cancelled) entries overlapping the given time.

---

## Database Triggers

All tables (except app_metadata) have an `BEFORE UPDATE` trigger that automatically sets `updated_at = NOW()` whenever a row is modified, using the shared `update_updated_at_column()` function.

---

## Row Level Security (RLS)

RLS is enabled on all 8 tables. Current policies allow all operations for any user (development/demo mode). In production, these should be restricted by role:
- Super Admin: Full CRUD on all tables
- Teacher Admin: Read/update on timetable_entries, read on other tables
- Teachers: Read-only on schedule-related tables, update own profile
- Students: Read-only on schedules, update own password

---

## Supabase Storage

### Bucket: teacher-profiles
- **Purpose**: Stores teacher profile pictures.
- **Access Policies**:
  - Insert: Authenticated users
  - Select: Public (anyone can view)
  - Update: Authenticated users
  - Delete: Authenticated users

---

## Dart Model Mapping

| Database Table | Dart Model Class | File |
|---|---|---|
| admins | `Admin` | lib/models/admin.dart |
| teachers | `Teacher` | lib/models/teacher.dart |
| batches | `Batch` | lib/models/batch.dart |
| courses | `Course` | lib/models/course.dart |
| rooms | `Room` | lib/models/room.dart |
| students | `Student` | lib/models/student.dart |
| timetable_entries | `TimetableEntry` | lib/models/timetable_entry.dart |
| app_metadata | `AppMeta` | lib/models/app_meta.dart |
| (aggregate) | `AppData` | lib/models/app_data.dart |
