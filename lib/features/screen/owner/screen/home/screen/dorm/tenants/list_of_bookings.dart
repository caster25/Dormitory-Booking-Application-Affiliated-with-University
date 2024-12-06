// ignore_for_file: use_build_context_synchronously


import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/widgetchat/chat_owner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfBookings extends StatelessWidget {
  final String dormitoryId;
  final String ownerId;

  // ignore: use_super_parameters
  const ListOfBookings({
    Key? key,
    required this.dormitoryId,
    required this.ownerId,
    required String chatRoomId,
  }) : super(key: key);

  Stream<List<Map<String, dynamic>>> _fetchBookings() {
    return FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .snapshots() // ใช้ snapshots แทน get
        .asyncMap((snapshot) async {
      final dormitoryData = snapshot.data();
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
          userData['userId'] = userId; // เพิ่ม userId ไปยังข้อมูลผู้ใช้
          bookings.add(userData);
        }
      }

      return bookings;
    });
  }

  void _openChat(BuildContext context, String userId) async {
    // Get user data from Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      _showSnackBar(context, 'ไม่พบข้อมูลผู้ใช้');
      return;
    }

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    // Get chatRoomIds list from userData
    List<dynamic>? userChatRoomIds = userData?['chatRoomId'];

    if (userChatRoomIds == null || userChatRoomIds.isEmpty) {
      _showSnackBar(context, 'ยังไม่มีการสนทนาในห้องนี้');
      return;
    }

    // Get dormitory data to check its chatRoomIds
    DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .get();

    if (!dormitorySnapshot.exists) {
      _showSnackBar(context, 'ไม่พบข้อมูลหอพัก');
      return;
    }

    Map<String, dynamic>? dormitoryData =
        dormitorySnapshot.data() as Map<String, dynamic>?;

    List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomId'];

    if (dormitoryChatRoomIds == null || dormitoryChatRoomIds.isEmpty) {
      _showSnackBar(context, 'ยังไม่มีการสนทนาในห้องนี้');
      return;
    }

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
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmBooking(
      BuildContext context, String dormitoryId, String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการจอง'),
        content: const Text('คุณแน่ใจว่าต้องการรับผู้เช่ารายนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              try {
                DocumentReference dormitoryRef = FirebaseFirestore.instance
                    .collection('dormitories')
                    .doc(dormitoryId);
                DocumentSnapshot dormitorySnapshot = await dormitoryRef.get();

                if (dormitorySnapshot.exists) {
                  Map<String, dynamic>? dormitoryData =
                      dormitorySnapshot.data() as Map<String, dynamic>?;

                  if (dormitoryData != null) {
                    // ตรวจสอบว่ามีฟิลด์ tenants หรือไม่ ถ้าไม่มีจะสร้างเป็น array ว่าง
                    if (!dormitoryData.containsKey('tenants')) {
                      await dormitoryRef.update({
                        'tenants': [],
                      });
                    }

                    // ตรวจสอบว่ามีฟิลด์ usersBooked หรือไม่
                    if (dormitoryData.containsKey('usersBooked')) {
                      List<dynamic> usersBooked =
                          dormitoryData['usersBooked'] as List<dynamic>;

                      // ตรวจสอบว่า userId นี้อยู่ใน usersBooked หรือไม่
                      if (usersBooked.contains(userId)) {
                        // เพิ่ม userId เข้าไปใน tenants
                        await dormitoryRef.update({
                          'tenants': FieldValue.arrayUnion(
                              [userId]), // เพิ่ม user คนเดียว
                          'usersBooked': FieldValue.arrayRemove(
                              [userId]), // ลบ user ออกจาก usersBooked
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('ไม่พบผู้ใช้ในรายการจอง')),
                        );
                        Navigator.of(context).pop();
                        return; // ออกจากฟังก์ชัน
                      }
                    }

                    // อัปเดตสถานะของผู้ใช้ในคอลเลคชัน users
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({
                      'isStaying': dormitoryId,
                      'currentDormitoryId': dormitoryId,
                      'bookedDormitory': null,
                    });

                    // เพิ่มการแจ้งเตือนเมื่อการจองสำเร็จ
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .add({
                      'userId': userId,
                      'dormitoryId': dormitoryId,
                      'type': 'confirmBooking',
                      'message': 'การจองหอพักสำเร็จ',
                      'timestamp': FieldValue.serverTimestamp(),
                      'status': 'unread', // Mark as unread initially
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('การจองสำเร็จและคุณได้ย้ายเข้าหอพักแล้ว')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('หอพักไม่พบหรือไม่มีอยู่')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('หอพักไม่พบหรือไม่มีอยู่')),
                  );
                }
              } catch (e) {
                print('เกิดข้อผิดพลาด: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('เกิดข้อผิดพลาดในการจอง')),
                );
              }
            },
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectBooking(
      BuildContext context, String dormitoryId, String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการปฏิเสธการจอง'),
        content: const Text('คุณแน่ใจว่าต้องการปฏิเสธผู้เช่ารายนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด Dialog ถ้ายกเลิก
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // ลบ userId ออกจาก usersBooked
                await FirebaseFirestore.instance
                    .collection('dormitories')
                    .doc(dormitoryId)
                    .update({
                  'usersBooked': FieldValue.arrayRemove([userId]),
                });

                // รีเซ็ตข้อมูลการจองของผู้ใช้
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'bookedDormitory': null,
                  'currentDormitoryId': null,
                });

                // เพิ่มการแจ้งเตือนเมื่อการจองสำเร็จ
                await FirebaseFirestore.instance
                    .collection('notifications')
                    .add({
                  'userId': userId,
                  'dormitoryId': dormitoryId,
                  'type': 'rejectBooking',
                  'message': 'ถูกปฏิเสธการจอง',
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': 'unread', // Mark as unread initially
                });

                DocumentSnapshot dormitorySnapshot = await FirebaseFirestore
                    .instance
                    .collection('dormitories')
                    .doc(dormitoryId)
                    .get();

                if (dormitorySnapshot.exists) {
                  Map<String, dynamic> dormitoryData =
                      dormitorySnapshot.data() as Map<String, dynamic>;

                  int availableRooms = dormitoryData['availableRooms'] ?? 0;
                  availableRooms += 1; // เพิ่มจำนวนห้องว่างขึ้น 1

                  // อัปเดตค่า availableRooms ใน Firestore
                  await FirebaseFirestore.instance
                      .collection('dormitories')
                      .doc(dormitoryId)
                      .update({'availableRooms': availableRooms});
                }

                // แสดงข้อความเมื่อปฏิเสธการจองเสร็จสิ้น
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ปฏิเสธการจองเรียบร้อยแล้ว')),
                );

                // ปิด Dialog
                Navigator.of(context).pop();
              } catch (e) {
                print('เกิดข้อผิดพลาด: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('เกิดข้อผิดพลาดในการปฏิเสธการจอง')),
                );
              }
            },
            child: const Text('ปฏิเสธ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'รายชื่อผู้จอง', context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _fetchBookings(), // ใช้ StreamBuilder แทน FutureBuilder
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('ไม่มีการจอง'));
            }

            final bookings = snapshot.data!;

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final userId = booking['userId'];

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
                              TextWidget.buildText(text: 
                                booking['username'] ?? 'ไม่มีชื่อ',fontSize: 18, isBold: true
                                
                              ),
                              const SizedBox(height: 5),
                              TextWidget.buildText(text: 
                                'อีเมล: ${booking['email'] ?? 'ไม่มีอีเมล'}',
                              ),
                              const SizedBox(height: 5),
                              TextWidget.buildText(text: 
                                'เบอร์โทรศัพท์: ${booking['numphone'] ?? 'ไม่มีเบอร์'}',
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10, // ระยะห่างระหว่างปุ่ม
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _confirmBooking(context, dormitoryId,
                                          booking['userId']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorsApp.green, // สีปุ่มยืนยัน
                                    ),
                                    child: TextWidget.buildText(text: 'ยืนยันการเข้าหอพัก'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _rejectBooking(context, dormitoryId,
                                          booking['userId']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorsApp.red, // สีปุ่มปฏิเสธ
                                    ),
                                    child: TextWidget.buildText(text: 'ปฏิเสธการจอง'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _openChat(context, booking['userId']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorsApp.blue, // สีปุ่มสนทนา
                                    ),
                                    child: TextWidget.buildText(text: 'เปิดการสนทนา'),
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
          }),
    );
  }
}
