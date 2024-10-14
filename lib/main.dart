import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/index.dart';
import 'package:dorm_app/screen/login.dart';
import 'package:dorm_app/screen/owner/screen/home_owner.dart';
import 'package:dorm_app/screen/user/screen/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // Ensure that Flutter services are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with FirebaseOptions
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyDNmyeh6dFL65qhXP2bkOowgl_97O4glkY',
    appId: '1:870658394151:android:db7be5de05075a91e5e602',
    messagingSenderId: 'G-T3QSM1C2CH',
    projectId: 'accommoease',
    storageBucket: 'accommoease.appspot.com',
  )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            User? user = snapshot.data;
            return UserRoleScreen(user: user);
          } else {
            return const IndexScreen(); // หน้าสำหรับการล็อกอิน
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserRoleScreen extends StatelessWidget {
  final User? user;

  // ignore: use_super_parameters
  const UserRoleScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.exists) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String role = userData['role'] ?? 'unknown'; // ตรวจสอบค่า role

          if (role == 'owner') {
            return const Ownerhome(); // หน้าหลักสำหรับผู้ดูแลระบบ
          } else if (role == 'user') {
            return const Homepage(); // หน้าหลักสำหรับผู้ใช้ทั่วไป
          } else {
            return const IndexScreen();
          }
        } else {
          return const Center(child: Text('User data does not exist.'));
        }
      },
    );
  }
}
