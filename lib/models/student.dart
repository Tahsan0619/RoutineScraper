class Student {
  final String studentId;
  final String name;
  final String batchId;
  final String? email; // Added for login
  final bool hasChangedPassword; // Track if user changed password

  Student({
    required this.studentId,
    required this.name,
    required this.batchId,
    this.email,
    this.hasChangedPassword = false,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        studentId: json['student_id'],
        name: json['name'] ?? '',
        batchId: json['batch_id'],
        email: json['email'],
        hasChangedPassword: json['has_changed_password'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'name': name,
        'batch_id': batchId,
        'email': email,
        'has_changed_password': hasChangedPassword,
      };
}
