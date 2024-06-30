import 'package:dorm_app/screen/user.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หอพัก'), // "Dormitory" in Thai
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                runSpacing: 16,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('ข้อมูลส่วนตัว'), // "Personal Information" in Thai
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const User(),
                      ));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Ionicons.heart_circle_outline),
                    title: const Text('หอพักที่ถูกใจ'), // "Favorite Dormitories" in Thai
                    onTap: () {
                      // Add your onTap logic here
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('การตั้งค่า'), // "Settings" in Thai
                    onTap: () {
                      // Add your onTap logic here
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('การแจ้งเตือน'), // "Notifications" in Thai
                    onTap: () {
                      // Add your onTap logic here
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
