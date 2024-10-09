import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dorm_app/screen/user/widgets/chat.dart';
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
  void _navigateToChat(String dormitoryId, String ownerId) {
    // Create chatRoomId using userId and ownerId
    String chatRoomId = _createChatRoomId(widget.userId, ownerId);

    // Replace this with your actual chat screen implementation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userId: widget.userId,
          ownerId: ownerId,
          chatRoomId: chatRoomId, // Pass chatRoomId
        ),
      ),
    );
  }

  // Function to create chatRoomId
  String _createChatRoomId(String userId, String ownerId) {
    var bytes = utf8.encode('$userId$ownerId');
    var digest = sha256.convert(bytes);
    return digest.toString(); // Return chatRoomId
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
