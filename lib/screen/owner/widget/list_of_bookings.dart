import 'package:dorm_app/screen/user/widgets/chat.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfBookings extends StatelessWidget {
  final String dormitoryId;
  final String ownerId;

  const ListOfBookings({Key? key, required this.dormitoryId, required this.ownerId}) : super(key: key);

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
        userData['userId'] = userId; // เพิ่ม userId ลงในข้อมูลของ user
        bookings.add(userData);
      }
    }

    return bookings;
  }

  Future<void> _confirmBooking(
      BuildContext context, String dormitoryId, String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการจอง'),
        content: const Text('คุณแน่ใจว่าต้องการจองหอพักนี้หรือไม่?'),
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
                    if (!dormitoryData.containsKey('tenants')) {
                      await dormitoryRef.update({
                        'tenants': [],
                      });
                    }

                    if (dormitoryData.containsKey('usersBooked')) {
                      List<dynamic> usersBooked =
                          dormitoryData['usersBooked'] as List<dynamic>;

                      await dormitoryRef.update({
                        'tenants': FieldValue.arrayUnion(usersBooked),
                        'usersBooked':
                            FieldValue.delete(), // ลบฟิลด์ usersBooked
                      });
                    }

                    await dormitoryRef.update({
                      'tenants': FieldValue.arrayUnion([userId]),
                    });

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({
                      'isStaying': dormitoryId,
                      'currentDormitoryId': dormitoryId,
                      'bookedDormitory': null
                    });

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('การจองสำเร็จและคุณได้ย้ายเข้าหอพักแล้ว')),
                    );

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('หอพักไม่พบหรือไม่มีอยู่')),
                    );
                  }
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('หอพักไม่พบหรือไม่มีอยู่')),
                  );
                }
              } catch (e) {
                print('เกิดข้อผิดพลาด: $e');
                // ignore: use_build_context_synchronously
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
    // แสดง AlertDialog เพื่อยืนยันการปฏิเสธการจอง
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการปฏิเสธการจอง'),
        content: const Text('คุณแน่ใจว่าต้องการปฏิเสธการจองนี้หรือไม่?'),
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
                  'usersBooked': FieldValue.arrayRemove([userId])
                });

                // รีเซ็ตข้อมูลการจองของผู้ใช้
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'bookedDormitory': null,
                  'currentDormitoryId': null,
                });

                // ดึงข้อมูล dormitory จาก Firestore และเพิ่มค่า availableRooms ขึ้น 1
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

                  // แสดงข้อความสำเร็จ
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('การจองถูกปฏิเสธและเพิ่มจำนวนห้องว่างแล้ว')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ไม่พบหอพักที่ต้องการ')),
                  );
                }
              } catch (e) {
                print('เกิดข้อผิดพลาด: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('เกิดข้อผิดพลาดในการปฏิเสธการจอง')),
                );
              }

              // ปิด Dialog หลังการยืนยันเสร็จสิ้น
              Navigator.of(context).pop();
            },
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
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
                  final String chatRoomId =
                      '${booking['userId']}_$ownerId'; // Define chatRoomId here
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
                            child: Icon(Icons.person,
                                size: 30, color: Colors.white),
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
                                        _openChat(context, booking['userId'],
                                            ownerId, chatRoomId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: const Text('แชท'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _confirmBooking(context,
                                            dormitoryId, booking['userId']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: const Text('ยืนยัน'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _rejectBooking(context,
                                            dormitoryId, booking['userId']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: const Text('ไม่อนุมัติ'),
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
                });
          }
        },
      ),
    );
  }
}

void _openChat(
    BuildContext context, String userId, String ownerId, String chatRoomId) {
  // เปิดหน้าจอแชท (ตัวอย่างนี้ใช้ Navigator เพื่อไปยังหน้า Chat)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
          userId: userId,
          ownerId: ownerId,
          chatRoomId: chatRoomId), // ส่ง userId, ownerId, และ chatRoomId
    ),
  );
}
