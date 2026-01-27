class Course {
  final String code;
  final String title;

  Course({
    required this.code,
    required this.title,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        code: json['code'],
        title: json['title'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
      };
}
