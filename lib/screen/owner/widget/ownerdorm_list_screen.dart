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
        stream:
            FirebaseFirestore.instance.collection('dormitories').snapshots(),
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
              var dormitory = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String dormId = snapshot.data!.docs[index].id; 
              String dormName = dormitory['name'] ?? 'ไม่มีชื่อ';
              double dormPrice = dormitory['price']?.toDouble() ?? 0;
              int availableRooms = dormitory['availableRooms']?.toInt() ?? 0;
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ปุ่มแสดงผู้เช่า
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
                      // ปุ่มแสดงผู้จอง
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
