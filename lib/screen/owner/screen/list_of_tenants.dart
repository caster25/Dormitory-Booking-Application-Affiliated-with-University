import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfTenants extends StatelessWidget {
  final String dormitoryId;

  const ListOfTenants({Key? key, required this.dormitoryId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchTenants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .collection('tenants') // คอลเล็กชั่นย่อยที่เก็บผู้เช่า
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายชื่อผู้เช่า'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTenants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีผู้เช่าในหอพักนี้'));
          } else {
            final tenants = snapshot.data!;
            return ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenants[index];
                return ListTile(
                  title: Text(tenant['username'] ?? 'ไม่มีชื่อ'),
                  subtitle: Text(tenant['email'] ?? 'ไม่มีอีเมล'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
