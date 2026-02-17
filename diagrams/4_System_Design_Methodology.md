# System Design Methodology — SmartRoutine (EdTE Scheduler)

## Project Context

SmartRoutine is a university schedule management application built with Flutter (Dart) for the frontend and Supabase (PostgreSQL) for the backend. This document covers the architectural decisions, design patterns, development methodology, and system design rationale.

---

## 1. Development Methodology: Agile with Iterative Prototyping

### Approach Used
The project follows an **iterative incremental development** model:
- **Phase 1**: Core data models and Supabase schema design.
- **Phase 2**: Authentication and role-based routing.
- **Phase 3**: Admin CRUD operations (batches, courses, rooms, teachers, students).
- **Phase 4**: Timetable management (create, edit, cancel, reschedule).
- **Phase 5**: Student and teacher portals (view schedules, free rooms).
- **Phase 6**: Import/export functionality (JSON, CSV, PDF).
- **Phase 7**: Session persistence, credential management, profile features.
- **Phase 8**: UI/UX polish (Material Design 3, dark theme, animations).

### Why Iterative
- Allows early feedback from stakeholders (university department).
- Each phase produces a working increment that can be tested.
- New requirements (e.g., credential locking, unified login) can be incorporated in later iterations.

---

## 2. System Architecture: Three-Tier Client-Server

### Architecture Diagram Description

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION TIER                      │
│              (Flutter Mobile Application)                │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Screens (UI Layer)                              │   │
│  │  - UnifiedLoginScreen                            │   │
│  │  - SuperAdminPortalScreen                        │   │
│  │  - TeacherAdminPortalScreen                      │   │
│  │  - TeacherPortalScreen                           │   │
│  │  - MainNavigationScreen (Student)                │   │
│  │  - ManageBatchesScreen, ManageRoomsScreen, etc.  │   │
│  └──────────────┬───────────────────────────────────┘   │
│                 │ uses                                    │
│  ┌──────────────▼───────────────────────────────────┐   │
│  │  Widgets (Reusable Components)                   │   │
│  │  - ScheduleCard, GradientShell, OnlineBadge      │   │
│  │  - CustomDropdown, CustomInputField, BrandCard   │   │
│  │  - TeacherCard, ScheduleList, SearchBar          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                   APPLICATION TIER                       │
│             (Business Logic & State Layer)                │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  State Management (Provider)                     │   │
│  │  - ChangeNotifierProvider<SupabaseService>       │   │
│  │  - Consumer widgets react to state changes       │   │
│  └──────────────┬───────────────────────────────────┘   │
│                 │                                        │
│  ┌──────────────▼───────────────────────────────────┐   │
│  │  SupabaseService (Service Layer)                 │   │
│  │  - Authentication (admin, teacher, student)      │   │
│  │  - CRUD for all entities                         │   │
│  │  - Session management (SharedPreferences)        │   │
│  │  - Data caching in memory                        │   │
│  │  - File upload (Supabase Storage)                │   │
│  └──────────────┬───────────────────────────────────┘   │
│                 │                                        │
│  ┌──────────────▼───────────────────────────────────┐   │
│  │  DataRepository (Repository Layer)               │   │
│  │  - Aggregates data from SupabaseService          │   │
│  │  - Parallel loading of all entity types          │   │
│  │  - Provides unified AppData object               │   │
│  │  - Entry ID mapping for updates                  │   │
│  └──────────────┬───────────────────────────────────┘   │
│                 │                                        │
│  ┌──────────────▼───────────────────────────────────┐   │
│  │  Utilities                                       │   │
│  │  - DateUtils (day/time formatting)               │   │
│  │  - TimetableExportImport (JSON/CSV/PDF)          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Models (Data Transfer Objects)                  │   │
│  │  - Admin, Teacher, Student, Batch                │   │
│  │  - Course, Room, TimetableEntry                  │   │
│  │  - AppData (aggregate), AppMeta (config)         │   │
│  │  - fromJson() / toJson() serialization           │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                     DATA TIER                            │
│              (Supabase Cloud Backend)                    │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PostgreSQL Database                             │   │
│  │  - 8 tables with RLS policies                    │   │
│  │  - UUID primary keys                             │   │
│  │  - Foreign key constraints with CASCADE/SET NULL  │   │
│  │  - Views (v_timetable_complete, v_students...)   │   │
│  │  - Stored functions (get_free_rooms, etc.)       │   │
│  │  - Triggers (updated_at auto-update)             │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Supabase Storage                                │   │
│  │  - Bucket: teacher-profiles (profile pictures)   │   │
│  │  - Public read, authenticated write              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Supabase REST API (auto-generated PostgREST)    │   │
│  │  - HTTPS communication                           │   │
│  │  - Anon key authentication                       │   │
│  │  - Row Level Security enforcement                │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                  LOCAL STORAGE                           │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  SharedPreferences                               │   │
│  │  - Admin session (edte_current_admin)            │   │
│  │  - Student session (student_session)             │   │
│  │  - Teacher session (teacher_session)             │   │
│  │  - Key-value JSON serialization                  │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Design Patterns Used

