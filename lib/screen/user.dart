import 'package:dorm_app/screen/edituser.dart';
import 'package:flutter/material.dart';

class User extends StatelessWidget {
  const User({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditUser()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://images.pexels.com/photos/1402787/pexels-photo-1402787.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2', // URL ของรูปโปรไฟล์
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('อีเมล'),
                subtitle: const Text('user@example.com'), // แสดงอีเมลของผู้ใช้
              ),
              ListTile(
                leading: const Icon(Icons.local_phone_sharp),
                title: const Text('เบอร์โทรศัพท์'),
                subtitle: const Text('123-456-7890'), // แสดงเบอร์โทรศัพท์ของผู้ใช้
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('ชื่อผู้ใช้'),
                subtitle: const Text('username123'), // แสดงชื่อผู้ใช้
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
