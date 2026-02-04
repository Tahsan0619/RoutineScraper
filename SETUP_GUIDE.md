# EDTE Routine Scrapper - Supabase Integration Setup Guide

## 📋 Overview
This guide will help you set up your Flutter app with Supabase backend for a fully functional university schedule management system.

---

## 🚀 Quick Start Steps

### Step 1: Run SQL Setup in Supabase

1. **Go to your Supabase Project Dashboard**
   - URL: https://supabase.com/dashboard
   - Select your project (https://yofrdlyzetcezbhhbkdb.supabase.co)

2. **Navigate to SQL Editor**
   - Click on "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Execute the Database Schema**
   - Open the file: `supabase_schema.sql` (in your project root)
   - Copy ALL the contents
   - Paste into Supabase SQL Editor
   - Click "Run" or press `Ctrl+Enter`

4. **Verify Success**
   - You should see success messages
   - Check "Table Editor" to see all tables created:
     - admins
     - teachers
     - batches
     - courses
     - rooms
     - students
     - timetable_entries
     - app_metadata

---

### Step 2: Install Dependencies

Open your terminal in the project directory and run:

```bash
flutter pub get
```

This will install all required packages including:
- supabase_flutter
- provider
- google_fonts
- and more...

---

### Step 3: Run the Application

```bash
flutter run
```

Or select your device in VS Code and press F5.

---

## 🔐 Default Login Credentials

### Super Admin Account
```
Username: superadmin@edte.com
Password: SuperAdmin@2026
```

### Alternative Admin Account
```
Username: admin@edte.com
Password: Admin@123
```

**⚠️ IMPORTANT:** Change these passwords in production!

---

## 📊 Database Schema Overview

### Tables Created

1. **admins** - Admin user accounts (Super Admin & Teacher Admins)
2. **teachers** - Faculty information with initials
3. **batches** - Student batches/groups (e.g., CSE-A 2024-2025)
4. **courses** - Course catalog with codes and titles
5. **rooms** - Classroom/lab information
6. **students** - Student records linked to batches
7. **timetable_entries** - Schedule/routine entries
8. **app_metadata** - Application settings and metadata

### Sample Data Included

The SQL script automatically creates:
- ✅ 2 Super Admin accounts
- ✅ 4 Sample teachers
- ✅ 6 Sample courses
- ✅ 6 Sample rooms
- ✅ 4 Sample batches

---

## 🎯 Features Available

### For Super Admin:

#### ✅ Dashboard
- View total batches, students, teachers, and classes
- Quick action cards for management

#### ✅ Batch Management
- **Add New Batch** - Create batches with name and session
- **Edit Batch** - Update batch information
- **Delete Batch** - Remove batches (cascades to students)
- View all batches in a clean list

#### ✅ Student Management
- **Add New Student** - Add students with ID, name, and batch
- **Edit Student** - Update student information
- **Delete Student** - Remove student records
- **Filter by Batch** - View students by specific batch
- Automatic batch linking

#### 🔄 Teachers Management (Coming Soon)
- Add/Edit/Delete teachers
- Set teacher initials and departments

#### 🔄 Timetable Management (Coming Soon)
- Create class schedules
- Assign teachers, rooms, and batches
- Cancel/reschedule classes

### For Students:
- View schedules by batch
- Check free rooms
- Access teacher information

---

## 🔧 Configuration Details

### Supabase Connection

Your app is configured with:
```dart
URL: https://yofrdlyzetcezbhhbkdb.supabase.co
Anon Key: (Already configured in main.dart)
```

### Row Level Security (RLS)

Currently set to allow all operations for simplicity. In production, you should:
1. Enable proper authentication
2. Create specific policies per user role
3. Restrict direct database access

---

## 📝 How to Use Super Admin Features

### Adding a Batch

1. Login as Super Admin
2. Click "Batches" tab
3. Click "Add Batch" button
4. Enter:
   - **Batch Name**: e.g., "CSE-A", "EEE-B"
   - **Session**: e.g., "2024-2025"
5. Click "Add"

### Adding Students to a Batch

1. Go to "Students" tab
2. Click "Add Student"
3. Enter:
   - **Student ID**: Unique identifier (e.g., "2024-CSE-001")
   - **Student Name**: Full name
   - **Batch**: Select from dropdown
4. Click "Add"

### Editing/Deleting

- Click the **Edit** icon (✏️) to modify records
- Click the **Delete** icon (🗑️) to remove records
- Confirm deletions in the dialog

---

## 🔍 Troubleshooting

### Issue: "Failed to load data"
**Solution:** Verify Supabase connection and run SQL schema

### Issue: "Invalid credentials"
**Solution:** Check username/password, ensure SQL script ran successfully

### Issue: "Batch/Student not appearing"
**Solution:** Check Supabase Table Editor for data, verify RLS policies

### Issue: Flutter packages error
**Solution:** Run `flutter clean` then `flutter pub get`

---

## 📱 Testing Checklist

- [ ] SQL script executed without errors
- [ ] Can login as Super Admin
- [ ] Dashboard shows stats
- [ ] Can add a new batch
- [ ] Can edit an existing batch
- [ ] Can delete a batch
- [ ] Can add a student to a batch
- [ ] Can edit student information
- [ ] Can delete a student
- [ ] Can filter students by batch

---

## 🔒 Production Deployment Checklist

Before deploying to production:

1. **Security**
   - [ ] Change default admin passwords
   - [ ] Update RLS policies for proper access control
   - [ ] Enable Supabase auth (not just password-based)
   - [ ] Add password hashing (bcrypt/argon2)

2. **Environment**
   - [ ] Move Supabase credentials to environment variables
   - [ ] Enable HTTPS only
   - [ ] Set up proper error logging

3. **Database**
   - [ ] Remove sample data
   - [ ] Add database backups
   - [ ] Set up monitoring

4. **App**
   - [ ] Test on multiple devices
   - [ ] Add loading states
   - [ ] Handle offline scenarios
   - [ ] Add data validation

---

## 📚 Database Functions

The SQL script includes helper functions:

### `get_teacher_schedule(teacher_initial, day)`
Returns a teacher's schedule for a specific day

### `get_batch_schedule(batch_id, day)`
Returns a batch's schedule for a specific day

### `get_free_rooms(day, time)`
Returns available rooms at a specific day and time

**Usage Example:**
```sql
SELECT * FROM get_teacher_schedule('AZ', 'Mon');
SELECT * FROM get_free_rooms('Mon', '10:00:00');
```

---

## 🎨 UI Theme

The app uses a modern dark theme with:
- **Primary Color**: Blue (#5B7CFF)
- **Secondary Color**: Purple (#8A5BFF)
- **Background**: Dark (#121212, #1E1E1E)
- **Font**: Google Fonts Poppins

---

## 📞 Support

If you encounter issues:

1. Check Supabase dashboard for errors
2. Verify table structure in Table Editor
3. Check Flutter console for error messages
4. Ensure internet connection is stable

---

## ✨ Future Enhancements

Planned features:
- Teacher management interface
- Complete timetable CRUD operations
- PDF export of schedules
- Email notifications
- Mobile app optimization
- Offline support with sync

---

## 📄 License

This project is part of EDTE University Schedule Management System.

---

**Last Updated:** February 2026
**Version:** 1.0.0

---

## Quick Command Reference

```bash
# Install dependencies
flutter pub get

# Clean build
flutter clean

# Run app
flutter run

# Build APK
flutter build apk --release

# Build for web
flutter build web
```

---

**🎉 You're all set! Login and start managing your university schedule system.**
