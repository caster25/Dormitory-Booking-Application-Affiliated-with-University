import 'package:dorm_app/widgets/edituser.dart';
import 'package:dorm_app/screen/homepage.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Homepage()),
            (route) => false,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
            ),
            const SizedBox(height: 16),
            const Text(
              'test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const ProfileInfoRow(
              icon: Icons.person,
              text: 'test',
            ),
            const ProfileInfoRow(
              icon: Icons.line_style,
              text: 'test',
            ),
            const ProfileInfoRow(
              icon: Icons.email,
              text: 'dev test',
            ),
            const ProfileInfoRow(
              icon: Icons.phone,
              text: '087-000-0000',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditUser()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 73, 177, 247),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('แก้ไขข้อมูล'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Handle edit action
              // You can navigate to a detailed edit page or show a dialog for editing
            },
          ),
        ],
      ),
    );
  }
}

