
import 'package:dorm_app/screen/login.dart';
import 'package:dorm_app/screen/role.dart';
import 'package:flutter/material.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AccommoEase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return const LoginScreen();
                    }));
                  }, 
                  icon: const Icon(Icons.login),
                  label: const Text('เช้าสู่ระบบ',style: TextStyle(fontSize: 20)
                  ,),),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return const role_sceen();
                    }));
                  }, 
                  icon: const Icon(Icons.login),
                  label: const Text('สร้างบัญชี',style: TextStyle(fontSize: 20)
                  ,),),
              )
            ],
          ),
        ),),
    );
  }
}
