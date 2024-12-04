// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userId; // user ที่ admin ต้องการแก้ไข

  const UserDetailsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in admin
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: buildAppBar(title: 'User Details', context: context),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(), // Stream for real-time updates
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user details'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          var user = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name', user['fullname'] ?? 'No Name'),
                _buildDetailRow('Email', user['email'] ?? 'No Email'),
                _buildDetailRow('Phone Number', user['numphone'] ?? 'No Phone'),
                _buildDetailRow('Role', user['role'] ?? 'No Role'),
                _buildDetailRow('Username', user['username'] ?? 'No Username'),

                const SizedBox(height: 20),

                // แสดงปุ่มแก้ไขรหัสผ่านถ้า current user เป็น admin
                if (currentUser != null && currentUser.uid != userId) ...[
                  ElevatedButton(
                    onPressed: () {
                      _showEditUserDialog(context, user); // ฟังก์ชันแก้ไขข้อมูล user
                    },
                    child: const Text('แก้ไขข้อมูล'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    TextEditingController nameController =
        TextEditingController(text: user['fullname']);
    TextEditingController phoneController =
        TextEditingController(text: user['numphone']);
    TextEditingController usernameController =
        TextEditingController(text: user['username']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('แก้ไขข้อมูลผู้ใช้'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'username'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อ'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'เบอร์โทร'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // อัปเดตข้อมูลลง Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'fullname': nameController.text,
                  'numphone': phoneController.text,
                  'username': usernameController.text, // Update username
                }).then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('แก้ไขข้อมูลสำเร็จ')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
                  );
                });
              },
              child: const Text('บันทึก'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }
}
