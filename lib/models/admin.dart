class Admin {
  final String id;
  final String username;
  final String password;
  final String type; // 'super_admin' or 'teacher_admin'
  final String? teacherInitial; // null for super_admin, required for teacher_admin

  Admin({
    required this.id,
    required this.username,
    required this.password,
    required this.type,
    this.teacherInitial,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        type: json['type'],
        teacherInitial: json['teacher_initial'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'type': type,
        'teacher_initial': teacherInitial,
      };

  bool get isSuperAdmin => type == 'super_admin';
  bool get isTeacherAdmin => type == 'teacher_admin';
}
