class Student {
  final String studentId;
  final String name;
  final String batchId;

  Student({
    required this.studentId,
    required this.name,
    required this.batchId,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        studentId: json['student_id'],
        name: json['name'] ?? '',
        batchId: json['batch_id'],
      );

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'name': name,
        'batch_id': batchId,
      };
}
