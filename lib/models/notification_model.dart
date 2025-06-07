class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String petId;
  final String type; // 'vaccination', 'bath', 'feeding', 'checkup'
  final bool isCompleted;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.petId,
    required this.type,
    this.isCompleted = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      petId: json['petId'],
      type: json['type'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'petId': petId,
      'type': type,
      'isCompleted': isCompleted,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? scheduledTime,
    String? petId,
    String? type,
    bool? isCompleted,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
