class Teacher {
  final String id;
  final String name;
  final String initial;
  final String designation;
  final String phone;
  final String email;
  final String homeDepartment;

  Teacher({
    required this.id,
    required this.name,
    required this.initial,
    required this.designation,
    required this.phone,
    required this.email,
    required this.homeDepartment,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'],
        name: json['name'],
        initial: json['initial'],
        designation: json['designation'],
        phone: json['phone'],
        email: json['email'],
        homeDepartment: json['home_department'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initial': initial,
        'designation': designation,
        'phone': phone,
        'email': email,
        'home_department': homeDepartment,
      };
}
