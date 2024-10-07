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

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['fullname'] ?? 'No Name'),
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
              );
            },
          );
        },
      ),
    );
  }
}
