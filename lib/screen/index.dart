import 'package:dorm_app/screen/homepage.dart';
import 'package:dorm_app/screen/login.dart';
import 'package:dorm_app/screen/owner/ownerhome.dart';
import 'package:dorm_app/screen/role.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // กำหนดความสูงเต็มจอ
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/dorm/back.png'), // Replace with your image path
            fit: BoxFit.fill, // Ensures the image covers the entire container
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/dorm/1 (1).jpg'),
              ),
              const SizedBox(height: 20),
              const Text(
                "AccommoEase",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const LoginScreen();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B59B6)),
                  child: const Text("เข้าสู่ระบบ",
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const RoleScreen();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B59B6)),
                  child: const Text(
                    "สมัครบัญชีผู้ใช้งาน",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Predefined credentials for test user
                    String testEmail = 'servicetest@gmail.com';
                    String testPassword = 'test1234';

                    try {
                      // Sign in the user with Firebase Authentication
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: testEmail,
                        password: testPassword,
                      );

                      // On successful login, navigate to Homepage
                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Homepage()),
                      );
                    } on FirebaseAuthException catch (e) {
                      // Handle authentication errors
                      String errorMessage = 'Login failed: ${e.message}';
                      // Display error message (you can use a dialog or Snackbar)
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  },
                  child: const Text('testuser'),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Predefined credentials for test user
                    String testEmail = 'ownertest@gmail.com';
                    String testPassword = 'owner1234';

                    try {
                      // Sign in the user with Firebase Authentication
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: testEmail,
                        password: testPassword,
                      );

                      // On successful login, navigate to Homepage
                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Ownerhome()),
                      );
                    } on FirebaseAuthException catch (e) {
                      // Handle authentication errors
                      String errorMessage = 'Login failed: ${e.message}';
                      // Display error message (you can use a dialog or Snackbar)
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  },
                  child: const Text('testowner'),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
