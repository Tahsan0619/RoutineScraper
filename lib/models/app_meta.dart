class AppMeta {
  final String version;
  final String updatedAt;
  final String tz;
  final List<String> daysOff;
  final String department;
  final String university;
  final List<String> slotLabels;

  AppMeta({
    required this.version,
    required this.updatedAt,
    required this.tz,
    required this.daysOff,
    required this.department,
    required this.university,
    required this.slotLabels,
  });

  factory AppMeta.fromJson(Map<String, dynamic> json) => AppMeta(
        version: json['version'],
        updatedAt: json['updated_at'],
        tz: json['tz'],
        daysOff: (json['days_off'] as List).cast<String>(),
        department: json['department'],
        university: json['university'],
        slotLabels: (json['slot_labels'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'updated_at': updatedAt,
        'tz': tz,
        'days_off': daysOff,
        'department': department,
        'university': university,
        'slot_labels': slotLabels,
      };
}
