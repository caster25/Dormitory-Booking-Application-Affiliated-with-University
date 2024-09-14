import 'package:flutter/material.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late Future<UserProfile> _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = getUserProfile(); // Initialize the Future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลบัญชี'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('ไม่พบข้อมูล'));
          } else {
            final userProfile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('อีเมล: ${userProfile.email}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('เบอร์โทร: ${userProfile.phoneNumber}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('ชื่อบัญชี: ${userProfile.username}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                      'ชื่อ-นามสกุล: ${userProfile.fullName} + ${userProfile.fullName}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('รหัสผ่าน: ${userProfile.password}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<UserProfile> getUserProfile() async {
    // ฟังก์ชันนี้จะดึงข้อมูลจากฐานข้อมูลจริง
    // นี่เป็นตัวอย่าง
    await Future.delayed(const Duration(seconds: 1)); // จำลองการรอคอย
    return UserProfile(
      email: 'example@example.com',
      phoneNumber: '1234567890',
      username: 'user123',
      fullName: 'John Doe',
      password: 'password123',
    );
  }
}

class UserProfile {
  final String email;
  final String phoneNumber;
  final String username;
  final String fullName;
  final String password;

  UserProfile({
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.fullName,
    required this.password,
  });
}
