import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/model/Dormitory.dart';
import 'package:dorm_app/screen/owner/widget/details_dorm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DormitoryListEditScreen extends StatelessWidget {
  const DormitoryListEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current owner's user ID
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final formatNumber = NumberFormat('#,##0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการหอพัก'),
        automaticallyImplyLeading: true,
      ),
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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var dormitoryData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String dormId = snapshot.data!.docs[index].id;

              // แปลง imageUrl เป็น List<String>
              List<String> imageUrlList =
                  List<String>.from(dormitoryData['imageUrl'] ?? []);

              // สร้างอ็อบเจ็กต์ Dormitory
              var dormitory = Dormitory(
                  id: dormId,
                  name: dormitoryData['name'] ?? 'ไม่มีชื่อ',
                  roomType: dormitoryData['roomType'] ?? '',
                  occupants: dormitoryData['occupants'] ?? '',
                  price: dormitoryData['price']?.toInt() ?? 0,
                  maintenanceFee: dormitoryData['maintenanceFee']?.toInt() ?? 0,
                  furnitureFee: dormitoryData['furnitureFee']?.toInt() ?? 0,
                  monthlyRent: dormitoryData['monthlyRent']?.toInt() ?? 0,
                  securityDeposit:
                      dormitoryData['securityDeposit']?.toInt() ?? 0,
                  availableRooms: dormitoryData['availableRooms']?.toInt() ?? 0,
                  electricityRate:
                      dormitoryData['electricityRate']?.toInt() ?? 0,
                  waterRate: dormitoryData['waterRate']?.toInt() ?? 0,
                  rating: dormitoryData['rating']?.toDouble() ?? 0,
                  imageUrl: imageUrlList, // ใช้ imageUrl ที่แปลงแล้ว
                  tenants: List<String>.from(dormitoryData['tenants'] ?? []),
                  equipment: dormitoryData['equipment'] ?? '-',
                  address: dormitoryData['address'] ?? '',
                  dormType: dormitoryData['dormType'],
                  rule: dormitoryData['rule'],
                  submittedBy: dormitoryData['submittedBy']);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: (imageUrlList.isNotEmpty)
                      ? Image.network(
                          imageUrlList[0], // แสดงภาพแรกจากอาเรย์
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 50),
                  title: Text(
                    dormitory.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'ราคา: ฿${formatNumber.format(dormitory.price)} บาท/เดือน'),
                      Text('ห้องว่าง: ${dormitory.availableRooms} ห้อง'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
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
          );
        },
      ),
    );
  }
}
