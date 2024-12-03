import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/features/screen/user/data/src/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetUser extends StatefulWidget {
  GetUser({super.key});
  
  @override
  _GetUserState createState() => _GetUserState();
}

class _GetUserState extends State<GetUser> {
  List<String> favorites = [];
  final FirestoreServiceUser firestoreServiceUser = FirestoreServiceUser();

  @override
  Widget build(BuildContext context) {
    return _buildUserFavorites();
  }

  // ดึงข้อมูล favorites ของผู้ใช้จาก Firebase
  Stream<DocumentSnapshot> _getUserFavoritesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return firestoreServiceUser.getUserStream(user.uid);
    }
    throw Exception("User not signed in");
  }

  // แสดงผล favorites
  Widget _buildUserFavorites() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _getUserFavoritesStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('User data not found'));
        }

        // ดึงข้อมูล favorites จาก Firestore
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        favorites = List<String>.from(userData['favorites'] ?? []);

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(favorites[index]),
            );
          },
        );
      },
    );
  }
}
