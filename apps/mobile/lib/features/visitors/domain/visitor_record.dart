final class VisitorRecord {
  const VisitorRecord({
    required this.id,
    required this.name,
    required this.visitedAt,
    required this.purpose,
  });
  final String id;
  final String name;
  final DateTime visitedAt;
  final String purpose;

  factory VisitorRecord.fromJson(Map<String, dynamic> json) => VisitorRecord(
    id: json['id'] as String,
    name: json['visitor_name'] as String,
    visitedAt: DateTime.parse(json['visited_at'] as String).toLocal(),
    purpose: json['purpose'] as String,
  );
}
