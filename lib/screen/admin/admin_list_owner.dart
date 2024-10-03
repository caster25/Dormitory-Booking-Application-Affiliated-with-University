import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/admin/admin_list_detail.dart';
import 'package:flutter/material.dart';


class OwnerListScreen extends StatelessWidget {
  const OwnerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'owner') // Filter by role 'owner'
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading owners'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final owners = snapshot.data!.docs;

          return ListView.builder(
            itemCount: owners.length,
            itemBuilder: (context, index) {
              var owner = owners[index];
              return ListTile(
                title: Text(owner['fullname'] ?? 'No Name'),
                subtitle: Text(owner['email'] ?? 'No Email'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to owner details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsScreen(userId: owner.id),
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