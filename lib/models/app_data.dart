import 'app_meta.dart';
import 'teacher.dart';
import 'batch.dart';
import 'course.dart';
import 'room.dart';
import 'student.dart';
import 'timetable_entry.dart';
import 'admin.dart';

class AppData {
  final AppMeta meta;
  final List<Teacher> teachers;
  final List<Batch> batches;
  final List<Course> courses;
  final List<Room> rooms;
  final List<Student> students;
  final List<TimetableEntry> timetable;
  final List<Admin> admins;

  AppData({
    required this.meta,
    required this.teachers,
    required this.batches,
    required this.courses,
    required this.rooms,
    required this.students,
    required this.timetable,
    this.admins = const [],
  });

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        meta: AppMeta.fromJson(json['meta']),
        teachers: (json['teachers'] as List)
            .map((e) => Teacher.fromJson(e))
            .toList(),
        batches:
            (json['batches'] as List).map((e) => Batch.fromJson(e)).toList(),
        courses:
            (json['courses'] as List).map((e) => Course.fromJson(e)).toList(),
        rooms: (json['rooms'] as List).map((e) => Room.fromJson(e)).toList(),
        students:
            (json['students'] as List).map((e) => Student.fromJson(e)).toList(),
        timetable: (json['timetable'] as List)
            .map((e) => TimetableEntry.fromJson(e))
            .toList(),
        admins: json['admins'] != null
            ? (json['admins'] as List).map((e) => Admin.fromJson(e)).toList()
            : [],
      );

  Map<String, dynamic> toJson({List<TimetableEntry>? timetableOverride}) => {
        'meta': meta.toJson(),
        'teachers': teachers.map((t) => t.toJson()).toList(),
        'batches': batches.map((b) => b.toJson()).toList(),
        'courses': courses.map((c) => c.toJson()).toList(),
        'rooms': rooms.map((r) => r.toJson()).toList(),
        'students': students.map((s) => s.toJson()).toList(),
        'timetable': (timetableOverride ?? timetable)
            .map((e) => e.toJson())
            .toList(),
        'admins': admins.map((a) => a.toJson()).toList(),
      };
}
