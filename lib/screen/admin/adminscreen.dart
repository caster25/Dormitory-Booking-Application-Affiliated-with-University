// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/admin/admin_issue_list.dart';
import 'package:dorm_app/screen/admin/screen/view_owner/admin_list_owner.dart';
import 'package:dorm_app/screen/admin/screen/view_user/admin_list_user.dart';
import 'package:dorm_app/screen/index.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ยืนยันการออกจากระบบ'),
                  content: const Text('คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Login Screen and remove all previous routes
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const IndexScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('ยืนยัน'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
                  MaterialPageRoute(
                      builder: (context) => const UserListScreen()),
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
                  MaterialPageRoute(
                      builder: (context) => const OwnerListScreen()),
                );
              },
              child: const Text('Owner List'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Issue List
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminIssueListScreen()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 240, 43, 138),
        child: const Icon(Icons.report), // Icon to represent reports
      ),
    );
  }
}
