import 'package:dorm_app/screen/terms_and_conditions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dorm_app/screen/login.dart';


class RegisterownerScreen extends StatefulWidget {
  const RegisterownerScreen({super.key});

  @override
  State<RegisterownerScreen> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterownerScreen> {
  final _formKey = GlobalKey<FormState>();
  // final OwnerProfile profile = OwnerProfile(); // Instance of userProfile
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _numphoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // ignore: unused_field
  final TextEditingController _dormitoryNameController =
      TextEditingController();
  // ignore: unused_field
  final TextEditingController _dormitoryAddressController =
      TextEditingController();
  // ignore: unused_field
  bool _acceptTerms = false;

  final auth = FirebaseAuth.instance;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
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

  void _register() async {
  if (_formKey.currentState!.validate()) {
    bool? acceptTerms = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsAndConditionsScreen(),
      ),
    );

    // ตรวจสอบว่าผู้ใช้ยอมรับเงื่อนไขหรือไม่
    if (acceptTerms == true) {
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
            'dormitoryname': _dormitoryNameController.text,
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คุณต้องยอมรับเงื่อนไขก่อนทำการลงทะเบียน')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('กรุณาตรวจสอบข้อมูลอีกครั้ง')),
    );
  }
}


  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(fontSize: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: 30)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: _buildInputDecoration('ชื่อผู้ใช้'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _firstnameController,
                  decoration: _buildInputDecoration('ชื่อ'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _lastnameController,
                  decoration: _buildInputDecoration('นามสกุล'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อ-นามสกุล';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _numphoneController,
                  decoration:
                      _buildInputDecoration('เบอร์โทร'), // Only one decoration
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
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      _buildInputDecoration('อีเมล'), // Only one decoration
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
                const SizedBox(height: 30),
                TextFormField(
                  controller: _dormitoryNameController,
                  decoration: _buildInputDecoration('ชื่อหอพัก'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อหอพัก';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _dormitoryAddressController,
                  decoration: _buildInputDecoration('ที่อยู่หอพัก'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกที่อยู่หอพัก';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _passwordController,
                  decoration:
                      _buildInputDecoration('รหัสผ่าน'), // Only one decoration
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
                const SizedBox(height: 30),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: _buildInputDecoration(
                      'ยืนยันรหัสผ่าน'), // Only one decoration
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    child:
                        const Text('ลงทะเบียน', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
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
