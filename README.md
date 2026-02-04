# SmartRoutine - EdTE Scheduler

A comprehensive class schedule management application for the **Department of Educational Technology and Engineering** at the **University of Frontier Technology, Bangladesh**.

## Project Overview

SmartRoutine is a Flutter-based mobile application designed to streamline routine management for students, teachers, and administrators. The app provides an intuitive, reliable, and interactive platform to manage academic routines efficiently with secure authentication and session persistence.

## Features

### Authentication & Security
- **Unified Login System** - Single login screen for super admin, teacher admin, teachers, and students
- **Role-Based Access** - Different portals for each user type with appropriate permissions
- **Password Management** - Secure password change functionality for all users
- **Session Persistence** - Persistent login across app restarts and hot reloads
- **Credential Locking** - Auto-lock credentials after password change for enhanced security

### Super Admin Portal
- **Comprehensive Management** - Manage batches, students, teachers, rooms, and courses
- **Student Management** - Add/edit students, set initial login credentials
- **Teacher Management** - Manage teacher profiles and credentials
- **Batch Management** - Create and manage academic batches
- **Room Management** - Configure classroom information
- **Timetable Management** - Create, edit, and organize class schedules
- **Analytics Dashboard** - View statistics on classes, batches, and scheduling
- **PDF Export** - Export complete timetables in professional format
- **Import Functionality** - Import timetable data from JSON and CSV files
- **Credential Control** - Lock student/teacher credentials after password change

### Teacher Portal (Teacher Admin)
- **Dashboard** - View daily class schedule with quick actions
- **Schedule Management** - Organize and manage teaching schedule
- **Class Control** - Cancel, reschedule, or change room for classes
- **Profile Management** - Update profile information
- **Password Change** - Secure password change functionality
- **Teachers List** - View all teachers and their schedules

### Teacher Portal (Regular Teacher)
- **Daily Schedule View** - View today's classes with detailed information
- **Weekly View** - Comprehensive week-at-a-glance schedule
- **Class Information** - Course names, batch information, room locations, and timing
- **Profile Management** - Personal profile and password change
- **PDF Export** - Download schedules as PDF

### Student Portal
- **Login with Email** - Secure login using student email
- **Daily Schedule** - View today's classes
- **Weekly Schedule** - See full week's schedule
- **Batch Information** - Class details specific to batch
- **Room Schedule** - View room availability and schedules
- **Free Rooms** - Find available classrooms
- **Student Profile** - View profile and change password
- **Persistent Login** - Stay logged in across app sessions

### General Features
- **Responsive Design** - Works seamlessly on phones and tablets
- **Material Design 3** - Modern UI with Google Fonts (Poppins)
- **Dark Theme** - Eye-friendly dark color scheme
- **Offline Support** - Data caching for offline access
- **Real-time Updates** - Supabase backend for live data synchronization
- **Color-coded Classes** - Visual distinction between Online/Onsite classes

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/                             # Data models
│   ├── admin.dart
│   ├── student.dart
│   ├── teacher.dart
│   ├── batch.dart
│   ├── course.dart
│   ├── room.dart
│   └── timetable_entry.dart
├── screens/                            # UI screens
│   ├── unified_login_screen_new.dart
│   ├── super_admin_portal_screen_new.dart
│   ├── teacher_admin_portal_screen_new.dart
│   ├── teacher_profile_screen.dart
│   ├── student_profile_screen.dart
│   ├── main_navigation_screen.dart
│   ├── student_screen.dart
│   ├── teacher_screen.dart
│   ├── room_screen.dart
│   ├── free_rooms_screen.dart
│   ├── manage_batches_screen.dart
│   ├── manage_rooms_screen.dart
│   └── manage_teachers_screen.dart
├── services/                           # Business logic
│   ├── supabase_service.dart           # Backend API integration
│   └── data_repository.dart            # Data management
├── utils/                              # Helper functions
│   ├── date_utils.dart
│   └── timetable_export_import.dart
└── widgets/                            # Reusable UI components
    ├── gradient_shell.dart
    ├── online_badge.dart
    ├── schedule_card.dart
    └── custom_dropdown.dart

assets/
├── data.json                           # Legacy data format
├── timetable_template.json             # JSON import template
└── timetable_template.csv              # CSV import template
```

## Technologies Used

- **Framework**: Flutter (Dart) 3.8.1+
- **Backend**: Supabase (PostgreSQL)
- **UI**: Material Design 3, Google Fonts
- **State Management**: Provider
- **PDF Generation**: pdf & printing packages
- **File Handling**: file_picker
- **Local Storage**: SharedPreferences
- **Authentication**: Email/password with session persistence
- **Data Format**: JSON, CSV

## Installation & Setup

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Git
- Android Studio / VS Code with Flutter extensions

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tahsan0619/Oli_Vai.git
   cd edteroutinescrapper
   ```

2. **Install dependencies**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Configure Supabase** (if needed)
   - Update Supabase credentials in `lib/main.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## Usage Guide

### For Super Admin (Initial Setup)
1. Login with super admin credentials
2. Create batches, rooms, courses
3. Add students and teachers
4. Set initial login credentials for students/teachers
5. Create and manage timetables
6. Export/import schedules as needed

### For Teachers
1. Login with email and password
2. Access teaching schedule
3. Manage daily classes (cancel, reschedule, change room)
4. Change password from profile
5. View analytics and statistics

### For Students
1. Login with email and password
2. View daily and weekly schedules
3. Check free classroom availability
4. View room information
5. Change password from profile

## API Endpoints

The app uses Supabase as backend with the following main tables:
- `admins` - Administrator accounts
- `students` - Student records with login credentials
- `teachers` - Teacher profiles with login credentials
- `batches` - Academic batch information
- `courses` - Course details
- `rooms` - Classroom information
- `timetable` - Class schedule entries

## Security Features

- **Password Hashing** - Secure password storage
- **Session Management** - SharedPreferences-based session persistence
- **Credential Locking** - Automatic credential lock after password change
- **Email Verification** - Student/teacher email-based login
- **Role-Based Access Control** - Different UI/functionality per user type

## Future Enhancements

- Real-time notifications for schedule changes
- Attendance tracking system
- Student-teacher messaging
- Integration with academic calendar
- Advanced analytics and reporting
- Mobile push notifications
- QR code scanning for class attendance
- Integration with Learning Management Systems (LMS)

## Troubleshooting

### Hot Reload Issues
- If session is lost after hot reload, ensure SharedPreferences is properly initialized
- Run `flutter clean` and rebuild if persistent issues occur

### Supabase Connection
- Verify Supabase credentials in `lib/main.dart`
- Check internet connectivity
- Ensure Supabase project is active

### Build Issues
- Run `flutter pub get` to install dependencies
- Clear build cache: `flutter clean`
- Rebuild: `flutter pub get && flutter run`

## Contributors

- **Developer**: Tahsan
- **Department**: Educational Technology and Engineering
- **Institution**: University of Frontier Technology, Bangladesh

## License

This project is developed as a capstone project for educational purposes.

---

**Version**: 2.0.0  
**Last Updated**: February 4, 2026  
**Status**: Production Ready  
**Latest Features**: Unified authentication, session persistence, profile management, PDF export/import
