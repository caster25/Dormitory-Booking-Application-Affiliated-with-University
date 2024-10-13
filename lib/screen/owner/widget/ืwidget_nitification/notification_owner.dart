import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationOwnerScreen extends StatefulWidget {
  const NotificationOwnerScreen({super.key});

  @override
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
          .get();

      List<Map<String, dynamic>> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // ดึงข้อมูลหอพักที่เกี่ยวข้อง
        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(data['dormitoryId'])
            .get();

        // ตรวจสอบว่าหอพักมีอยู่จริงหรือไม่
        if (dormitorySnapshot.exists) {
          String dormitoryName =
              dormitorySnapshot.get('name') ?? 'Unnamed Dormitory';

          // ดึงข้อมูล ownerId จากหอพัก
          String ownerId = dormitorySnapshot.get('ownerId') ?? 'Unknown Owner';

          // ดึงข้อมูลผู้ใช้ที่เป็นเจ้าของ
          DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(ownerId)
              .get();

          String userName = ownerSnapshot.get('username') ?? 'Unnamed User';

          // ดึงข้อมูล timestamp
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
      }

      // เรียงลำดับ notifications ตาม timestamp โดยให้ล่าสุดอยู่บนสุด
      notifications.sort((a, b) {
        DateTime aTime =
            a['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime bTime =
            b['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
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
                                  Icon(
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
                                  Icon(
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
                                  Icon(
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
