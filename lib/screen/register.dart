import 'package:dorm_app/model/profile.dart'; // Assuming this contains the userProfile class
import 'package:dorm_app/screen/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างบัญชี'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: const RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final userProfile profile = userProfile(); // Instance of userProfile
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณายอมรับเงื่อนไข')),
        );
        return;
      }

      // Perform Firebase registration or Firestore storage logic here...

      _formKey.currentState!.reset();
      _passwordController.clear();
      _confirmPasswordController.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาตรวจสอบข้อมูลอีกครั้ง')),
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (value.length < 8) {
      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณายืนยันรหัสผ่าน';
    }
    if (value != _passwordController.text) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Text('ชื่อผู้ใช้', style: TextStyle(fontSize: 20)),
                  TextFormField(
                    onSaved: (value) {
                      profile.userfname = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อผู้ใช้';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text('ชื่อ-นามสกุล', style: TextStyle(fontSize: 20)),
                  TextFormField(
                    onSaved: (value) {
                      profile.userlname = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อ-นามสกุล';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text('เบอร์โทร', style: TextStyle(fontSize: 20)),
                  TextFormField(
                    onSaved: (value) {
                      profile.numphone = value as num?;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกเบอร์โทร';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'รูปแบบเบอร์โทรไม่ถูกต้อง';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  const Text('อีเมล', style: TextStyle(fontSize: 20)),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      profile.email = value;
                    },
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
                    onSaved: (value) {
                      profile.password = value;
                    },
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 15),
                  const Text('ยืนยันรหัสผ่าน', style: TextStyle(fontSize: 20)),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: _validateConfirmPassword,
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
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