### 3.1 Provider Pattern (State Management)
- **What**: `SupabaseService` extends `ChangeNotifier` and is provided at the root of the widget tree via `ChangeNotifierProvider`.
- **Why**: Reactive state management — when data changes (login, CRUD), calling `notifyListeners()` automatically rebuilds dependent widgets using `Consumer<SupabaseService>`.
- **Where**: `main.dart` → `ChangeNotifierProvider(create: (_) => SupabaseService())`.
- **Benefit**: Decouples UI from business logic. Screens don't need to manage their own API calls.

### 3.2 Repository Pattern
- **What**: `DataRepository` acts as an intermediary between the UI and `SupabaseService`.
- **Why**: Aggregates multiple data sources into a single `AppData` object. Handles parallel loading. Manages cache invalidation.
- **Where**: `DataRepository` wraps `SupabaseService`, used in admin portal screens.
- **Benefit**: Single point of data access. Easy to swap backend (e.g., from local JSON to Supabase migration).

### 3.3 Service Layer Pattern
- **What**: `SupabaseService` encapsulates all Supabase API interactions.
- **Why**: Isolates external API dependency. All network calls go through one class.
- **Methods**: `authenticateAdmin()`, `getTeachers()`, `addBatch()`, `deleteTimetableEntry()`, etc.
- **Benefit**: If Supabase API changes or backend is swapped, only SupabaseService needs modification.

### 3.4 Factory Pattern (Model Deserialization)
- **What**: Every model class (Admin, Teacher, Student, etc.) has a `factory fromJson(Map<String, dynamic>)` constructor.
- **Why**: Standardizes JSON-to-Dart-object conversion. Handles null safety and default values.
- **Complement**: Every model also has a `toJson()` method for serialization back to JSON.

### 3.5 Observer Pattern (inherent in Provider)
- **What**: Widgets using `Consumer<SupabaseService>` are automatically rebuilt when `notifyListeners()` is called.
- **Where**: `AuthCheck` uses `Consumer` to detect login state changes and route accordingly.

### 3.6 Composition over Inheritance (Widget Design)
- **What**: Reusable widgets (`ScheduleCard`, `GradientShell`, `OnlineBadge`, `CustomDropdown`) are composed together rather than inheriting from complex base classes.
- **Why**: Flutter's widget model naturally favors composition. Each widget has a single responsibility.

---

## 4. Architectural Decisions and Rationale

### 4.1 Why Flutter?
| Factor | Decision |
|---|---|
| Cross-platform | Single codebase for Android, iOS, and Web |
| Performance | Compiled to native ARM code, no JavaScript bridge |
| UI Toolkit | Rich Material Design 3 components |
| Developer Experience | Hot reload for fast iteration |
| University Requirement | Mobile-first with possibility of web deployment |

### 4.2 Why Supabase over Firebase?
| Factor | Supabase | Firebase |
|---|---|---|
| Database | PostgreSQL (relational, SQL) | Firestore (NoSQL, document) |
| Data Relationships | Native FK constraints, JOINs | Manual denormalization |
| Querying | Full SQL, views, stored functions | Limited query operators |
| Schema for this app | Highly relational (batch→student, entry→batch+teacher+course+room) | Would require complex denormalization |
| Open Source | Yes | No |
| Cost | Generous free tier | Pay-as-you-go |

### 4.3 Why Provider over Riverpod/BLoC?
| Factor | Decision |
|---|---|
| Simplicity | Provider is simpler for this app's complexity level |
| Learning Curve | Lower than BLoC |
| Integration | Direct ChangeNotifier integration |
| Project Size | Medium-sized app doesn't need BLoC's formality |
| State Requirements | Mostly reactive data display, not complex state transitions |

### 4.4 Why SharedPreferences for Sessions?
| Factor | Decision |
|---|---|
| Simplicity | Key-value storage is sufficient for session tokens |
| Platform Support | Works on Android, iOS, and Web |
| No Encryption Needed (Demo) | In production, use flutter_secure_storage |
| Speed | Synchronous read after initial load |

