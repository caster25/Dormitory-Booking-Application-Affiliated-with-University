import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/data/src/service.dart';
import 'package:dorm_app/features/screen/user/data/src/service_dorm.dart';
import 'package:dorm_app/features/screen/user/widgets/chat_user.dart';
import 'package:flutter/material.dart';

class BookDorm extends StatefulWidget {
  final String userId;

  const BookDorm({required this.userId, super.key});

  @override
  _BookDormState createState() => _BookDormState();
}

class _BookDormState extends State<BookDorm> {
  bool _isBookingCanceled = false;
  final FirebaseServiceDorm firestoreServiceDorm = FirebaseServiceDorm();
  final FirestoreServiceUser firestoreServiceUser = FirestoreServiceUser();

  void _navigateToChat(String dormitoryId, String ownerId) async {
    DocumentSnapshot userSnapshot =
        await firestoreServiceUser.getUserData(widget.userId);

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      List<dynamic>? userChatRoomIds = userData?['chatRoomId'];

      DocumentSnapshot dormitorySnapshot =
          await firestoreServiceDorm.getOwnerDataOnce(dormitoryId);

      if (dormitorySnapshot.exists) {
        Map<String, dynamic>? dormitoryData =
            dormitorySnapshot.data() as Map<String, dynamic>?;
        List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomId'];

        if (userChatRoomIds != null &&
            dormitoryChatRoomIds != null &&
            userChatRoomIds.isNotEmpty &&
            dormitoryChatRoomIds.isNotEmpty) {
          String? matchingChatRoomId;
          for (var chatRoomId in userChatRoomIds) {
            if (dormitoryChatRoomIds.contains(chatRoomId)) {
              matchingChatRoomId = chatRoomId;
              break;
            }
          }

          if (matchingChatRoomId != null) {
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
            _showSnackBar('ยังไม่มีการสนทนาในห้องนี้');
          }
        } else {
          _showSnackBar('ยังไม่มีการสนทนาในห้องนี้');
        }
      } else {
        _showSnackBar('ไม่พบข้อมูลหอพัก');
      }
    } else {
      _showSnackBar('ไม่พบข้อมูลผู้ใช้');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: Column(
                    children: [
                      ListTile(
                        leading: imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(
                          dormName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          'ราคา: ฿${price.toStringAsFixed(2)} บาท/เทอม',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (!_isBookingCanceled) ...[
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog(
                                context, bookedDormId); // ยกเลิกการจอง
                          },
                          child: const Text('ยกเลิกการจอง'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _navigateToChat(bookedDormId, ownerId);
                          },
                          child: const Text('คุยกับเจ้าของหอพัก'),
                        ),
                      ],
                    ],
                  ),
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
          title: TextWidget.buildText(text: 'ยืนยันการยกเลิก'),
          content: TextWidget.buildText(text: 'แน่ใจหรือไม่ว่าต้องการยกเลิกการจอง'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _cancelBooking(context, bookedDormitoryId);
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
      await firestoreServiceUser.updateUserData(widget.userId, {
        'bookedDormitory': null,
      });
      await firestoreServiceDorm.updateDormitory(bookedDormitoryId, {
        'availableRooms': FieldValue.increment(1),
        'usersBooked': null,
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.userId,
        'dormitoryId': bookedDormitoryId,
        'type': 'cancellation',
        'message': 'คุณได้ยกเลิกการจองหอพัก',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
      });

      _showSnackBar('ยกเลิกการจองหอพักเรียบร้อยแล้ว');

      setState(() {
        _isBookingCanceled = true;
      });
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาด: ${error.toString()}');
    }
  }
}
