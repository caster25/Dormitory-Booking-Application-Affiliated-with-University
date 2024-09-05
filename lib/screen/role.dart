import 'package:dorm_app/screen/owner/ownerhome.dart';
import 'package:dorm_app/screen/register.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // ใช้ Center เพื่อให้อยู่กลางหน้าจอ
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              // ใช้ Column แทน Row
              mainAxisAlignment:
                  MainAxisAlignment.center, // จัดให้อยู่กลางแนวตั้ง
              crossAxisAlignment:
                  CrossAxisAlignment.center, // จัดให้อยู่กลางแนวนอน
              children: [
                SizedBox(
                  width: 250, // เพิ่มความกว้างของปุ่ม
                  height: 100, // กำหนดความสูงของปุ่ม
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const RegisterScreen();
                        },
                      ));
                    },
                    icon: const Icon(Icons.person),
                    label: const Text(
                      'ผู้ใช้งานทั่วไป',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30), // เว้นระยะห่างระหว่างปุ่ม
                SizedBox(
                  width: 250, // เพิ่มความกว้างของปุ่ม
                  height: 100, // กำหนดความสูงของปุ่ม
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const Ownerhome();
                        },
                      ));
                    },
                    icon: const Icon(Icons.business),
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
