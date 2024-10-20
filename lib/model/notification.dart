import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String dormitoryId;
  final String message;
  final String status;
  final Timestamp timestamp;
  final String type;
  final String userId;

  NotificationModel({
    required this.id,
    required this.dormitoryId,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.type,
    required this.userId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      dormitoryId: data['dormitoryId'],
      message: data['message'],
      status: data['status'],
      timestamp: data['timestamp'],
      type: data['type'],
      userId: data['userId'],
    );
  }
}
