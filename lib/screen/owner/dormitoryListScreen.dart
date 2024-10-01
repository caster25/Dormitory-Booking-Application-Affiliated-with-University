import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/owner/DormitoryDetailsScreen.dart';
import 'package:flutter/material.dart';

class DormitoryListScreen extends StatelessWidget {
  const DormitoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DormitoryDetailsScreen(
                            dormitory: dormitory,
                            dormitoryId: dormId, // ส่ง ID ของหอพัก
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
