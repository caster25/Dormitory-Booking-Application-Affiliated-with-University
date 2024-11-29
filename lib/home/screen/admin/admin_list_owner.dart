import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/home/screen/admin/admin_list_detail.dart';
import 'package:flutter/material.dart';

class OwnerListScreen extends StatelessWidget {
  const OwnerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner List'),
        centerTitle: true,
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

          if (owners.isEmpty) {
            return const Center(child: Text('No owners found.'));
          }

          return ListView.builder(
            itemCount: owners.length,
            itemBuilder: (context, index) {
              var owner = owners[index];

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
                    backgroundImage: (owner['profilePictureURL'] != null &&
                            owner['profilePictureURL'] != "null" &&
                            owner['profilePictureURL']!.isNotEmpty)
                        ? NetworkImage(owner['profilePictureURL'])
                        : null,
                    child: (owner['profilePictureURL'] == null ||
                            owner['profilePictureURL'] == "null" ||
                            owner['profilePictureURL']!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white,
                          )
                        : null,
                  ),
                    title: Text(
                      owner['fullname'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
