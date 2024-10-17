// ignore_for_file: use_build_context_synchronously

import 'package:dorm_app/screen/owner/widget/chat_owner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/model/Dormitory.dart';

class ListOfTenants extends StatelessWidget {
  final String dormitoryId;

  const ListOfTenants({Key? key, required this.dormitoryId}) : super(key: key);

  Stream<List<Map<String, dynamic>>> _fetchTenantsStream() {
    return FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .snapshots()
        .asyncMap((dormitorySnapshot) async {
      final dormitoryData = dormitorySnapshot.data();

      if (dormitoryData == null || dormitoryData['tenants'] == null) {
        return [];
      }

      List<dynamic> tenants = dormitoryData['tenants'];

      // สร้างรายการผู้เช่า
      List<Map<String, dynamic>> tenantsList = [];
      for (String tenantId in tenants) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(tenantId)
            .get();

        if (userSnapshot.exists) {
          tenantsList.add({
            'iduser': userSnapshot.id, // หรือ tenantId
            ...userSnapshot.data() as Map<String, dynamic>,
          });
        }
      }

      return tenantsList;
    });
  }

  Future<void> _removeTenant(String tenantId) async {
    // อัปเดต currentDormitoryId ของผู้เช่าเป็น null
    await FirebaseFirestore.instance
        .collection('users')
        .doc(tenantId)
        .update({'currentDormitoryId': null, 'isStaying': null});

    // ลบ tenantId ออกจาก tenants array ของ dormitory
    await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .update({
      'tenants': FieldValue.arrayRemove([tenantId]),
    });

    // อัปเดตจำนวนห้องว่าง
    DocumentSnapshot dormitoriesSnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .get();

    Dormitory dormitory = Dormitory.fromFirestore(
        dormitoriesSnapshot.data() as Map<String, dynamic>, dormitoryId);

    await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .update({'availableRooms': dormitory.availableRooms + 1});
  }

  Future<bool> _verifyPassword(String password) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );

      await currentUser.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showPasswordDialog(BuildContext context, String tenantId) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('กรุณาใส่รหัสผ่านเพื่อยืนยันการลบผู้เช่า'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                // ตรวจสอบรหัสผ่าน
                bool isPasswordCorrect =
                    await _verifyPassword(passwordController.text);
                if (isPasswordCorrect) {
                  // รหัสผ่านถูกต้อง ทำการลบผู้เช่า
                  await _removeTenant(tenantId);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ลบผู้เช่าสำเร็จ')),
                  );
                } else {
                  // รหัสผ่านไม่ถูกต้อง แสดงข้อผิดพลาด
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('รหัสผ่านไม่ถูกต้อง')),
                  );
                }
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
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
            ownerId: 'ownerId', // เปลี่ยนเป็น ID ของเจ้าของหอพักที่เหมาะสม
            chatRoomId: matchingChatRoomId!,
          ),
        ),
      );
    } else {
      _showSnackBar(context, 'ยังไม่มีการสนทนาในห้องนี้');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        title: const Text('รายชื่อผู้เช่า'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchTenantsStream(), // สร้าง stream สำหรับข้อมูลผู้เช่า
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีผู้เช่าในหอพักนี้'));
          } else {
            final tenants = snapshot.data!;
            return ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenants[index];
                final tenantId = tenant['iduser'];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // รูปประจำตัวผู้เช่า (ตัวอย่าง: Icon)
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              tenant['profilePictureURL'] != null &&
                                      tenant['profilePictureURL'].isNotEmpty
                                  ? NetworkImage(tenant['profilePictureURL'])
                                  : null, // ใช้ backgroundImage เพื่อแสดงรูปภาพ
                          child: tenant['profilePictureURL'] == null ||
                                  tenant['profilePictureURL'].isEmpty
                              ? const Icon(
                                  Icons.person, // แสดงไอคอนผู้ใช้แทน
                                  size: 30,
                                  color: Colors.white,
                                )
                              : null, // ถ้ามีรูปภาพก็ไม่แสดงไอคอน
                        ),

                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tenant['fullname']}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                tenant['email'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _openChat(context, tenantId);
                                    },
                                    child: const Text('ข้อความ'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showPasswordDialog(context, tenantId);
                                    },
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
