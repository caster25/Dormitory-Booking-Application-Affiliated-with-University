import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationOwnerScreen extends StatefulWidget {
  const NotificationOwnerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationOwnerScreenState createState() =>
      _NotificationOwnerScreenState();
}

class _NotificationOwnerScreenState extends State<NotificationOwnerScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    _loadOwnerId();
  }

  Future<void> _loadOwnerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ownerId = prefs.getString('ownerId');
    });
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: 'booking')
          .where('ownerId', isEqualTo: _ownerId) // กรองโดย ownerId
          .get();

      List<Map<String, dynamic>> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // ดึงข้อมูล dormitory โดยใช้ dormitoryId
        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(data['dormitoryId'])
            .get();

        String dormitoryName = dormitorySnapshot.exists
            ? dormitorySnapshot.get('name') ?? 'Unnamed Dormitory'
            : 'Unnamed Dormitory';

        // ดึงข้อมูล user โดยใช้ userId
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

      // จัดเรียง notifications ตามเวลา
      notifications.sort((a, b) {
        DateTime aTime =
            a['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime bTime =
            b['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      setState(() {
        _notifications = notifications;
        _isLoading =
            false; // เปลี่ยน _isLoading เป็น false หลังจากโหลดข้อมูลเสร็จ
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _isLoading = false; // เปลี่ยน _isLoading เป็น false เมื่อมีข้อผิดพลาด
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
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to details screen
                                  },
                                  child: const Text('View Details'),
                                ),
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
