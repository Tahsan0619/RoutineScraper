import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/app_data.dart';
import '../models/teacher.dart';
import '../models/batch.dart';
import '../models/course.dart';
import '../models/room.dart';
import '../models/student.dart';
import '../models/timetable_entry.dart';
import '../models/admin.dart';

/// Data Repository for managing all app data
class DataRepository extends ChangeNotifier {
  AppData? _data;
  AppData? get data => _data;
  
  // In-memory storage for modifications (cancellations, room changes)
  final Map<String, TimetableEntry> _modifiedEntries = {};
  final List<TimetableEntry> _newEntries = [];

  /// Load data from JSON file
  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data.json');
    final cleaned = _stripJsonComments(raw);
    final jsonMap = jsonDecode(cleaned) as Map<String, dynamic>;
    _data = AppData.fromJson(jsonMap);
    notifyListeners();
  }

  /// Strip comments from JSON (supports // and /* */ style comments)
  static String _stripJsonComments(String s) {
    final withoutBlock = s.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    final withoutLine = withoutBlock
        .split('\n')
        .map((line) {
          final idx = line.indexOf('//');
          return idx >= 0 ? line.substring(0, idx) : line;
        })
        .join('\n');
    return withoutLine;
  }

  /// Get teacher entries for a specific day
  List<TimetableEntry> teacherEntriesForDay(String initial, String day) {
    if (_data == null) return const [];
    final allEntries = getAllTimetableEntries();
    final list = allEntries
        .where((e) => e.teacherInitial == initial && e.day == day)
        .toList();
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// Get all teacher entries for the entire week
  Map<String, List<TimetableEntry>> teacherWeeklyEntries(String initial) {
    if (_data == null) return {};
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final Map<String, List<TimetableEntry>> weekMap = {};
    
    for (final day in days) {
      weekMap[day] = teacherEntriesForDay(initial, day);
    }
    return weekMap;
  }

  /// Get batch entries for a specific day
  List<TimetableEntry> batchEntriesForDay(String batchId, String day) {
    if (_data == null) return const [];
    final allEntries = getAllTimetableEntries();
    final list = allEntries
        .where((e) => e.batchId == batchId && e.day == day)
        .toList();
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// Get teacher by initial
  Teacher? teacherByInitial(String initial) {
    if (_data == null) return null;
    for (final t in _data!.teachers) {
      if (t.initial == initial) return t;
    }
    return null;
  }

  /// Get batch by ID
  Batch? batchById(String id) {
    if (_data == null) return null;
    for (final b in _data!.batches) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Get course by code
  Course? courseByCode(String code) {
    if (_data == null) return null;
    for (final c in _data!.courses) {
      if (c.code == code) return c;
    }
    return null;
  }

  /// Get room by ID
  Room? roomById(String? id) {
    if (_data == null || id == null) return null;
    for (final r in _data!.rooms) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Get student by ID
  Student? studentById(String sid) {
    if (_data == null) return null;
    for (final s in _data!.students) {
      if (s.studentId == sid) return s;
    }
    return null;
  }

  /// Get all allowed teacher initials
  Set<String> allowedTeacherInitials() {
    if (_data == null) return {};
    return _data!.teachers.map((t) => t.initial).toSet();
  }

  /// Authenticate admin
  Admin? authenticateAdmin(String username, String password) {
    if (_data == null) return null;
    for (final admin in _data!.admins) {
      if (admin.username == username && admin.password == password) {
        return admin;
      }
    }
    return null;
  }

  /// Get entry key for tracking modifications
  String _getEntryKey(TimetableEntry entry) {
    return '${entry.day}_${entry.batchId}_${entry.teacherInitial}_${entry.courseCode}_${entry.start}';
  }

  /// Get timetable entry considering modifications
  TimetableEntry _getModifiedEntry(TimetableEntry original) {
    final key = _getEntryKey(original);
    return _modifiedEntries[key] ?? original;
  }

  /// Cancel a class
  void cancelClass(TimetableEntry entry, String reason) {
    final key = _getEntryKey(entry);
    _modifiedEntries[key] = entry.copyWith(
      isCancelled: true,
      cancellationReason: reason,
    );
    notifyListeners();
  }

  /// Un-cancel a class
  void uncancelClass(TimetableEntry entry) {
    final key = _getEntryKey(entry);
    _modifiedEntries[key] = entry.copyWith(
      isCancelled: false,
      cancellationReason: null,
    );
    notifyListeners();
  }

  /// Change room for a class
  void changeRoom(TimetableEntry entry, String newRoomId) {
    final key = _getEntryKey(entry);
    _modifiedEntries[key] = entry.copyWith(roomId: newRoomId);
    notifyListeners();
  }

  /// Add new timetable entry (super admin only)
  void addTimetableEntry(TimetableEntry entry) {
    _newEntries.add(entry);
    notifyListeners();
  }

  /// Remove timetable entry (super admin only)
  void removeTimetableEntry(TimetableEntry entry) {
    _newEntries.removeWhere((e) => _getEntryKey(e) == _getEntryKey(entry));
    final key = _getEntryKey(entry);
    _modifiedEntries[key] = entry.copyWith(isCancelled: true);
    notifyListeners();
  }

  /// Get all timetable entries (including modifications)
  List<TimetableEntry> getAllTimetableEntries() {
    if (_data == null) return [];
    final allEntries = [..._data!.timetable, ..._newEntries];
    return allEntries.map(_getModifiedEntry).toList();
  }
}
