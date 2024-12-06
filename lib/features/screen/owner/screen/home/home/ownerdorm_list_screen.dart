import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/widgetchat/chat_gruop_dorm.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/tenants/list_of_bookings.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/tenants/list_of_tenants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OwnerDormListScreen extends StatelessWidget {
  const OwnerDormListScreen({super.key});

  String getUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

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
            return const Center(child: Text('ยังไม่มีข้อมูลหอพัก'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var dormitory =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String dormId = snapshot.data!.docs[index].id;
              String dormName = dormitory['name'] ?? 'ไม่มีชื่อ';
              double dormPrice = dormitory['price']?.toDouble() ?? 0;
              int availableRooms = dormitory['availableRooms']?.toInt() ?? 0;
              int totalRooms = dormitory['totalRooms'];
              String roomType = dormitory['roomType'] ?? 'ไม่มีประเภทห้อง';
              String dormType = dormitory['dormType'] ?? 'ไม่มีประเภทหอพัก';

              // Get chatGroupId from the dormitory data
              String chatGroupId = dormitory['chatGroupId'] ?? '';
              String chatRooomId = dormitory['chatRooomId'] ?? '';

              var imageUrlField = dormitory['imageUrl'];
              String? firstImageUrl;
              if (imageUrlField is List && imageUrlField.isNotEmpty) {
                firstImageUrl = imageUrlField[0];
              } else {
                firstImageUrl = 'https://via.placeholder.com/150';
              }

              List<String> chatRoomIds = [];
              if (dormitory['chatRoomId'] != null &&
                  dormitory['chatRoomId'] is List) {
                chatRoomIds = List<String>.from(dormitory['chatRoomId']);
              }

              // Handle tenants
              List<String> tenants =
                  List<String>.from(dormitory['tenants'] ?? []);

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextWidget.buildText(text: 
                      '$dormName ($roomType, $dormType)',
                    ),
                    Column(
                      children: [
                        ListTile(
                          leading: firstImageUrl != null
                              ? Image.network(
                                  firstImageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error, size: 50),
                                )
                              : const Icon(Icons.image, size: 50),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextWidget.buildText(text: 
                                      'ราคา: ฿${formatNumber.format(dormPrice)} บาท/เทอม'),
                                  TextWidget.buildText(text: 
                                      'ห้องว่าง: $availableRooms ห้อง'),
                                  TextWidget.buildText(text: 
                                      'ห้องทั้งหมด: $totalRooms ห้อง'),
                                  TextWidget.buildText(text: 
                                    'ผู้เช่า: ${tenants.isNotEmpty ? tenants.length.toString() : '0'} คน',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Button to show tenants
                              IconButton(
                                icon: const Icon(Icons.people),
                                tooltip: 'ผู้เช่า',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListOfTenants(dormitoryId: dormId),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.book),
                                tooltip: 'ผู้จอง',
                                onPressed: () {
                                  if (currentUserId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListOfBookings(
                                          dormitoryId: dormId,
                                          ownerId: currentUserId,
                                          chatRoomId: chatRooomId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'ไม่สามารถดึงข้อมูลผู้ใช้ได้')),
                                    );
                                  }
                                },
                              ),
                              // Button to access the all chat screen
                              IconButton(
                                icon: const Icon(Icons.chat),
                                tooltip: 'แชททั้งหมด',
                                onPressed: () {
                                  if (currentUserId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OwnerAllChatScreen(
                                          ownerId: currentUserId,
                                          chatGroupId: chatGroupId,
                                          userId: getUserId(),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'ไม่สามารถดึงข้อมูลผู้ใช้ได้')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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
