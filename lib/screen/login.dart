import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/model/Userprofile.dart';
import 'package:dorm_app/screen/homepage.dart';
import 'package:dorm_app/screen/owner/ownerhome.dart';
import 'package:dorm_app/screen/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ฟังก์ชันสำหรับดึง role ของผู้ใช้จาก Firestore
Future<String?> getUserRole(String userId) async {
  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (doc.exists) {
    return doc['role'];
  }

  return null; // ถ้าไม่มีข้อมูล role
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _showErrorDialog(String message,
      {bool showRegisterButton = false,
      bool showResetPasswordButton = false}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'ข้อผิดพลาด',
            style: GoogleFonts.prompt(),
          ),
          content: Text(
            message,
            style: GoogleFonts.prompt(),
          ),
          actions: <Widget>[
            if (showResetPasswordButton)
              TextButton(
                child: Text(
                  'รีเซ็ตรหัสผ่าน',
                  style: GoogleFonts.prompt(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetPassword();
                },
              ),
            if (showRegisterButton)
              TextButton(
                child: Text(
                  'สมัครสมาชิก',
                  style: GoogleFonts.prompt(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
              ),
            TextButton(
              child: Text(
                'ตกลง',
                style: GoogleFonts.prompt(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginFunction() async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String? userId = userCredential.user?.uid;
        if (userId != null) {
          // Retrieve user profile data from Firestore
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (doc.exists) {
            var userData = doc.data() as Map<String, dynamic>;
            UserProfile userProfile = UserProfile.fromMap(userData);
            userProfile.idusers = userId; // กำหนด iduser
            print('User Data from Firestore: $userData');
            print('User ID: ${userProfile.idusers}');
            print('Username: ${userProfile.username}');
            print('First Name: ${userProfile.firstname}');
            print('Last Name: ${userProfile.lastname}');
            print('Email: ${userProfile.email}');
            print('Phone Number: ${userProfile.numphone}');
            print('Role: ${userProfile.role}');
            print('Profile Picture URL: ${userProfile.profilePictureURL}');

            // Navigate based on the role
            String? role = userProfile.role;
            if (role != null) {
              if (role == 'owner') {
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => Ownerhome(),
                  ),
                );
              } else if (role == 'user') {
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => Homepage(),
                  ),
                );
              } 
              else {
                _showErrorDialog('Role ไม่ถูกต้อง');
              }
            } else {
              _showErrorDialog('ไม่พบข้อมูล role');
            }
          } else{
          print('Document does not exist');
          }

          //  else {
          //   _showErrorDialog('ไม่พบข้อมูลผู้ใช้');
            
          // }
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase authentication errors
        String errorMessage;

        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'อีเมลที่กรอกไม่ถูกต้อง';
            break;
          case 'user-disabled':
            errorMessage = 'บัญชีผู้ใช้ถูกปิดการใช้งาน';
            break;
          case 'user-not-found':
            errorMessage = 'ไม่พบบัญชีผู้ใช้';
            break;
          case 'wrong-password':
            errorMessage = 'รหัสผ่านไม่ถูกต้อง';
            break;
          case 'invalid-credential':
            errorMessage = 'ข้อมูลรับรองไม่ถูกต้องหรือหมดอายุ';
            break;
          default:
            errorMessage = 'เกิดข้อผิดพลาด: ${e.message}';
        }

        _showErrorDialog(errorMessage);
      } catch (e) {
        _showErrorDialog('เกิดข้อผิดพลาด: ${e.toString()}');
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมล')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อีเมลรีเซ็ตรหัสผ่านถูกส่งไปแล้ว')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text("${snapshot.error}")),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Text('เข้าสู่ระบบ',
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('อีเมล', style: TextStyle(fontSize: 20)),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'กรอกอีเมลของคุณ',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกอีเมล';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'กรอกรูปแบบอีเมลที่ถูกต้อง';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      const Text('รหัสผ่าน', style: TextStyle(fontSize: 20)),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'กรอกรหัสผ่านของคุณ',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกรหัสผ่าน';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginFunction,
                          child: const Text('เข้าสู่ระบบ'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
