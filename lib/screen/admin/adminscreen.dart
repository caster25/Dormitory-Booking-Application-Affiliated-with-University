import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/admin/admin_list_owner.dart';
import 'package:dorm_app/screen/admin/admin_list_user.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้ทั้งหมดจาก Firestore
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to User List
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserListScreen()),
                );
              },
              child: const Text('User List'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Owner List
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerListScreen()),
                );
              },
              child: const Text('Owner List'),
            ),
          ],
        ),
      ),
    );
  }
}