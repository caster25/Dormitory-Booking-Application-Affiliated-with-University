import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationUserScreen extends StatefulWidget {
  final User user; // รับค่า User จาก constructor

  const NotificationUserScreen({super.key, required this.user});

  @override
  _NotificationUserScreenState createState() => _NotificationUserScreenState();
}

class _NotificationUserScreenState extends State<NotificationUserScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // กำหนดค่าให้ _currentUser จาก widget.user
  }

  Stream<List<Map<String, dynamic>>> _fetchNotificationsStream() async* {
    final notificationQuery = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('type', whereIn: ['confirmBooking', 'rejectBooking']);

    await for (QuerySnapshot snapshot in notificationQuery.snapshots()) {
      List<Map<String, dynamic>> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('dormitoryId') || !data.containsKey('userId')) {
          continue;
        }

        var dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(data['dormitoryId'])
            .get();
        var userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .get();

        if (dormitorySnapshot.exists && userSnapshot.exists) {
          String dormitoryName =
              dormitorySnapshot.get('name') ?? 'Unnamed Dormitory';
          String userName = userSnapshot.get('username') ?? 'Unnamed User';

          Timestamp timestamp = data['timestamp'];
          DateTime notificationTime = timestamp.toDate();

          notifications.add({
            'dormitoryName': dormitoryName,
            'userName': userName,
            'message': data['message'] ?? 'No message',
            'timestamp': notificationTime,
            'type': data['type'],
          });
        }
      }

      notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      yield notifications;
    }
  }

  String _timeAgo(DateTime notificationTime) {
    final now = DateTime.now();
    final difference = now.difference(notificationTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} วันก่อน';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงก่อน';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เพิ่งเกิดขึ้น';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'การแจ้งเตือน', context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: TextWidget.buildText(text: 'ไม่มีการแจ้งเตือน'),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 6.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['type'] == 'confirmBooking'
                              ? 'การจองสำเร็จ'
                              : 'การจองถูกปฏิเสธ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: notification['type'] == 'confirmBooking'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.home, color: Colors.blueAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextWidget.buildText(
                                text:
                                    'หอพัก: ${notification['dormitoryName']}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextWidget.buildText(
                                text: 'ผู้ใช้: ${notification['userName']}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextWidget.buildText(
                                text:
                                    'เวลา: ${_timeAgo(notification['timestamp'])}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
