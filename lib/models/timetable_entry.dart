class TimetableEntry {
  final String day;
  final String batchId;
  final String teacherInitial;
  final String courseCode;
  final String type; // Lecture, Tutorial, Sessional, Online
  final String? group; // G-1 / G-2 / null
  final String? roomId;
  final String mode; // Onsite / Online
  final String start; // "HH:mm"
  final String end; // "HH:mm"
  final bool isCancelled; // Class cancellation status
  final String? cancellationReason; // Reason for cancellation

  TimetableEntry({
    required this.day,
    required this.batchId,
    required this.teacherInitial,
    required this.courseCode,
    required this.type,
    this.group,
    this.roomId,
    required this.mode,
    required this.start,
    required this.end,
    this.isCancelled = false,
    this.cancellationReason,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) => TimetableEntry(
        day: json['day'],
        batchId: json['batch_id'],
        teacherInitial: json['teacher_initial'],
        courseCode: json['course_code'],
        type: json['type'],
        group: json['group'],
        roomId: json['room_id'],
        mode: json['mode'],
        start: json['start'],
        end: json['end'],
        isCancelled: json['is_cancelled'] ?? false,
        cancellationReason: json['cancellation_reason'],
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'batch_id': batchId,
        'teacher_initial': teacherInitial,
        'course_code': courseCode,
        'type': type,
        'group': group,
        'room_id': roomId,
        'mode': mode,
        'start': start,
        'end': end,
        'is_cancelled': isCancelled,
        'cancellation_reason': cancellationReason,
      };

  // Create a copy with modified fields
  TimetableEntry copyWith({
    String? day,
    String? batchId,
    String? teacherInitial,
    String? courseCode,
    String? type,
    String? group,
    String? roomId,
    String? mode,
    String? start,
    String? end,
    bool? isCancelled,
    String? cancellationReason,
  }) {
    return TimetableEntry(
      day: day ?? this.day,
      batchId: batchId ?? this.batchId,
      teacherInitial: teacherInitial ?? this.teacherInitial,
      courseCode: courseCode ?? this.courseCode,
      type: type ?? this.type,
      group: group ?? this.group,
      roomId: roomId ?? this.roomId,
      mode: mode ?? this.mode,
      start: start ?? this.start,
      end: end ?? this.end,
      isCancelled: isCancelled ?? this.isCancelled,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
