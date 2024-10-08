import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/admin/admin_list_detail.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

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
                      backgroundImage: user['profilePictureURL'] != null && user['profilePictureURL'] != ''
                          ? NetworkImage(user['profilePictureURL'])
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      radius: 30,
                    ),
                    title: Text(
                      user['fullname'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user['email'] ?? 'No Email'),
                    trailing: const Icon(Icons.arrow_forward),
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
