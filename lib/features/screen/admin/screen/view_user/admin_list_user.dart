import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/features/screen/admin/screen/detail/admin_list_detail.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  // Function to delete a user
  Future<void> _deleteUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  // Function to show confirmation dialog before deleting a user
  Future<void> _showDeleteConfirmationDialog(BuildContext context, String userId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบผู้ใช้นี้?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('ลบ'),
              onPressed: () {
                _deleteUser(context, userId); // Call delete function
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to block a user
  Future<void> _blockUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isBlocked': true, // Assuming you have a field to track block status
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error blocking user: $e')),
      );
    }
  }

  // Function to show confirmation dialog before blocking a user
  Future<void> _showBlockConfirmationDialog(BuildContext context, String userId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการบล็อก'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการบล็อกผู้ใช้นี้?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('บล็อก'),
              onPressed: () {
                _blockUser(context, userId); // Call block function
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user') // Filter users by role 'user'
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      radius: 52,
                      backgroundImage: (user['profilePictureURL'] != null &&
                          user['profilePictureURL'] != "null" &&
                          user['profilePictureURL']!.isNotEmpty)
                          ? NetworkImage(user['profilePictureURL'])
                          : null,
                      child: (user['profilePictureURL'] == null ||
                          user['profilePictureURL'] == "null" ||
                          user['profilePictureURL']!.isEmpty)
                          ? const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.white,
                      )
                          : null,
                    ),
                    title: Text(
                      user['fullname'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user['email'] ?? 'No Email'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // IconButton(
                        //   icon: const Icon(Icons.block),
                        //   onPressed: () {
                        //     _showBlockConfirmationDialog(context, user.id); // Show block confirmation dialog
                        //   },
                        // ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, user.id); // Show delete confirmation dialog
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to user details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsScreen(userId: user.id),
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
