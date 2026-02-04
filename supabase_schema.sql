-- =====================================================
-- EDTE Routine Scrapper - Supabase Database Schema
-- =====================================================
-- Run this SQL in your Supabase SQL Editor
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- STORAGE BUCKET FOR TEACHER PROFILE PICTURES
-- =====================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('teacher-profiles', 'teacher-profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for teacher profile pictures
CREATE POLICY "Teachers can upload profile pictures"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'teacher-profiles');

CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'teacher-profiles');

CREATE POLICY "Teachers can update profile pictures"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'teacher-profiles');

CREATE POLICY "Teachers can delete profile pictures"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'teacher-profiles');

-- =====================================================
-- 1. ADMINS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('super_admin', 'teacher_admin')),
    teacher_initial TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX idx_admins_username ON admins(username);
CREATE INDEX idx_admins_type ON admins(type);

-- =====================================================
-- 2. TEACHERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    initial TEXT UNIQUE NOT NULL,
    designation TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    home_department TEXT NOT NULL,
    profile_pic TEXT,
    password TEXT,
    has_changed_password BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_teachers_initial ON teachers(initial);
CREATE INDEX idx_teachers_department ON teachers(home_department);

-- =====================================================
-- 3. BATCHES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    session TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(name, session)
);

CREATE INDEX idx_batches_session ON batches(session);

-- =====================================================
-- 4. COURSES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_courses_code ON courses(code);

-- =====================================================
-- 5. ROOMS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_rooms_name ON rooms(name);

-- =====================================================
-- 6. STUDENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    batch_id UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    email TEXT,
    phone TEXT,
    password TEXT,
    has_changed_password BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_students_batch ON students(batch_id);
CREATE INDEX idx_students_student_id ON students(student_id);

-- =====================================================
-- 7. TIMETABLE ENTRIES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS timetable_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day TEXT NOT NULL CHECK (day IN ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')),
    batch_id UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    teacher_initial TEXT NOT NULL REFERENCES teachers(initial) ON DELETE CASCADE,
    course_code TEXT NOT NULL REFERENCES courses(code) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('Lecture', 'Tutorial', 'Sessional', 'Online')),
    group_name TEXT,
    room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
    mode TEXT NOT NULL CHECK (mode IN ('Onsite', 'Online')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_cancelled BOOLEAN DEFAULT FALSE,
    cancellation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_timetable_day ON timetable_entries(day);
CREATE INDEX idx_timetable_batch ON timetable_entries(batch_id);
CREATE INDEX idx_timetable_teacher ON timetable_entries(teacher_initial);
CREATE INDEX idx_timetable_course ON timetable_entries(course_code);
CREATE INDEX idx_timetable_room ON timetable_entries(room_id);

-- =====================================================
-- 8. APP METADATA TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS app_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version TEXT NOT NULL,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    institution_name TEXT,
    academic_year TEXT
);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teachers_updated_at BEFORE UPDATE ON teachers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_batches_updated_at BEFORE UPDATE ON batches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_timetable_entries_updated_at BEFORE UPDATE ON timetable_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE timetable_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_metadata ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (you can customize these based on your needs)
-- For simplicity, allowing all operations with anon key
-- In production, you should implement proper authentication

CREATE POLICY "Allow all on admins" ON admins FOR ALL USING (true);
CREATE POLICY "Allow all on teachers" ON teachers FOR ALL USING (true);
CREATE POLICY "Allow all on batches" ON batches FOR ALL USING (true);
CREATE POLICY "Allow all on courses" ON courses FOR ALL USING (true);
CREATE POLICY "Allow all on rooms" ON rooms FOR ALL USING (true);
CREATE POLICY "Allow all on students" ON students FOR ALL USING (true);
CREATE POLICY "Allow all on timetable_entries" ON timetable_entries FOR ALL USING (true);
CREATE POLICY "Allow all on app_metadata" ON app_metadata FOR ALL USING (true);

