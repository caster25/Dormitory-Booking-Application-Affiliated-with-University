import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentDormitoryCard extends StatelessWidget {
  final String userId;
  final String dormitoryId;

  const CurrentDormitoryCard({Key? key, required this.userId, required this.dormitoryId}) : super(key: key);

  Future<Map<String, dynamic>?> _fetchDormitoryData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        String? currentDormitoryId = userData?['currentDormitoryId'];

        if (currentDormitoryId != null) {
          DocumentSnapshot dormitoryDoc = await FirebaseFirestore.instance
              .collection('dormitories')
              .doc(currentDormitoryId)
              .get();

          if (dormitoryDoc.exists) {
            return dormitoryDoc.data() as Map<String, dynamic>?;
          }
        }
      }
    } catch (e) {
      print('Error fetching dormitory data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchDormitoryData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Text('ไม่พบข้อมูลหอพัก');
        }

        Map<String, dynamic> dormitoryData = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('ชื่อหอพัก: ${dormitoryData['name'] ?? 'ไม่พบชื่อ'}'),
                  subtitle: const Text('ข้อมูลหอพักปัจจุบัน'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String ownerId = "owner_id_here"; // เปลี่ยนเป็น ownerId ที่แท้จริง
                        // ฟังก์ชันสำหรับเข้าสู่การสนทนาเจ้าของหอพัก
                      },
                      child: const Text('เข้าสู่การสนทนาเจ้าของหอพัก'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ฟังก์ชันสำหรับเข้าสู่แชทกลุ่ม
                      },
                      child: const Text('เข้าสู่แชทกลุ่ม'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
