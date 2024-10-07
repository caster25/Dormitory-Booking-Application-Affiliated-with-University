import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/model/Userprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late Future<UserProfile> _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = getUserProfile(); // Initialize the Future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลบัญชี'),
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('ไม่พบข้อมูล'));
          } else {
            final userProfile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('อีเมล: ${userProfile.email}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('เบอร์โทร: ${userProfile.numphone}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('ชื่อบัญชี: ${userProfile.username}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('ชื่อ-นามสกุล: ${userProfile.fullname}', style: const TextStyle(fontSize: 16)),
                  // Do not display password in the UI for security reasons
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<UserProfile> getUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User profile not found');
    }

    final userData = userDoc.data()!;
    await Future.delayed(const Duration(seconds: 1));

    return UserProfile(
      email: userData['email'] ?? 'Unknown',
      numphone: userData['numphone'] ?? 'Unknown',
      username: userData['username'] ?? 'Unknown',
      fullname: (userData['fullname'] ?? ''),
      password: '********',
    );
  }
}

