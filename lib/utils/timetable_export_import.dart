import 'dart:convert';
import '../models/timetable_entry.dart';

/// Utility class for exporting and importing timetable data
class TimetableExportImport {
  /// Convert timetable entries to JSON format for export
  static String toJSON(List<TimetableEntry> entries) {
    final json = entries.map((e) => e.toJson()).toList();
    return jsonEncode({'entries': json, 'exportDate': DateTime.now().toIso8601String()});
  }

  /// Convert timetable entries to CSV format for export
  static String toCSV(List<TimetableEntry> entries) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('day,batchId,teacherInitial,courseCode,type,mode,start,end,roomId,group,isCancelled,cancellationReason');
    
    // Data rows
    for (var entry in entries) {
      buffer.writeln([
        entry.day,
        entry.batchId,
        entry.teacherInitial,
        entry.courseCode,
        entry.type,
        entry.mode,
        entry.start,
        entry.end,
        entry.roomId ?? '',
        entry.group ?? '',
        entry.isCancelled.toString(),
        entry.cancellationReason ?? '',
      ].map((v) => '"$v"').join(','));
    }
    
    return buffer.toString();
  }

  /// Get template for JSON import
  static String getJSONTemplate() {
    final template = [
      {
        'day': 'Mon',
        'batchId': 'B1',
        'teacherInitial': 'JD',
        'courseCode': 'CS101',
        'type': 'Lecture',
        'mode': 'Onsite',
        'start': '09:00',
        'end': '10:30',
        'roomId': 'R101',
        'group': 'None',
        'isCancelled': false,
        'cancellationReason': null,
      },
      {
        'day': 'Tue',
        'batchId': 'B1',
        'teacherInitial': 'AB',
        'courseCode': 'CS102',
        'type': 'Tutorial',
        'mode': 'Online',
        'start': '11:00',
        'end': '12:00',
        'roomId': null,
        'group': 'G-1',
        'isCancelled': false,
        'cancellationReason': null,
      },
    ];

    return jsonEncode({'entries': template, 'exportDate': DateTime.now().toIso8601String()});
  }

  /// Get template for CSV import
  static String getCSVTemplate() {
    return '''day,batchId,teacherInitial,courseCode,type,mode,start,end,roomId,group,isCancelled,cancellationReason
"Mon","B1","JD","CS101","Lecture","Onsite","09:00","10:30","R101","None","false",""
"Tue","B1","AB","CS102","Tutorial","Online","11:00","12:00","","G-1","false",""
"Wed","B2","XY","CS103","Sessional","Onsite","14:00","15:30","R102","None","false",""
"Thu","B1","JD","CS101","Lecture","Onsite","09:00","10:30","R101","None","false",""
"Fri","B2","AB","CS102","Tutorial","Online","11:00","12:00","","G-2","false",""''';
  }

  /// Validate timetable entries
  static List<String> validateEntries(List<TimetableEntry> entries) {
    final errors = <String>[];
    
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      
      if (entry.day.isEmpty) {
        errors.add('Row ${i + 1}: Day is required');
      }
      
      if (entry.batchId.isEmpty) {
        errors.add('Row ${i + 1}: Batch ID is required');
      }
      
      if (entry.teacherInitial.isEmpty) {
        errors.add('Row ${i + 1}: Teacher initial is required');
      }
      
      if (entry.courseCode.isEmpty) {
        errors.add('Row ${i + 1}: Course code is required');
      }
      
      final validTypes = ['Lecture', 'Tutorial', 'Sessional', 'Online'];
      if (!validTypes.contains(entry.type)) {
        errors.add('Row ${i + 1}: Invalid type "${entry.type}". Must be: ${validTypes.join(', ')}');
      }
      
      final validModes = ['Onsite', 'Online'];
      if (!validModes.contains(entry.mode)) {
        errors.add('Row ${i + 1}: Invalid mode "${entry.mode}". Must be: ${validModes.join(', ')}');
      }
      
      if (!_isValidTime(entry.start)) {
        errors.add('Row ${i + 1}: Invalid start time "${entry.start}". Use HH:mm format');
      }
      
      if (!_isValidTime(entry.end)) {
        errors.add('Row ${i + 1}: Invalid end time "${entry.end}". Use HH:mm format');
      }
      
      if (entry.mode == 'Onsite' && (entry.roomId == null || entry.roomId!.isEmpty)) {
        errors.add('Row ${i + 1}: Room is required for Onsite classes');
      }
    }
    
    return errors;
  }

  static bool _isValidTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return false;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }
}
