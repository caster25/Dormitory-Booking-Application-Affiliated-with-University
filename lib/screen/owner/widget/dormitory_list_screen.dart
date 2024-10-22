import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/owner/widget/add_dorm.dart';
import 'package:dorm_app/screen/owner/widget/dorm_review.dart';
import 'package:dorm_app/screen/owner/widget/dormitory_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DormitoryListScreen extends StatelessWidget {
  const DormitoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final formatNumber = NumberFormat('#,##0');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dormitories')
            .where('submittedBy', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ยังไม่มีข้อมูลหอพัก'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // ไปยังหน้าสำหรับเพิ่มหอพัก
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DormitoryFormScreen(),
                        ),
                      );
                    },
                    child: const Text('เพิ่มหอพัก +'),
                  ),
                ],
              ),
            );
          }

          final int dormitoryCount = snapshot.data!.docs.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'จำนวนหอพักที่คุณเป็นเจ้าของ: $dormitoryCount',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DormitoryFormScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: dormitoryCount,
                  itemBuilder: (context, index) {
                    var dormitory = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    String dormId = snapshot.data!.docs[index].id;
                    String dormName = dormitory['name'] ?? 'ไม่มีชื่อ';
                    String roomType =
                        dormitory['roomType'] ?? 'ไม่มีประเภทห้อง';
                    String dormType =
                        dormitory['dormType'] ?? 'ไม่มีประเภทหอพัก';
                    int totalRooms = dormitory['totalRooms'];
                    int dormPrice = dormitory['price']?.toInt() ?? 0;
                    int availableRooms =
                        dormitory['availableRooms']?.toInt() ?? 0;
                    // ดึง URL ของรูปภาพแรก
                    List<dynamic> images = dormitory['imageUrl'] ?? [];
                    String imageUrl = (images.isNotEmpty && images[0] is String)
                        ? images[0]
                        : '';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          // เมื่อกดที่การ์ดแล้วไปยังหน้าที่แตกต่างออกไป
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DormReview(
                                dormitoryId: dormId,
                                dormitory:
                                    dormitory, // ส่งข้อมูลหอพักไปยังหน้าใหม่
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image, size: 50),
                          title: Text(
                            '$dormName ($roomType, $dormType)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'ราคา: ${formatNumber.format(dormPrice)}  บาท/เทอม'),
                              Text('ห้องทั้งหมด: $totalRooms ห้อง'),
                              Text('ห้องว่าง: $availableRooms ห้อง'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // กดปุ่ม edit เพื่อแก้ไขหอพัก
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DormitoryDetailsScreen(
                                    dormitoryId: dormId,
                                    dormitory: dormitory,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
