import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationOwnerScreen extends StatefulWidget {
  final User user; // รับค่า User จาก constructor

  const NotificationOwnerScreen({super.key, required this.user});

  @override
  _NotificationOwnerScreenState createState() =>
      _NotificationOwnerScreenState();
}

class _NotificationOwnerScreenState extends State<NotificationOwnerScreen> {
  List<Map<String, dynamic>> _notifications = [];
  List<String> _dormitoryIds = []; // เก็บ dormitoryIds ของหอพักที่เป็นของเจ้าของหอ
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // กำหนดค่าให้ _currentUser จาก widget.user
    _fetchDormitoriesForOwner(); // ดึงหอพักที่เจ้าของหอนั้นเป็นเจ้าของ
  }

  Future<void> _fetchDormitoriesForOwner() async {
    try {
      // ดึงหอพักที่ submittedBy ตรงกับเจ้าของหอ
      QuerySnapshot dormitoriesSnapshot = await FirebaseFirestore.instance
          .collection('dormitories')
          .where('submittedBy', isEqualTo: _currentUser.uid)
          .get();

      List<String> dormitoryIds = dormitoriesSnapshot.docs
          .map((doc) => doc.id) // เก็บ id ของหอพักที่พบ
          .toList();

      setState(() {
        _dormitoryIds = dormitoryIds; // เก็บ dormitoryIds ใน state
      });

      // หลังจากดึงหอพักแล้ว ดึงการแจ้งเตือนที่เกี่ยวข้อง
      _fetchNotifications();
    } catch (e) {
      print('Error fetching dormitories: $e');
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      // ตรวจสอบว่าเจ้าของหอนี้มีหอพักไหนบ้าง และดึงการแจ้งเตือนที่เกี่ยวข้องกับหอพักเหล่านั้น
      if (_dormitoryIds.isEmpty) {
        return; // ถ้าไม่มีหอพัก ไม่ต้องดึงการแจ้งเตือน
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('dormitoryId',
              whereIn:
                  _dormitoryIds) // ค้นหาแจ้งเตือนที่ตรงกับหอพักของเจ้าของหอ
          .where('type', whereIn: [
        'booking',
        'cancellation'
      ]) // เพิ่ม 'cancellation' เพื่อดึงการยกเลิกด้วย
          .get();

      List<Map<String, dynamic>> notifications = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Fetched notification data: $data'); // ตรวจสอบข้อมูลที่ดึงมา

        // Fetch dormitory and user details
        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(data['dormitoryId'])
            .get();
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .get();

        if (dormitorySnapshot.exists && userSnapshot.exists) {
          String dormitoryName =
              dormitorySnapshot.get('name') ?? 'Unnamed Dormitory';
          String userName = userSnapshot.get('username') ?? 'Unnamed User';

          // Fetch timestamp
          Timestamp timestamp = data['timestamp'];
          DateTime notificationTime = timestamp.toDate();

          notifications.add({
            'dormitoryName': dormitoryName,
            'userName': userName,
            'message': data['message'] ?? 'No message',
            'timestamp': notificationTime,
            'type': data['type'], // เพิ่ม type เพื่อให้ใช้ในการแสดงผล
            'reason': data['reason'] ?? '', // เหตุผลในการยกเลิก ถ้ามี
          });
        } else {
          print('Dormitory or User does not exist');
        }
      }

      // เรียงลำดับการแจ้งเตือนตามเวลาล่าสุด
      notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  String _timeAgo(DateTime notificationTime) {
    final now = DateTime.now();
    final difference = now.difference(notificationTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'การแจ้งเตือน', context: context),
      body: _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
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
                            notification['type'] == 'booking'
                                ? 'New Booking Notification'
                                : 'Cancellation Notification', // ตรวจสอบว่าเป็นการจองหรือการยกเลิก
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: notification['type'] == 'booking'
                                  ? Colors.green // สีสำหรับการจอง
                                  : Colors.red, // สีสำหรับการยกเลิก
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.home, color: Colors.blueAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Dormitory: ${notification['dormitoryName']}',
                                  style: const TextStyle(fontSize: 16),
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
                                child: Text(
                                  'User: ${notification['userName']}',
                                  style: const TextStyle(fontSize: 16),
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
                                child: Text(
                                  'Time: ${_timeAgo(notification['timestamp'])}',
                                  style: const TextStyle(fontSize: 16),
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
            ),
    );
  }
}
