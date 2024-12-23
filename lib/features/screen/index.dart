import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/buttons/button_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/login.dart';
import 'package:dorm_app/features/screen/choose_role.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/home_owner.dart';
import 'package:dorm_app/features/screen/user/screen/homepage.dart';
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
              TextWidget.buildText(
                text: "AccommoEase",
                fontSize: 30.0,
                isBold: true,
                color: ColorsApp.primary01,
              ),
              const SizedBox(height: 40),
              ButtonWidget(
                label: 'เข้าสู่ระบบ',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }));
                },
                backgroundColor: Colors.purple,
                fontcolor: Colors.white,
              ),
              const SizedBox(height: 20),
              ButtonWidget(
                label: 'สมัครสมาชิก',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const RoleScreen();
                  }));
                },
                backgroundColor: Colors.purple,
                fontcolor: Colors.white,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Predefined credentials for test user
                    String testEmail = 'apptest@gmail.com';
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
                    String testEmail = 'ownertestapp@gmail.com';
                    String testPassword = 'test1234';

                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: testEmail,
                        password: testPassword,
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Ownerhome()),
                      );
                    } on FirebaseAuthException catch (e) {
                      // Handle authentication errors
                      String errorMessage = 'Login failed: ${e.message}';
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
