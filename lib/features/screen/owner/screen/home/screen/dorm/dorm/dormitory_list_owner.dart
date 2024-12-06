import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/model/Dormitory.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/dorm/details_dorm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DormitoryListOwnerScreen extends StatelessWidget {
  const DormitoryListOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current owner's user ID
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final formatNumber = NumberFormat('#,##0');

    return Scaffold(
      appBar: buildAppBar(title: 'รายการหอพัก', context: context),
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
            return const Center(child: Text('ยังไม่มีข้อมูลหอพัก'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var dormitoryData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String dormId = snapshot.data!.docs[index].id;

              List<String> imageUrlList =
                  List<String>.from(dormitoryData['imageUrl'] ?? []);

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
                  imageUrl: imageUrlList,
                  tenants: List<String>.from(dormitoryData['tenants'] ?? []),
                  equipment: dormitoryData['equipment'] ?? '-',
                  address: dormitoryData['address'] ?? '',
                  dormType: dormitoryData['dormType'],
                  rule: dormitoryData['rule'],
                  submittedBy: dormitoryData['submittedBy']);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: (imageUrlList.isNotEmpty)
                            ? Image.network(
                                imageUrlList[0],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 70),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.buildText(text: 
                              '${dormitory.name} (${dormitory.dormType})',fontSize: 18, isBold: true
                            ),
                            const SizedBox(height: 4),
                            TextWidget.buildText(text: 
                              'ราคา: ฿${formatNumber.format(dormitory.price)} บาท/เทอม',
                            ),
                            TextWidget.buildText(text: 
                              'ห้องว่าง: ${dormitory.availableRooms} ห้อง',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
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
                    ],
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
