class Teacher {
  final String id;
  final String name;
  final String initial;
  final String designation;
  final String phone;
  final String email;
  final String homeDepartment;
  final String? profilePic;
  final String? password; // Added for login (null after user changes it)
  final bool hasChangedPassword; // Track if user changed password

  Teacher({
    required this.id,
    required this.name,
    required this.initial,
    required this.designation,
    required this.phone,
    required this.email,
    required this.homeDepartment,
    this.profilePic,
    this.password,
    this.hasChangedPassword = false,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'],
        name: json['name'],
        initial: json['initial'],
        designation: json['designation'],
        phone: json['phone'],
        email: json['email'],
        homeDepartment: json['home_department'],
        profilePic: json['profile_pic'],
        password: json['password'],
        hasChangedPassword: json['has_changed_password'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initial': initial,
        'designation': designation,
        'phone': phone,
        'email': email,
        'home_department': homeDepartment,
        'profile_pic': profilePic,
        'password': password,
        'has_changed_password': hasChangedPassword,
      };
}
