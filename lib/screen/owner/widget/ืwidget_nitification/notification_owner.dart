import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
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
          .where('ownerId', isEqualTo: _ownerId) // หากต้องการกรองโดย ownerId
          .get();

      List<Map<String, dynamic>> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(data['dormitoryId'])
            .get();

        if (dormitorySnapshot.exists) {
          String dormitoryName =
              dormitorySnapshot.get('name') ?? 'Unnamed Dormitory';

          Map<String, dynamic>? dormitoryData =
              dormitorySnapshot.data() as Map<String, dynamic>?;

          String ownerId =
              dormitoryData != null && dormitoryData.containsKey('ownerId')
                  ? dormitoryData['ownerId']
                  : 'Unknown Owner';

          DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(ownerId)
              .get();

          if (ownerSnapshot.exists) {
            // ตรวจสอบว่ามีเอกสารผู้ใช้หรือไม่
            String userName = ownerSnapshot.get('username') ?? 'Unnamed User';
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
          } else {
            // ถ้าไม่พบผู้ใช้ ให้เพิ่มข้อมูลที่ไม่มีชื่อผู้ใช้
            notifications.add({
              'dormitoryName': dormitoryName,
              'userName': 'Unnamed User', // หรือข้อความที่คุณต้องการ
              'message': data['message'] ?? 'No message',
              'timestamp': null,
            });
          }
        }
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
    return DateFormat('dd/MM/yyyy HH:mm').format(notificationTime);
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
