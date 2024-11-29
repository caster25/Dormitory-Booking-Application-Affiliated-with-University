import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/home/screen/index.dart';
import 'package:dorm_app/home/screen/owner/screen/home_owner.dart';
import 'package:dorm_app/home/screen/user/screen/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginService extends StatelessWidget {
  const LoginService({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); 
        } else if (snapshot.hasData) {
          User? user = snapshot.data;
          return UserRoleScreen(user: user!); 
        } else {
          return const IndexScreen();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class UserRoleScreen extends StatelessWidget {
  final User? user;

  const UserRoleScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.exists) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String role = userData['role'] ?? 'unknown';
          if (role == 'owner') {
            return const Ownerhome();
          } else if (role == 'user') {
            return const Homepage();
          }
        }
        return const IndexScreen();
      },
    );
  }
}
