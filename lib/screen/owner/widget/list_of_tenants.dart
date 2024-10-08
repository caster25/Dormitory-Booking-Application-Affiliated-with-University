import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/model/Dormitory.dart';

class ListOfTenants extends StatelessWidget {
  final String dormitoryId;

  // ignore: use_super_parameters
  const ListOfTenants({Key? key, required this.dormitoryId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchTenants() async {
    final dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .get();

    final dormitoryData = dormitorySnapshot.data();

    if (dormitoryData == null || dormitoryData['tenants'] == null) {
      return [];
    }

    List<dynamic> tenants = dormitoryData['tenants'];

    List<Map<String, dynamic>> tenantsList = [];
    for (String tenantId in tenants) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(tenantId)
          .get();
      if (userSnapshot.exists) {
        tenantsList.add(userSnapshot.data() as Map<String, dynamic>);
      }
    }
    return tenantsList;
  }

   Future<void> _cancelBooking(String tenantId) async {
    // อัปเดต currentDormitoryId ของผู้เช่าเป็น null
    await FirebaseFirestore.instance
        .collection('users')
        .doc(tenantId)
        .update({'currentDormitoryId': null,
        'isStaying': null});

    // ลบ tenantId ออกจาก tenants array ของ dormitory
    await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .update({
      'tenants': FieldValue.arrayRemove([tenantId],
      )
    });

    DocumentSnapshot dormitoriesSnapshot = await FirebaseFirestore.instance
    .collection('dormitories')
    .doc(dormitoryId)
    .get();

    Dormitory dormitory = Dormitory.fromFirestore(dormitoriesSnapshot.data() as Map<String, dynamic> , dormitoryId);

    await FirebaseFirestore.instance
    .collection('dormitories')
    .doc(dormitoryId)
    .update({'availableRooms': dormitory.availableRooms +1 });
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
          title: const Text('ยืนยันการยกเลิก'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('กรุณาใส่รหัสผ่านเพื่อยืนยันการยกเลิก'),
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
                  // รหัสผ่านถูกต้อง ทำการยกเลิกการเช่า
                  await _cancelBooking(tenantId);
                  Navigator.of(context).pop(); // ปิด Dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('การยกเลิกเสร็จสมบูรณ์')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายชื่อผู้เช่า'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTenants(),
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
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blueAccent,
                          child:
                              Icon(Icons.person, size: 30, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        // ข้อมูลผู้เช่า
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenant['username'] ?? 'ไม่มีชื่อ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'อีเมล: ${tenant['email'] ?? 'ไม่มีอีเมล'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'เบอร์โทรศัพท์: ${tenant['numphone'] ?? 'ไม่มีเบอร์'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            // แสดง Dialog ให้ผู้ใช้กรอกรหัสผ่านเพื่อยืนยันการยกเลิก
                            _showPasswordDialog(context, tenantId);
                          },
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
