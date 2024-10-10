import 'package:dorm_app/screen/owner/widget/chat_owner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfBookings extends StatelessWidget {
  final String dormitoryId;
  final String ownerId;

  const ListOfBookings({
    Key? key,
    required this.dormitoryId,
    required this.ownerId, required String chatRoomIds,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .get();

    final dormitoryData = dormitorySnapshot.data();
    if (dormitoryData == null || dormitoryData['usersBooked'] == null) {
      return [];
    }

    List<dynamic> usersBooked = dormitoryData['usersBooked'];
    List<Map<String, dynamic>> bookings = [];

    for (String userId in usersBooked) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        userData['userId'] = userId; // Add userId to user data
        bookings.add(userData);
      }
    }

    return bookings;
  }

  void _openChat(BuildContext context, String userId) async {
    // Get user data from Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Get chatRoomIds list from userData
      List<dynamic>? userChatRoomIds = userData?['chatRoomIds'];

      if (userChatRoomIds != null && userChatRoomIds.isNotEmpty) {
        // Get dormitory data to check its chatRoomIds
        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(dormitoryId)
            .get();

        if (dormitorySnapshot.exists) {
          Map<String, dynamic>? dormitoryData =
              dormitorySnapshot.data() as Map<String, dynamic>?;

          List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomIds'];

          if (dormitoryChatRoomIds != null && dormitoryChatRoomIds.isNotEmpty) {
            // Find matching chatRoomId for the current dormitory owner
            String? matchingChatRoomId;
            for (var chatRoomId in userChatRoomIds) {
              if (dormitoryChatRoomIds.contains(chatRoomId)) {
                matchingChatRoomId = chatRoomId;
                break;
              }
            }

            if (matchingChatRoomId != null) {
              // Navigate to the chat screen with the existing chatRoomId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OwnerChatScreen(
                    userId: userId,
                    ownerId: ownerId,
                    chatRoomId: matchingChatRoomId!,
                  ),
                ),
              );
            } else {
              _showSnackBar(context, 'ยังไม่มีการสนทนาในห้องนี้');
            }
          } else {
            _showSnackBar(context, 'ยังไม่มีการสนทนาในห้องนี้');
          }
        } else {
          _showSnackBar(context, 'ไม่พบข้อมูลหอพัก');
        }
      } else {
        _showSnackBar(context, 'ยังไม่มีการสนทนาในห้องนี้');
      }
    } else {
      _showSnackBar(context, 'ไม่พบข้อมูลผู้ใช้');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายชื่อผู้จอง'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีผู้จองในหอพักนี้'));
          } else {
            final bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blueAccent,
                          child:
                              Icon(Icons.person, size: 30, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['username'] ?? 'ไม่มีชื่อ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'อีเมล: ${booking['email'] ?? 'ไม่มีอีเมล'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'เบอร์โทรศัพท์: ${booking['numphone'] ?? 'ไม่มีเบอร์'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _openChat(context, booking['userId']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue, // Change color
                                    ),
                                    child: const Text('เปิดการสนทนา'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
