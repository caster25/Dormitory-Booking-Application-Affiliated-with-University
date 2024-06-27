import 'package:dorm_app/screen/homepage.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เช้าสู่ระบบ'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('อีเมล', style: TextStyle(fontSize: 20)),
              TextFormField(),
              SizedBox(height: 15),
              Text('รหัสผ่าน', style: TextStyle(fontSize: 20)),
              TextFormField(
                obscureText: true, //ซ่อนรหัส
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return Homepage();
                  }));
                }, child: Text('เข้าสู่ระบบ')),
              )
            ],
          ),),
      ),
    );
  }
}