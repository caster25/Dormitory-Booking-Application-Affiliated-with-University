// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/data/src/service.dart';
import 'package:dorm_app/features/screen/user/data/src/service_dorm.dart';
import 'package:dorm_app/features/screen/user/widgets/chat_user.dart';
import 'package:flutter/material.dart';

class BookDorm extends StatefulWidget {
  final String userId; // Accept userId through constructor

  BookDorm({required this.userId, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookDormState createState() => _BookDormState();
}

class _BookDormState extends State<BookDorm> {
  bool _isBookingCanceled =
      false; // State variable to track booking cancellation
  final FirebaseServiceDorm firestoreServiceDorm = FirebaseServiceDorm();
  final FirestoreServiceUser firestoreServiceUser = FirestoreServiceUser();

  // Function to navigate to chat screen
  // Inside your _navigateToChat function
  void _navigateToChat(String dormitoryId, String ownerId) async {
    // Get user data from Firestore
    DocumentSnapshot userSnapshot =
        await firestoreServiceUser.getUserData(widget.userId);

    if (userSnapshot.exists) {
      // Cast the data to a Map<String, dynamic>
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Get the chatRoomIds list from userData
      List<dynamic>? userChatRoomIds = userData?['chatRoomId'];

      // Get dormitory data to check its chatRoomIds
      DocumentSnapshot dormitorySnapshot =
          await firestoreServiceDorm.getOwnerDataOnce(dormitoryId);
      if (dormitorySnapshot.exists) {
        // Cast the data to a Map<String, dynamic>
        Map<String, dynamic>? dormitoryData =
            dormitorySnapshot.data() as Map<String, dynamic>?;

        // Get the chatRoomIds from dormitory data
        List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomId'];

        if (userChatRoomIds != null &&
            userChatRoomIds.isNotEmpty &&
            dormitoryChatRoomIds != null &&
            dormitoryChatRoomIds.isNotEmpty) {
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
                  dormitoryId: dormitoryId,
                  chatRoomId: matchingChatRoomId!,
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
          // If either chatRoomIds is empty, show a message
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'หอพักที่คุณจองไว้', context: context),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestoreServiceUser.getUserStream(widget.userId),
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

          if (bookedDormId == null || bookedDormId.isEmpty) {
            return const Center(child: Text('คุณยังไม่ได้จองหอพักใด ๆ'));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: firestoreServiceDorm.getDormData(bookedDormId),
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

              List<dynamic> imageUrls = dormData['imageUrl'] ?? [];
              String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

              String ownerId = dormData['submittedBy'] ?? '';

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
                          Text('ราคา: ฿${price.toStringAsFixed(2)} บาท/เทอม'),
                    ),
                    // Render button only if the booking is not canceled
                    if (!_isBookingCanceled) ...[
                      ElevatedButton(
                        onPressed: () async {
                          DocumentSnapshot userDoc = await firestoreServiceUser
                              .getUserData(widget.userId);
                          String bookedDormitoryId = userDoc['bookedDormitory'];
                          _showConfirmationDialog(context,
                              bookedDormitoryId); // เรียก Dialog ยืนยันการยกเลิก
                        },
                        child: const Text('ยกเลิกการจอง'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _navigateToChat(
                              bookedDormId, ownerId); // ไปยังหน้าจอแชท
                        },
                        child: const Text('คุยกับเจ้าของหอพัก'),
                      ),
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String bookedDormitoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget.buildHeader24('ยืนยันการยกเลิก'),
          content: TextWidget.buildSubSection16('แน่ใจหรือไม่ว่าต้องการยกเลิกการจอง'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog เมื่อเลือกยกเลิก
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // ปิด Dialog หลังจากการกดยืนยัน
                await _cancelBooking(
                    context, bookedDormitoryId); // เรียกฟังก์ชันยกเลิกการจอง
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(
      BuildContext context, String bookedDormitoryId) async {
    try {
      // อัปเดตข้อมูลใน Firestore
      await firestoreServiceUser.updateUserData(widget.userId, {
        'bookedDormitory': null,
      });
      await firestoreServiceDorm.updateDormitory(bookedDormitoryId, {
        'availableRooms': FieldValue.increment(1),
        'usersBooked': null,
      });

      // บันทึกการแจ้งเตือน
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.userId,
        'dormitoryId': bookedDormitoryId,
        'type': 'cancellation',
        'message': 'คุณได้ยกเลิกการจองหอพัก',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
      });

      // แสดง SnackBar แจ้งเตือนสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ยกเลิกการจองหอพักเรียบร้อยแล้ว'),
        ),
      );

      // อัปเดตสถานะ
      setState(() {
        _isBookingCanceled = true;
      });
    } catch (error) {
      // แสดง SnackBar เมื่อเกิดข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${error.toString()}'),
        ),
      );
    }
  }
}
