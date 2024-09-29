import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfBookings extends StatelessWidget {
  final String dormitoryId;

  const ListOfBookings({Key? key, required this.dormitoryId}) : super(key: key);

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
        bookings.add(userSnapshot.data() as Map<String, dynamic>);
      }
    }

    return bookings;
  }

  Future<void> _confirmBooking(
      BuildContext context, String dormitoryId, String userId) async {
    // แสดง AlertDialog เพื่อยืนยันการจอง
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการจอง'),
        content: const Text('คุณแน่ใจว่าต้องการจองหอพักนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด Dialog ถ้ายกเลิก
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              // ไม่ปิด Dialog ทันที
              try {
                DocumentReference dormitoryRef = FirebaseFirestore.instance
                    .collection('dormitories')
                    .doc(dormitoryId);

                // ดึงข้อมูลเอกสารของหอพัก
                DocumentSnapshot dormitorySnapshot = await dormitoryRef.get();

                // ตรวจสอบว่าเอกสารนี้มีอยู่และมีข้อมูลหรือไม่
                if (dormitorySnapshot.exists) {
                  Map<String, dynamic>? dormitoryData =
                      dormitorySnapshot.data() as Map<String, dynamic>?;

                  // ตรวจสอบว่ามีฟิลด์ 'tenants' หรือไม่
                  if (dormitoryData == null ||
                      !dormitoryData.containsKey('tenants')) {
                    // ถ้าไม่มีฟิลด์ 'tenants' ให้สร้างฟิลด์นี้ขึ้นมาเป็นลิสต์ว่าง
                    await dormitoryRef.update({
                      'tenants': [],
                    });
                  }

                  // เพิ่ม userId เข้าไปในลิสต์ tenants
                  await dormitoryRef.update({
                    'tenants': FieldValue.arrayUnion([userId]),
                  });

                  // อัปเดตสถานะของผู้ใช้ว่ากำลังพักอาศัยในหอพักนี้
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({
                    'isStaying': true,
                    'currentDormitoryId':
                        dormitoryId, // เก็บข้อมูลหอพักที่ผู้ใช้กำลังพักอยู่
                  });

                  // แสดงข้อความยืนยันการจอง
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('การจองสำเร็จและคุณได้ย้ายเข้าหอพักแล้ว')),
                  );

                  // ปิด Dialog หลังจากการจองสำเร็จ
                  Navigator.of(context).pop();
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
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                        Text('อีเมล: ${booking['email'] ?? 'ไม่มีอีเมล'}'),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            try {
                              // Your booking confirmation logic here
                            } catch (e) {
                              print(
                                  'Error occurred: $e'); // Log the error for debugging
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('เกิดข้อผิดพลาดในการจอง')),
                              );
                            }
                          },
                          child: const Text('ยืนยัน'),
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
