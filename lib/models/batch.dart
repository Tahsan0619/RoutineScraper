class Batch {
  final String id;
  final String name;
  final String session;

  Batch({
    required this.id,
    required this.name,
    required this.session,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: json['id'],
        name: json['name'],
        session: json['session'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'session': session,
      };
}
