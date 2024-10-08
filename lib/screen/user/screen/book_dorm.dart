import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/user/widgets/chat_user.dart';
import 'package:flutter/material.dart';

class BookDorm extends StatefulWidget {
  final String userId; // Accept userId through constructor

  const BookDorm({required this.userId, super.key});

  @override
  _BookDormState createState() => _BookDormState();
}

class _BookDormState extends State<BookDorm> {
  bool _isBookingCanceled =
      false; // State variable to track booking cancellation

  // Function to navigate to chat screen
  void _navigateToChat(String dormitoryId, String ownerId) async {
    // Get user data from Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userSnapshot.exists) {
      // Cast the data to a Map<String, dynamic>
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Get the chatRoomIds list from userData
      List<dynamic>? userChatRoomIds = userData?['chatRoomIds'];

      if (userChatRoomIds != null && userChatRoomIds.isNotEmpty) {
        // Get dormitory data to check its chatRoomIds
        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(dormitoryId)
            .get();

        if (dormitorySnapshot.exists) {
          // Cast the data to a Map<String, dynamic>
          Map<String, dynamic>? dormitoryData =
              dormitorySnapshot.data() as Map<String, dynamic>?;

          // Get the chatRoomIds from dormitory data
          List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomIds'];

          if (dormitoryChatRoomIds != null && dormitoryChatRoomIds.isNotEmpty) {
            // Find the matching chatRoomId that belongs to the current dormitory owner
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
                  builder: (context) => ChatScreen(
                    userId: widget.userId,
                    ownerId: ownerId,
                    chatRoomId: matchingChatRoomId!, // Pass the found chatRoomId
                  ),
                ),
              );
            } else {
              // If no matching chatRoomId found, show a message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ยังไม่มีการสนทนาในห้องนี้')),
              );
            }
          } else {
            // If dormitory chatRoomIds is empty, show a message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ยังไม่มีการสนทนาในห้องนี้')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่พบข้อมูลหอพัก')),
          );
        }
      } else {
        // If user chatRoomIds is empty, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ยังไม่มีการสนทนาในห้องนี้')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หอพักที่คุณจองไว้'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId) // Use the userId that is passed
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('คุณยังไม่ได้จองหอพักใด ๆ'));
          }

          String? bookedDormId = snapshot.data!.get('bookedDormitory');

          // Check if bookedDormId is null or empty and return appropriate message
          if (bookedDormId == null || bookedDormId.isEmpty) {
            return const Center(child: Text('คุณยังไม่ได้จองหอพักใด ๆ'));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('dormitories')
                .doc(bookedDormId)
                .snapshots(),
            builder: (context, dormSnapshot) {
              if (dormSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (dormSnapshot.hasError) {
                return const Center(
                    child: Text('เกิดข้อผิดพลาดในการดึงข้อมูลหอพัก'));
              }

              if (!dormSnapshot.hasData || !dormSnapshot.data!.exists) {
                return const Center(child: Text('ไม่พบข้อมูลหอพัก'));
              }

              var dormData = dormSnapshot.data!.data() as Map<String, dynamic>;
              String dormName = dormData['name'] ?? 'ไม่มีชื่อ';
              double price = dormData['price']?.toDouble() ?? 0;
              String imageUrl = dormData['imageUrl'];
              String ownerId =
                  dormData['submittedBy'] ?? ''; // Get ownerId from dormData

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, size: 50),
                      title: Text(
                        dormName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text('ราคา: ฿${price.toStringAsFixed(2)} บาท/เดือน'),
                    ),
                    // Render button only if the booking is not canceled
                    if (!_isBookingCanceled)
                      ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext content) {
                              return AlertDialog(
                                title: const Text('ยืนยันการยกเลิก'),
                                content: const Text(
                                    'แน่ใจหรือไม่ว่าต้องการยกเลิกการจอง'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(content).pop();
                                    },
                                    child: const Text('ยกเลิก'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userId)
                                          .update({'bookedDormitory': null});

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'ยกเลิกการจองหอพักเรียบร้อยแล้ว'),
                                        ),
                                      );

                                      // Set the state to indicate the booking has been canceled
                                      setState(() {
                                        _isBookingCanceled = true;
                                      });

                                      Navigator.of(content).pop();
                                    },
                                    child: const Text('ยืนยัน'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('ยกเลิกการจองแล้ว'),
                      ),
                    // Button to navigate to chat screen
                    if (!_isBookingCanceled)
                      ElevatedButton(
                        onPressed: () {
                          _navigateToChat(
                              bookedDormId, ownerId); // Navigate to chat screen
                        },
                        child: const Text('คุยกับเจ้าของหอพัก'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