-- =====================================================
-- INSERT DEFAULT SUPER ADMIN
-- =====================================================
-- Password: SuperAdmin@2026 (you should change this in production)
-- Using a simple hash for demonstration (in production use proper bcrypt/argon2)
INSERT INTO admins (username, password_hash, type, teacher_initial)
VALUES 
    ('superadmin@edte.com', 'SuperAdmin@2026', 'super_admin', NULL),
    ('admin@edte.com', 'Admin@123', 'super_admin', NULL),
    -- Teacher Admin Account (linked to teacher with initial 'AZ')
    ('teacher@edte.com', 'Teacher@123', 'teacher_admin', 'AZ')
ON CONFLICT (username) DO NOTHING;

-- =====================================================
-- INSERT SAMPLE DATA (OPTIONAL - Remove in production)
-- =====================================================

-- Insert sample metadata
INSERT INTO app_metadata (version, institution_name, academic_year)
VALUES ('1.0.0', 'EDTE University', '2025-2026')
ON CONFLICT DO NOTHING;

-- Insert sample teachers
INSERT INTO teachers (name, initial, designation, phone, email, home_department) VALUES
('Dr. Azizur Rahman', 'AZ', 'Professor', '01711-123456', 'aziz@edte.edu', 'CSE'),
('Dr. Mohammad Ali', 'MA', 'Associate Professor', '01722-234567', 'mali@edte.edu', 'CSE'),
('Dr. Fatima Khan', 'FK', 'Assistant Professor', '01733-345678', 'fkhan@edte.edu', 'EEE'),
('Dr.Rahim Uddin', 'RU', 'Professor', '01744-456789', 'rahim@edte.edu', 'CSE')
ON CONFLICT (initial) DO NOTHING;

-- Insert sample courses
INSERT INTO courses (code, title) VALUES
('CSE101', 'Introduction to Programming'),
('CSE201', 'Data Structures'),
('CSE301', 'Database Management Systems'),
('CSE401', 'Software Engineering'),
('EEE101', 'Circuit Theory'),
('MATH101', 'Calculus I')
ON CONFLICT (code) DO NOTHING;

-- Insert sample rooms
INSERT INTO rooms (name) VALUES
('1001'),
('1002'),
('2001'),
('2002'),
('2701 (LAB)'),
('4001'),
('4002'),
('4701 (LAB)'),
('5001'),
('5002'),
('5701 (LAB)')
ON CONFLICT (name) DO NOTHING;

-- Insert sample batches
INSERT INTO batches (name, session) VALUES
('CSE-A', '2023-2024'),
('CSE-B', '2023-2024'),
('EEE-A', '2023-2024'),
('CSE-A', '2024-2025')
ON CONFLICT (name, session) DO NOTHING;

-- =====================================================
-- VIEWS FOR EASIER QUERYING
-- =====================================================

-- View for complete timetable with all related information
CREATE OR REPLACE VIEW v_timetable_complete AS
SELECT 
    te.id,
    te.day,
    te.start_time,
    te.end_time,
    te.type,
    te.group_name,
    te.mode,
    te.is_cancelled,
    te.cancellation_reason,
    b.id as batch_id,
    b.name as batch_name,
    b.session as batch_session,
    t.initial as teacher_initial,
    t.name as teacher_name,
    t.designation as teacher_designation,
    c.code as course_code,
    c.title as course_title,
    r.id as room_id,
    r.name as room_name,
    te.created_at,
    te.updated_at
FROM timetable_entries te
JOIN batches b ON te.batch_id = b.id
JOIN teachers t ON te.teacher_initial = t.initial
JOIN courses c ON te.course_code = c.code
LEFT JOIN rooms r ON te.room_id = r.id;

-- View for student batch information
CREATE OR REPLACE VIEW v_students_with_batch AS
SELECT 
    s.id,
    s.student_id,
    s.name,
    s.email,
    s.phone,
    b.id as batch_id,
    b.name as batch_name,
    b.session as batch_session,
    s.created_at,
    s.updated_at
FROM students s
JOIN batches b ON s.batch_id = b.id;

-- =====================================================
-- FUNCTIONS FOR COMMON OPERATIONS
-- =====================================================

