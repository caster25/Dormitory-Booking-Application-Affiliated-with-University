import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/owner/screen/home_owner.dart';
import 'package:dorm_app/screen/owner/widget/chat_gruop_dorm.dart';
import 'package:dorm_app/screen/owner/widget/list_of_bookings.dart';
import 'package:dorm_app/screen/owner/widget/list_of_tenants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerDormListScreen extends StatelessWidget {
  const OwnerDormListScreen({super.key});

  String getUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการหอพัก'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Ownerhome()),
            (route) => false,
          ),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Filter dormitories by the current owner's submittedBy ID
        stream: FirebaseFirestore.instance
            .collection('dormitories')
            .where('submittedBy', isEqualTo: currentUserId) // Filter by submittedBy
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

              // Get chatGroupId from the dormitory data
              String chatGroupId = dormitory['chatGroupId'] ?? '';
              String chatRooomId = dormitory['chatRooomId'] ?? '';

              // Handle imageUrl as either String or List<String>
              var imageUrlField = dormitory['imageUrl'];
              String? firstImageUrl;
              if (imageUrlField is String) {
                firstImageUrl = imageUrlField;
              } else if (imageUrlField is List<String> && imageUrlField.isNotEmpty) {
                firstImageUrl = imageUrlField[0]; // Use the first image in the list
              }

              // Handle tenants
              List<String> tenants =
                  List<String>.from(dormitory['tenants'] ?? []);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
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
                  title: Text(
                    dormName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ราคา: ฿${dormPrice.toStringAsFixed(2)} บาท/เดือน'),
                      Text('ห้องว่าง: $availableRooms ห้อง'),
                      Text(
                        'ผู้เช่า: ${tenants.isNotEmpty ? tenants.length.toString() : '0'} คน',
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
                      // Button to show bookings
                      IconButton(
                        icon: const Icon(Icons.book_online),
                        tooltip: 'ผู้จอง',
                        onPressed: () {
                          if (currentUserId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListOfBookings(
                                  dormitoryId: dormId,
                                  ownerId: currentUserId,
                                  chatRoomId: chatRooomId, // Use chatGroupId from dormitorytest
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('ไม่สามารถดึงข้อมูลผู้ใช้ได้')),
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
                                builder: (context) => OwnerAllChatScreen(
                                  ownerId: currentUserId,
                                  chatGroupId: chatGroupId, // Use chatGroupId from dormitory
                                  userId: getUserId(),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('ไม่สามารถดึงข้อมูลผู้ใช้ได้')),
                            );
                          }
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
