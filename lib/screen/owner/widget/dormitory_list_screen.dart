import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/owner/widget/add_dorm.dart';
import 'package:dorm_app/screen/owner/widget/dormitory_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DormitoryListScreen extends StatelessWidget {
  const DormitoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Filter dormitories by the current owner's submittedBy ID
        stream: FirebaseFirestore.instance
            .collection('dormitories')
            .where('submittedBy',
                isEqualTo: currentUserId) // Filter by submittedBy
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ยังไม่มีข้อมูลหอพัก'));
          }

          // Count the number of dormitories
          final int dormitoryCount = snapshot.data!.docs.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // จัดวางให้ปุ่มอยู่ข้างข้อความ
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
                            builder: (context) =>
                                DormitoryFormScreen(), // หน้าจอสำหรับเพิ่มหอพักใหม่
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
                    int dormPrice = dormitory['price']?.toInt() ?? 0;
                    int availableRooms =
                        dormitory['availableRooms']?.toInt() ?? 0;
                    String imageUrl = dormitory['imageUrl'] ?? '';

                    return Card(
                      margin: const EdgeInsets.all(10),
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
                          dormName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ราคา: $dormPrice บาท/เดือน'),
                            Text('ห้องว่าง: $availableRooms ห้อง'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DormitoryDetailsScreen(
                                  dormitory: dormitory,
                                  dormitoryId: dormId,
                                ),
                              ),
                            );
                          },
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
