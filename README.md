# SmartRoutine - EdTE Scheduler

A comprehensive class schedule management application for the **Department of Educational Technology and Engineering** at the **University of Frontier Technology, Bangladesh**.

## Project Overview

SmartRoutine is a Flutter-based mobile application designed to streamline routine management for both teachers and students. The app provides an intuitive, reliable, and interactive platform to manage academic routines efficiently.

## Features

### Student Portal
- **Login with Student ID** - Quick access using student identification
- **Daily Schedule View** - View today's classes with detailed information
- **Visual Indicators** - Clear display of class times, locations, and modes (Online/Onsite)
- **Batch Information** - See classes specific to your batch
- **Off-day Detection** - Automatic detection and notification of holidays

### Teacher Portal
- **Login with Initials** - Fast access using teacher initials
- **Daily View** - See today's teaching schedule
- **Weekly View** - Comprehensive week-at-a-glance schedule
- **PDF Export** - Download complete weekly schedule as PDF
- **Teacher Profile** - Display teacher information including designation, department, and contact details
- **Class Details** - Course names, batch information, room locations, and timing

### General Features
- **Offline Support** - Works without internet after initial data load
- **Beautiful UI** - Modern Material Design 3 with Google Fonts
- **Color-coded Classes** - Easy visual distinction between different class types
- **Real-time Data** - JSON-based data structure for easy updates
- **Responsive Design** - Works on phones and tablets

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── app_data.dart
│   ├── app_meta.dart
│   ├── batch.dart
│   ├── course.dart
│   ├── room.dart
│   ├── student.dart
│   ├── teacher.dart
│   └── timetable_entry.dart
├── screens/                     # UI screens
│   ├── landing_screen.dart
│   ├── student_portal_screen.dart
│   └── teacher_portal_screen.dart
├── services/                    # Business logic
│   └── data_repository.dart
├── utils/                       # Helper functions
│   └── date_utils.dart
└── widgets/                     # Reusable UI components
    ├── big_nav_button.dart
    ├── brand_card.dart
    ├── gradient_shell.dart
    ├── schedule_list.dart
    └── teacher_card.dart

assets/
└── data.json                    # Schedule data
```

## Technologies Used

- **Framework**: Flutter (Dart)
- **UI**: Material Design 3, Google Fonts (Poppins)
- **Data Format**: JSON
- **PDF Export**: pdf & printing packages
- **Date/Time**: intl package
- **Storage**: Local asset bundling

## Installation & Setup

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or emulator

### Steps

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Update data** (if needed)
   - Edit `assets/data.json` with your institution's data

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## Usage Guide

### For Students
1. Open the app and select "I'm a Student"
2. Enter your Student ID (e.g., 2023010101)
3. Click "Find" to view today's schedule
4. See all your classes with timings, locations, and course details

### For Teachers
1. Open the app and select "I'm a Teacher"
2. Enter your initials (e.g., AZ, RS)
3. Click "Find" to access your dashboard
4. Switch between "Daily" and "Weekly" views
5. Click "Export PDF" to download your schedule

## Customization

### Updating Schedule Data
Edit `assets/data.json` with your data structure.

### Changing Theme Colors
Modify `lib/main.dart`:
```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1976D2), // Change this color
  brightness: Brightness.light,
);
```

## Future Enhancements

- Real-time notifications for class changes
- Cloud-based backend (Firebase/AWS)
- Attendance tracking
- Multi-device synchronization
- Analytics dashboard for administrators
- Integration with Learning Management Systems (LMS)
- Support for multiple departments/universities

## Contributors

- **Developer**: Tahsan
- **Department**: Educational Technology and Engineering
- **Institution**: University of Frontier Technology, Bangladesh

## License

This project is developed as a capstone project for educational purposes.

---

**Version**: 1.0.0  
**Last Updated**: January 21, 2026  
**Status**: Production Ready
