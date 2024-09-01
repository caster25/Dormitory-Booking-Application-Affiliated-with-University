// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DormitoryListScreen extends StatelessWidget {
  const DormitoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการหอพัก'),
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
              var dormitory = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String dormName = dormitory['name'] ?? 'ไม่มีชื่อ';
              double dormPrice = dormitory['price'] ?? 0;
              int availableRooms = dormitory['availableRooms'] ?? 0;
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
                      // โค้ดเมื่อกดปุ่มนี้สามารถใช้สำหรับการแสดงรายละเอียดเพิ่มเติม
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DormitoryDetailsScreen(dormitory: dormitory),
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

class DormitoryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> dormitory;

  const DormitoryDetailsScreen({super.key, required this.dormitory});

  @override
  Widget build(BuildContext context) {
    String dormName = dormitory['name'] ?? 'ไม่มีชื่อ';
    double dormPrice = dormitory['price'] ?? 0;
    int availableRooms = dormitory['availableRooms'] ?? 0;
    String imageUrl = dormitory['imageUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(dormName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              dormName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ราคา: $dormPrice บาท/เดือน', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ห้องว่าง: $availableRooms ห้อง', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            // สามารถเพิ่มข้อมูลเพิ่มเติม เช่น รายละเอียดอื่น ๆ เกี่ยวกับหอพัก
          ],
        ),
      ),
    );
  }
}
