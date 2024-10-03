import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookDorm extends StatelessWidget {
  final String userId; // เพิ่มการรับค่า userId ผ่าน constructor

  const BookDorm({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หอพักที่คุณจองไว้'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // ใช้ userId ที่ถูกส่งเข้ามา
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
                                            .doc(userId)
                                            .update({'bookedDormitory': null});

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'ยกเลิกการจองหอพักเรียบร้อยแล้ว'),
                                          ),
                                        );
                                        Navigator.of(content).pop();
                                      },
                                      child: const Text('ยืนยัน'),
                                    )
                                ],
                              );
                            }
                          );
                      },
                      child: const Text('ยกเลิกการจองแล้ว'),
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
