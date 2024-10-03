import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/owner/screen/home_owner.dart';
import 'package:dorm_app/screen/owner/widget/list_of_bookings.dart';
import 'package:flutter/material.dart';
import 'list_of_tenants.dart'; // หน้าที่แสดงรายชื่อผู้เช่า

class Ownerdormlistscreen extends StatelessWidget {
  const Ownerdormlistscreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        stream: FirebaseFirestore.instance.collection('dormitories').snapshots(),
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

              // Handle imageUrl as a List<dynamic>
              List<dynamic> imageUrls = dormitory['imageUrl'] ?? [];

              // Get the first image URL if available
              String? firstImageUrl;
              if (imageUrls.isNotEmpty && imageUrls[0] is String) {
                firstImageUrl = imageUrls[0] as String; // Cast the first image URL to String
              }

              // Handle tenants
              List<dynamic> tenants = dormitory['tenants'] ?? [];
              List<String> tenantNames = [];

              for (var tenant in tenants) {
                // Ensure each tenant is a string before adding it
                if (tenant is String) {
                  tenantNames.add(tenant);
                } else if (tenant is Map<String, dynamic>) {
                  // If tenant is a Map, adjust this according to your Firestore structure
                  tenantNames.add(tenant['name'] ?? ''); // Adjust this if your tenant object structure is different
                }
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: firstImageUrl != null
                      ? Image.network(
                          firstImageUrl, // Use the first image if available
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
                      // Display tenant names
                      Text(
                        'ผู้เช่า: ${tenantNames.isNotEmpty ? tenantNames.join(', ') : 'ไม่มีผู้เช่า'}', // Join names for display
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
                              builder: (context) => ListOfTenants(dormitoryId: dormId),
                            ),
                          );
                        },
                      ),
                      // Button to show bookings
                      IconButton(
                        icon: const Icon(Icons.book_online),
                        tooltip: 'ผู้จอง',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListOfBookings(dormitoryId: dormId),
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
