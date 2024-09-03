import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dorm_app/screen/login.dart';
import 'package:dorm_app/model/profile.dart'; // Assuming this contains the userProfile class

class RegisterownerScreen extends StatefulWidget {
  const RegisterownerScreen({super.key});

  @override
  State<RegisterownerScreen> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterownerScreen> {
  final _formKey = GlobalKey<FormState>();
  final userProfile profile = userProfile(); // Instance of userProfile
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _numphoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _acceptTerms = false;

  final auth = FirebaseAuth.instance;
  final usersCollection = FirebaseFirestore.instance.collection('users');

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // ไม่อนุญาตให้ผู้ใช้ปิด dialog โดยการคลิกนอก dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด dialog
            },
            child: const Text('ตกลง'),
          ),
        ],
      );
    },
  );
}

// ในฟังก์ชัน _register ของคุณ
void _register() async {
  if (_formKey.currentState!.validate()) {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณายอมรับเงื่อนไข')),
      );
      return;
    }

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await usersCollection.doc(currentUser.uid).set({
          'username': _usernameController.text,
          'firstname': _firstnameController.text,
          'lastname': _lastnameController.text,
          'numphone': _numphoneController.text,
          'email': _emailController.text,
          'role': 'owner',
        });

        _formKey.currentState!.reset();
        _passwordController.clear();
        _confirmPasswordController.clear();
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // ignore: use_build_context_synchronously
        _showErrorDialog(context, 'อีเมลนี้มีการใช้งานแล้ว กรุณาใช้อีเมลอื่น');
      } else {
        // ignore: use_build_context_synchronously
        _showErrorDialog(context, 'Registration error: ${e.message}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showErrorDialog(context, 'Error: $e');
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('กรุณาตรวจสอบข้อมูลอีกครั้ง')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: 40)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('ชื่อผู้ใช้', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('ชื่อ', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: _firstnameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('นามสกุล', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: _lastnameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกนามสกุล';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('เบอร์โทร', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: _numphoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกเบอร์โทร';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'รูปแบบเบอร์โทรไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('อีเมล', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('รหัสผ่าน', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    if (value.length < 8) {
                      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('ยืนยันรหัสผ่าน', style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value!;
                        });
                      },
                    ),
                    const Text(
                      'ฉันยอมรับเงื่อนไขและข้อตกลงการใช้บริการ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Text('ลงทะเบียน', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