### 4.5 Why UUID Primary Keys?
| Factor | Decision |
|---|---|
| Distributed Generation | No need for auto-increment sequences |
| Security | Non-guessable IDs |
| Supabase Default | Native `uuid_generate_v4()` support |
| Client-side Generation | Can generate IDs before insert if needed |

---

## 5. Data Modeling Methodology

### Normalization Level: Third Normal Form (3NF)
- All tables are in 3NF.
- No repeating groups (1NF).
- No partial dependencies (2NF) — all non-key attributes depend on the entire primary key.
- No transitive dependencies (3NF) — e.g., `teacher_name` is not stored in `timetable_entries`; only `teacher_initial` (FK) is stored.

### Natural Keys vs Surrogate Keys
- **Primary Keys**: UUID (surrogate) for all tables.
- **Natural Keys as FKs**: `teacher_initial` and `course_code` are used as foreign keys in `timetable_entries` instead of UUIDs. This is a deliberate design choice for:
  - Readability in queries and CSV imports.
  - Teacher initials and course codes are immutable business identifiers.
  - Simpler import/export (CSV can reference "AZ" instead of a UUID).

### Referential Integrity Strategy
| Parent | Child | On Delete |
|---|---|---|
| batches | students | CASCADE (remove students if batch deleted) |
| batches | timetable_entries | CASCADE (remove schedule if batch deleted) |
| teachers | timetable_entries | CASCADE (remove schedule if teacher deleted) |
| courses | timetable_entries | CASCADE (remove schedule if course deleted) |
| rooms | timetable_entries | SET NULL (keep schedule, set room to null) |

---

## 6. Security Design

### Authentication Model
- Application-level authentication (not Supabase Auth).
- Credentials stored in application tables (admins, teachers, students).
- Password comparison done in Dart after fetching user record.
- No JWT tokens — session managed via SharedPreferences.

### Role-Based Access Control (RBAC)
- Four roles: super_admin, teacher_admin, teacher, student.
- Access control enforced at the UI layer (different screens per role).
- Database-level RLS policies exist but are currently permissive (allow all for demo).
- Production recommendation: Implement proper RLS policies per role.

### Credential Lifecycle
```
Admin sets credentials → User receives email + initial password
→ User logs in first time → Prompted to change password
→ User changes password → has_changed_password = true
→ Credentials locked (admin sees flag, cannot modify)
```

### Security Improvements for Production
1. Use bcrypt/argon2 for password hashing (currently plain text).
2. Implement Supabase Auth for proper JWT-based authentication.
3. Restrict RLS policies per role.
4. Use flutter_secure_storage instead of SharedPreferences.
5. Add rate limiting on login attempts.
6. Implement email verification flow.

---

## 7. UI/UX Design Methodology

### Design System: Material Design 3
- Dark theme with custom color scheme.
- Primary: #5B7CFF (blue-purple), Secondary: #8A5BFF (purple).
- Surface: #1E1E1E (dark gray), Background: #121212 (near black).
- Typography: Google Fonts Poppins throughout.

### Component Architecture
| Component | Purpose | Reusability |
|---|---|---|
| GradientShell | Scaffold wrapper with gradient background | Used in all portal screens |
| ScheduleCard | Displays a single class entry with color coding | Used in student, teacher, admin views |
| OnlineBadge | Visual indicator for Online/Onsite mode | Used on schedule cards |
| CustomDropdown | Styled dropdown with search capability | Used in all forms |
| CustomInputField | Themed text input with validation | Used in all forms |
| BrandCard | Styled card with branding elements | Used on login/landing screens |
| TeacherCard | Teacher info display card | Used in teacher list views |
| ScheduleList | Scrollable list of ScheduleCards | Used in schedule views |
| AnimatedIllustration | Subtle animations for empty states | Used in empty list views |

### Navigation Design
- **Super Admin**: Tab-based navigation within portal screen.
- **Teacher Admin**: Tab-based navigation with limited tabs.
- **Teacher**: Single screen with daily/weekly toggle.
- **Student**: Bottom navigation bar (4 tabs: Schedule, Rooms, Free Rooms, Profile).

### Responsive Design
- Card-based layouts that adapt to screen width.
- `MediaQuery` used for responsive sizing.
- Works on phones (360px+) and tablets (600px+).

---

## 8. Communication Protocol

### Client-Server Communication
```
Flutter App ←→ Supabase REST API (PostgREST)
              ↕
         HTTPS / TLS
              ↕
    Supabase Cloud (PostgreSQL)
```

