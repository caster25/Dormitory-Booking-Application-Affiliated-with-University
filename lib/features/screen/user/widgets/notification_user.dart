import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
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
  List<Map<String, dynamic>> _notifications = [];
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // กำหนดค่าให้ _currentUser จาก widget.user
    _fetchNotifications();
    print(_currentUser);
  }

  Future<void> _fetchNotifications() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _currentUser.uid)
          .where('type', whereIn: ['confirmBooking', 'rejectBooking']).get();

      List<Map<String, dynamic>> notifications = [];
      print('Current User ID: ${_currentUser.uid}');
      print('Querying notifications...');

      if (snapshot.docs.isEmpty) {
        print('No notifications found.');
      }

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('dormitoryId') || !data.containsKey('userId')) {
          print('Missing dormitoryId or userId in notification: ${doc.id}');
          continue;
        }

        var dormitoryFuture = FirebaseFirestore.instance
            .collection('dormitories')
            .doc(data['dormitoryId'])
            .get();
        var userFuture = FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .get();

        final dormitorySnapshot = await dormitoryFuture;
        final userSnapshot = await userFuture;

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
        } else {
          print(
              'Dormitory or User does not exist: dormitoryId=${data['dormitoryId']}, userId=${data['userId']}');
        }
      }

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
                            notification['type'] == 'confirmBooking'
                                ? 'Booking Confirmed'
                                : 'Booking Rejected',
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
