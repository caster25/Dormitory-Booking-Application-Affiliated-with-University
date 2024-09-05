import 'package:dorm_app/screen/owner/ownerhome.dart';
import 'package:dorm_app/screen/register.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

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
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 100,
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
                const SizedBox(height: 30), // Space between buttons
                SizedBox(
                  width: 250,
                  height: 100,
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
