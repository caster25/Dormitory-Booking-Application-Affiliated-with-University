// ignore_for_file: body_might_complete_normally_nullable, library_private_types_in_public_api
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationOwnerScreen extends StatefulWidget {
  const NotificationOwnerScreen({super.key});

  @override
  _NotificationOwnerScreenState createState() =>
      _NotificationOwnerScreenState();
}

class _NotificationOwnerScreenState extends State<NotificationOwnerScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    userId = await getDormitoryId();
    if (userId != null) {
      print(userId);
      _fetchNotifications();
    } else {
      print('Current User ID is null');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> getDormitoryId() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // ดึงเอกสารของผู้ใช้
    final userDoc =
        await FirebaseFirestore.instance
        .collection('dormitories')
        .doc('submittedBy')
        .get();

    if (!userDoc.exists) {
      throw Exception('User profile not found');
    }

    // ตรวจสอบว่าเอกสารมีฟิลด์ที่ต้องการ
    if (!userDoc.data()!.containsKey('submittedBy')) {
      throw Exception('Dormitory ID not found in user profile');
    }

    // ดึงค่า dormitoryId
    final dormitoryId = userDoc.get('submittedBy');

    if (dormitoryId == null) {
      throw Exception('Dormitory ID is null');
    }

    return dormitoryId;
  }

  Future<void> _fetchNotifications() async {
    try {
      print('Fetching notifications for userId: $userId');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('dormitoryId', isEqualTo: userId)
          .where('type', isEqualTo: 'booking')
          .get();

      List<Map<String, dynamic>> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(data['dormitoryId'])
            .get();

        String dormitoryName = dormitorySnapshot.exists
            ? dormitorySnapshot.get('name') ?? 'Unnamed Dormitory'
            : 'Unnamed Dormitory';

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .get();

        String userName = userSnapshot.exists
            ? userSnapshot.get('username') ?? 'Unnamed User'
            : 'Unnamed User';

        Timestamp? timestamp = data['timestamp'];
        DateTime? notificationTime;

        if (timestamp != null) {
          notificationTime = timestamp.toDate();
        }

        notifications.add({
          'dormitoryName': dormitoryName,
          'userName': userName,
          'message': data['message'] ?? 'No message',
          'timestamp': notificationTime,
        });
      }

      notifications.sort((a, b) {
        DateTime aTime =
            a['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime bTime =
            b['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(DateTime? notificationTime) {
    if (notificationTime == null) {
      return 'Unknown time';
    }
    final Duration difference = DateTime.now().difference(notificationTime);

    if (difference.inMinutes < 1) {
      return 'เพิ่งเกิดขึ้นเมื่อไม่กี่วินาทีที่แล้ว';
    } else if (difference.inMinutes == 1) {
      return 'เมื่อ 1 นาทีที่แล้ว';
    } else if (difference.inMinutes < 60) {
      return 'เมื่อ ${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours == 1) {
      return 'เมื่อ 1 ชั่วโมงที่แล้ว';
    } else if (difference.inHours < 24) {
      return 'เมื่อ ${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays == 1) {
      return 'เมื่อ 1 วันที่แล้ว';
    } else {
      return 'เมื่อ ${difference.inDays} วันที่แล้ว';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        title: const Text('Owner Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('ไม่มีการแจ้งเตือน'))
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
                                'New Booking Notification',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.home,
                                    color: Colors.blueAccent,
                                  ),
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
                                  const Icon(
                                    Icons.person,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Booked by: ${notification['userName']}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Time: ${_formatTimestamp(notification['timestamp'])}',
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
