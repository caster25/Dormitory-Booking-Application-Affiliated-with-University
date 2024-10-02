import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfBookings extends StatelessWidget {
  final String dormitoryId;

  // ignore: use_super_parameters
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
                      'isStaying': true,
                      'currentDormitoryId': dormitoryId,
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
                  elevation: 3, // เพิ่มเงาเพื่อให้การ์ดมีมิติมากขึ้น
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
                        // ข้อมูลผู้จอง
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
                              // ปุ่มยืนยันการจอง
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _confirmBooking(context, dormitoryId,
                                        booking['userId']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green, // สีพื้นหลังปุ่ม
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: const Text('ยืนยัน'),
                                ),
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
