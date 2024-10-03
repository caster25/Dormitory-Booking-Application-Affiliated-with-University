import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
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
                Text('Full Name: ${user['fullname'] ?? 'No Name'}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text('Email: ${user['email'] ?? 'No Email'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Phone Number: ${user['numphone'] ?? 'No Phone'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Role: ${user['role'] ?? 'No Role'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Username: ${user['username'] ?? 'No Username'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                user['isStaying'] != null
                    ? Text('Staying Status: ${user['isStaying'] ? 'Currently Staying' : 'Not Staying'}', style: const TextStyle(fontSize: 16))
                    : const Text('Staying Status: No Data'),
              ],
            ),
          );
        },
      ),
    );
  }
}