### Request Flow
1. Flutter widget triggers action (button tap, form submit).
2. Calls SupabaseService method.
3. SupabaseService uses `_client.from('table').select()/insert()/update()/delete()`.
4. Supabase Flutter SDK serializes to HTTP request.
5. Request sent to Supabase REST API endpoint with anon key in header.
6. PostgREST translates to SQL query.
7. PostgreSQL executes query, returns result.
8. Response JSON sent back to client.
9. SupabaseService deserializes JSON to Dart model objects.
10. `notifyListeners()` triggers UI rebuild.

### Caching Strategy
- **In-memory cache**: `SupabaseService` maintains `_cachedTeachers`, `_cachedBatches`, `_cachedCourses`, `_cachedRooms`, `_cachedStudents`.
- **Cache invalidation**: `forceRefresh: true` parameter bypasses cache and fetches fresh data.
- **Session cache**: SharedPreferences stores serialized user objects for session persistence.
- **No offline database**: Currently relies on in-memory cache only; no SQLite or Hive.

---

## 9. Deployment Architecture

### Current Deployment
```
┌──────────────┐        ┌─────────────────────┐
│   Android    │  HTTPS │  Supabase Cloud     │
│   Device     │◄──────►│  (supabase.co)      │
│   (APK)      │        │                     │
│              │        │  ┌───────────────┐  │
│  Flutter App │        │  │  PostgreSQL   │  │
│  + Provider  │        │  │  Database     │  │
│  + SharedPref│        │  └───────────────┘  │
│              │        │  ┌───────────────┐  │
│              │        │  │  Storage      │  │
│              │        │  │  (Profiles)   │  │
│              │        │  └───────────────┘  │
│              │        │  ┌───────────────┐  │
│              │        │  │  REST API     │  │
│              │        │  │  (PostgREST)  │  │
│              │        │  └───────────────┘  │
└──────────────┘        └─────────────────────┘
```

### Build Process
```
Source Code (Dart)
  → flutter build apk --release
  → Android APK (installable)
  → Distribution (sideload or Play Store)
```

### Environment Configuration
- Supabase URL and anon key are hardcoded in `main.dart`.
- Production recommendation: Use environment variables or `--dart-define`.
- Timezone: Asia/Dhaka (UTC+6).
- Days off: Friday (configured in AppMeta).
- Time slots: 6 slots from 08:00 to 17:00, 90 minutes each.

---

## 10. Technology Stack Summary

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| Language | Dart | 3.8.1+ | Primary programming language |
| Framework | Flutter | 3.8.1+ | Cross-platform UI framework |
| Backend | Supabase | Cloud | PostgreSQL + REST API + Storage |
| State Mgmt | Provider | 6.1.1 | Reactive state management |
| Database | PostgreSQL | (Supabase managed) | Relational data storage |
| Local Storage | SharedPreferences | 2.3.2 | Session persistence |
| HTTP Client | supabase_flutter | 2.9.0 | Supabase SDK for Dart |
| PDF | pdf + printing | 3.11.1 / 5.13.2 | PDF generation and printing |
| Fonts | google_fonts | 6.2.1 | Poppins font family |
| File Handling | file_picker | 8.1.3 | Import file selection |
| Image | image_picker | 1.2.1 | Profile picture selection |
| Crypto | crypto | 3.0.3 | Password hashing utilities |
| Date/Time | intl | 0.19.0 | Date formatting |
| Icons | cupertino_icons | 1.0.8 | iOS-style icons |
| Path | path_provider | 2.1.4 | Platform-specific file paths |

---

## 11. Testing Strategy

### Current State
- Basic widget test file exists (`test/widget_test.dart`).
- No comprehensive unit or integration tests.

### Recommended Testing Approach
| Test Type | Tools | Focus |
|---|---|---|
| Unit Tests | flutter_test | Model serialization, date utils, data transformations |
| Widget Tests | flutter_test | Screen rendering, form validation, navigation |
| Integration Tests | integration_test package | End-to-end flows (login → view schedule → logout) |
| API Tests | Mock SupabaseService | Service layer with mocked responses |

---

## 12. Scalability Considerations

### Current Limitations
- Single Supabase project instance.
- No pagination on list queries (loads all records).
- In-memory caching without TTL.
- No background sync or push notifications.

### Scaling Recommendations
1. **Pagination**: Implement `.range(start, end)` on Supabase queries for large datasets.
2. **Realtime**: Use Supabase Realtime channels for live schedule updates.
3. **Offline First**: Add SQLite (sqflite/drift) for offline data persistence.
4. **Push Notifications**: FCM for class cancellation alerts.
5. **Multi-tenancy**: Support multiple universities with tenant isolation.
6. **CDN**: Serve profile pictures via Supabase CDN for faster loading.
