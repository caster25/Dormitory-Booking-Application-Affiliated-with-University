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

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      // ดึงข้อมูลการแจ้งเตือนจากคอลเล็กชัน notifications
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('type',
              isEqualTo: 'booking') // กรองเฉพาะการแจ้งเตือนประเภท booking
          .get();

      List<Map<String, dynamic>> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // ดึงข้อมูล dormitory และ user เพิ่มเติม
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

          // ดึงข้อมูล timestamp
          Timestamp? timestamp = data['timestamp'];
          DateTime? notificationTime;

          // ตรวจสอบว่ามีค่า timestamp หรือไม่
          if (timestamp != null) {
            notificationTime = timestamp.toDate(); // แปลงเป็น DateTime
          }

          notifications.add({
            'dormitoryName': dormitoryName,
            'userName': userName,
            'message': data['message'] ?? 'No message',
            'timestamp': notificationTime, // อาจเป็น null
          });
        }
      }

      // เรียงลำดับ notifications ตาม timestamp โดยให้ล่าสุดอยู่บนสุด
      notifications.sort((a, b) {
        // ตรวจสอบว่า timestamp ไม่เป็น null ก่อนการเปรียบเทียบ
        DateTime aTime =
            a['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime bTime =
            b['timestamp'] ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // ให้ล่าสุดอยู่บนสุด
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
      return 'Unknown time'; // ถ้า notificationTime เป็น null
    }

    // รูปแบบวันที่และเวลา
    return '${notificationTime.day}/${notificationTime.month}/${notificationTime.year} ${notificationTime.hour}:${notificationTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Notifications'),
      ),
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
                                // ฟังก์ชันเมื่อกดปุ่ม (สามารถเพิ่มการทำงานได้ตามต้องการ)
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
