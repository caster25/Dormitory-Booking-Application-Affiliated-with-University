import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListOfTenants extends StatelessWidget {
  final String dormitoryId;

  // ignore: use_super_parameters
  const ListOfTenants({Key? key, required this.dormitoryId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchTenants() async {
    final dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .get();

    final dormitoryData = dormitorySnapshot.data();

    if (dormitoryData == null || dormitoryData['tenants'] == null) {
      return [];
    }

    List<dynamic> tenants = dormitoryData['tenants'];

    List<Map<String, dynamic>> tenantsList = [];
    for (String tenantId in tenants) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(tenantId)
          .get();
      if (userSnapshot.exists) {
        tenantsList.add(userSnapshot.data() as Map<String, dynamic>);
      }
    }
    return tenantsList;
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
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // รูปประจำตัวผู้เช่า (ตัวอย่าง: Icon)
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      // ข้อมูลผู้เช่า
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant['username'] ?? 'ไม่มีชื่อ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'อีเมล: ${tenant['email'] ?? 'ไม่มีอีเมล'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'เบอร์โทรศัพท์: ${tenant['numphone'] ?? 'ไม่มีเบอร์'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    ),
  );
}

}