-- Function to get teacher's schedule for a day
CREATE OR REPLACE FUNCTION get_teacher_schedule(
    teacher_initial_param TEXT,
    day_param TEXT
)
RETURNS TABLE (
    id UUID,
    start_time TIME,
    end_time TIME,
    course_code TEXT,
    course_title TEXT,
    batch_name TEXT,
    room_name TEXT,
    type TEXT,
    mode TEXT,
    is_cancelled BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        te.id,
        te.start_time,
        te.end_time,
        c.code,
        c.title,
        b.name,
        r.name,
        te.type,
        te.mode,
        te.is_cancelled
    FROM timetable_entries te
    JOIN courses c ON te.course_code = c.code
    JOIN batches b ON te.batch_id = b.id
    LEFT JOIN rooms r ON te.room_id = r.id
    WHERE te.teacher_initial = teacher_initial_param 
      AND te.day = day_param
    ORDER BY te.start_time;
END;
$$ LANGUAGE plpgsql;

-- Function to get batch schedule for a day
CREATE OR REPLACE FUNCTION get_batch_schedule(
    batch_id_param UUID,
    day_param TEXT
)
RETURNS TABLE (
    id UUID,
    start_time TIME,
    end_time TIME,
    course_code TEXT,
    course_title TEXT,
    teacher_name TEXT,
    teacher_initial TEXT,
    room_name TEXT,
    type TEXT,
    mode TEXT,
    is_cancelled BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        te.id,
        te.start_time,
        te.end_time,
        c.code,
        c.title,
        t.name,
        t.initial,
        r.name,
        te.type,
        te.mode,
        te.is_cancelled
    FROM timetable_entries te
    JOIN courses c ON te.course_code = c.code
    JOIN teachers t ON te.teacher_initial = t.initial
    LEFT JOIN rooms r ON te.room_id = r.id
    WHERE te.batch_id = batch_id_param 
      AND te.day = day_param
    ORDER BY te.start_time;
END;
$$ LANGUAGE plpgsql;

-- Function to find free rooms at a specific time
CREATE OR REPLACE FUNCTION get_free_rooms(
    day_param TEXT,
    time_param TIME
)
RETURNS TABLE (
    room_id UUID,
    room_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.name
    FROM rooms r
    WHERE r.id NOT IN (
        SELECT te.room_id
        FROM timetable_entries te
        WHERE te.day = day_param
          AND te.room_id IS NOT NULL
          AND te.is_cancelled = FALSE
          AND time_param >= te.start_time
          AND time_param < te.end_time
    )
    ORDER BY r.name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- MIGRATION: ADD CREDENTIAL COLUMNS (RUN IF UPDATING EXISTING DB)
-- =====================================================
-- Uncomment and run these ALTER TABLE statements if you have an existing database
-- to add the new credential management columns

-- ALTER TABLE teachers
-- ADD COLUMN IF NOT EXISTS password TEXT,
-- ADD COLUMN IF NOT EXISTS has_changed_password BOOLEAN DEFAULT FALSE;

-- ALTER TABLE students
-- ADD COLUMN IF NOT EXISTS password TEXT,
-- ADD COLUMN IF NOT EXISTS has_changed_password BOOLEAN DEFAULT FALSE;

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Database schema created successfully!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Default Super Admin Credentials:';
    RAISE NOTICE 'Username: superadmin@edte.com';
    RAISE NOTICE 'Password: SuperAdmin@2026';
    RAISE NOTICE '';
    RAISE NOTICE 'Alternative Admin:';
    RAISE NOTICE 'Username: admin@edte.com';
    RAISE NOTICE 'Password: Admin@123';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'IMPORTANT - NEW CREDENTIAL COLUMNS:';
    RAISE NOTICE 'If updating existing database, run the';
    RAISE NOTICE 'ALTER TABLE statements in the MIGRATION section';
    RAISE NOTICE '========================================';

    RAISE NOTICE 'IMPORTANT: Change these passwords in production!';
    RAISE NOTICE '========================================';
END $$;
