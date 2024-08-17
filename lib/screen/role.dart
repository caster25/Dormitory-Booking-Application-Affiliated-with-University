import 'package:dorm_app/screen/register.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class role_sceen extends StatelessWidget {
  const role_sceen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือก...'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context) {
                    return const RegisterScreen();
                  },));
                },
                 icon: const Icon(Icons.login),
                 label: const Text('ผู้ใช้ทั่วไป', style: TextStyle(fontSize: 20),) 
              ),),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context) {
                    return const RegisterScreen();
                  },));
                },
                 icon: const Icon(Icons.login),
                 label: const Text('ผู้ให้บริการหอพัก', style: TextStyle(fontSize: 20),) 
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
