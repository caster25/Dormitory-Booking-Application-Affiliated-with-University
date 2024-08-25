import 'package:dorm_app/screen/register.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือก...'),
      ),
      body: Center(  // ใช้ Center เพื่อให้อยู่กลางหน้าจอ
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่กลางแนวนอน
              crossAxisAlignment: CrossAxisAlignment.center, // จัดให้อยู่กลางแนวตั้ง
              children: [
                SizedBox(
                  width: 150, // กำหนดความกว้างของปุ่ม
                  height: 100, // กำหนดความสูงของปุ่ม
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) {
                          return const RegisterScreen();
                        },
                      ));
                    },
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'ผู้ใช้ทั่วไป', 
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // เว้นระยะห่างระหว่างปุ่ม
                SizedBox(
                  width: 150, // กำหนดความกว้างของปุ่ม
                  height: 100, // กำหนดความสูงของปุ่ม
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) {
                          return const RegisterScreen();
                        },
                      ));
                    },
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'ผู้ให้บริการหอพัก', 
                      style: TextStyle(fontSize: 16),
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

