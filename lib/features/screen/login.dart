// ignore_for_file: unused_catch_clause

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/buttons/button_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/screen/register_user.dart';
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

  return null;
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
  bool _isObscure = true;

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

        String? role = await getUserRole(userCredential.user!.uid);
        if (role != null) {
          // ดึงข้อมูล dynamic จาก Firestore หรือค่าที่สามารถเปลี่ยนแปลงได้
          String? redirectRoute = await getDynamicRedirectRoute(role);
          if (redirectRoute != null) {
            Navigator.pushReplacementNamed(context, redirectRoute);
          } else {
            _showErrorDialog('ไม่สามารถหาทางไปได้');
          }
        } else {
          _showErrorDialog('ไม่พบข้อมูล role');
        }
      } on FirebaseAuthException catch (e) {
        // จัดการข้อผิดพลาด
      } catch (e) {
        _showErrorDialog('เกิดข้อผิดพลาด: ${e.toString()}');
      }
    }
  }
  Future<String?> getDynamicRedirectRoute(String role) async {
    // ตัวอย่างการตั้งค่าหน้าจอที่จะแสดงตามข้อมูลจาก Firestore
    // เช่น ดึงค่าจาก Firestore เพื่อตัดสินใจว่า user ต้องการไปที่หน้าไหน
    if (role == 'owner') {
      return '/ownerHome'; // เส้นทางสำหรับเจ้าของ
    } else if (role == 'user') {
      return '/userHome'; // เส้นทางสำหรับผู้ใช้
    } else if (role == 'admin') {
      return '/adminHome'; // เส้นทางสำหรับผู้ดูแล
    }
    return null; // ถ้าไม่มีการกำหนดเส้นทาง
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
            appBar: buildAppBar(title: '', context: context),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              TextWidget.buildText(
                                  text: 'เข้าสู่ระบบ',
                                  fontSize: 30,
                                  isBold: true)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextWidget.buildText(text: 'อีเมล' , fontSize: 20, isBold: true),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'กรอกอีเมลของคุณ',
                          filled: true,
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
                      TextWidget.buildText(text: 'รหัสผ่าน' , fontSize: 20, isBold: true),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          hintText: 'กรอกรหัสผ่านของคุณ',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
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
                      ButtonWidget(
                        label: 'เข้าสู่ระบบ',
                        onPressed: _loginFunction,
                        backgroundColor: Colors.white,
                        fontcolor: Colors.black,
                      )
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
