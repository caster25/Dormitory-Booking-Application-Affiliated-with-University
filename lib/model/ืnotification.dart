class Notification {
  final String id;
  final String dormitoryId;
  final String message;
  final String status;
  final DateTime timestamp;
  final String type;
  final String userId;

  Notification({
    required this.id,
    required this.dormitoryId,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.type,
    required this.userId,
  });

  // สร้างจาก Map
  factory Notification.fromMap(Map<String, dynamic> data) {
    return Notification(
      id: data['id'],
      dormitoryId: data['dormitoryId'],
      message: data['message'],
      status: data['status'],
      timestamp: DateTime.parse(data['timestamp']),
      type: data['type'],
      userId: data['userId'],
    );
  }
}
