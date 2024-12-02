
import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/tenants/list_of_tenants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: use_key_in_widget_constructors
class ListOfDormitories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายชื่อหอพัก'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDormitories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีหอพัก'));
          } else {
            final dormitories = snapshot.data!;
            return ListView.builder(
              itemCount: dormitories.length,
              itemBuilder: (context, index) {
                final dormitory = dormitories[index];
                final dormitoryId = dormitory['id']; // ควรมีฟิลด์ ID ของหอพักในข้อมูล
                return ListTile(
                  title: Text(dormitory['name'] ?? 'ไม่มีชื่อหอพัก'),
                  onTap: () {
                    // เมื่อคลิกจะนำไปยังหน้าจอแสดงผู้เช่า
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListOfTenants(dormitoryId: dormitoryId),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDormitories() async {
    final dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .get();

    final List<Map<String, dynamic>> dormitoriesList = [];
    for (var doc in dormitorySnapshot.docs) {
      dormitoriesList.add({
        'id': doc.id,
        'name': doc['name'], // สมมุติว่ามีฟิลด์ชื่อว่า 'name'
      });
    }
    return dormitoriesList;
  }
}
