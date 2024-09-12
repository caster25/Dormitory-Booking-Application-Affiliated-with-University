// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สวัสดีค่ะ คุณ ....',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('หอพักบ้านแสนสุข'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                MenuItem(
                  icon: Icons.info_outline,
                  text: 'รายละเอียดหอพักของคุณ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DormitoryDetailsScreen(),
                      ),
                    );
                  },
                ),
                const MenuItem(
                  icon: Icons.favorite_border,
                  text: 'หอพักที่ถูกใจ',
                ),
                MenuItem(
                  icon: Icons.settings,
                  text: 'การตั้งค่า',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const MenuItem(
                  icon: Icons.notifications_none,
                  text: 'แจ้งเตือน',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap; // Add onTap to allow for navigation

  const MenuItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen for entering dormitory details
class DormitoryDetailsScreen extends StatelessWidget {
  const DormitoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _currentDormController =
        TextEditingController();
    final TextEditingController _previousDormController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดหอพักของคุณ'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'หอพักปัจจุบัน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currentDormController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ชื่อหอพักปัจจุบัน',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'หอพักที่เคยพัก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _previousDormController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ชื่อหอพักที่เคยพัก',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String currentDorm = _currentDormController.text;
                String previousDorm = _previousDormController.text;

                print('Current Dorm: $currentDorm');
                print('Previous Dorm: $previousDorm');
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การตั้งค่า'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuItem(
              icon: Icons.account_circle_outlined,
              text: 'ข้อมูลบัญชี',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountInfoScreen(),
                  ),
                );
              },
            ),
            MenuItem(
              icon: Icons.language_outlined,
              text: 'ภาษา',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );
              },
            ),
            MenuItem(
              icon: Icons.info_outline,
              text: 'เกี่ยวกับเรา',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy screens for Account Info, Language, and About Us
class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('ไม่พบข้อมูล'));
          } else {
            final userProfile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('อีเมล: ${userProfile.email}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('เบอร์โทร: ${userProfile.phoneNumber}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('ชื่อบัญชี: ${userProfile.username}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('ชื่อ-นามสกุล: ${userProfile.fullName}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('รหัสผ่าน: ${userProfile.password}',
                      style: TextStyle(fontSize: 16)),
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
    await Future.delayed(Duration(seconds: 1)); // จำลองการรอคอย
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

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกภาษา'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('ภาษาไทย'),
            onTap: () {
              // Code to change language to Thai
              _changeLanguage(context, 'th');
            },
          ),
          ListTile(
            title: const Text('English'),
            onTap: () {
              // Code to change language to English
              _changeLanguage(context, 'en');
            },
          ),
          // Add more languages here
        ],
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    // Function to change language
    // Example: Change app language and refresh the app
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เกี่ยวกับเรา'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เกี่ยวกับแอปของเรา',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'แอปของเราถูกสร้างขึ้นเพื่อช่วยนักศึกษาในการจองหอพักในมหาวิทยาลัยโดยง่ายและสะดวก เรามีความมุ่งมั่นในการให้บริการที่ดีที่สุดแก่ผู้ใช้',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'วิสัยทัศน์และพันธกิจ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'วิสัยทัศน์ของเราคือการทำให้การจองหอพักเป็นเรื่องง่ายและสะดวกสำหรับนักศึกษา โดยการให้บริการที่มีคุณภาพและตอบสนองความต้องการของผู้ใช้',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'ฟีเจอร์หลักของแอป',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• ค้นหาหอพักที่ตรงกับความต้องการ\n'
              '• การจองหอพักออนไลน์\n'
              '• การจัดการข้อมูลหอพัก\n'
              '• การติดต่อผู้ดูแลหอพักได้โดยตรง',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'ทีมงานของเรา',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ทีมพัฒนาแอปของเราประกอบด้วยนักพัฒนาที่มีประสบการณ์และทีมออกแบบที่ทุ่มเทในการสร้างประสบการณ์ที่ดีที่สุดสำหรับผู้ใช้',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'ติดต่อเรา',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• อีเมล: support@dormapp.com\n'
              '• เบอร์โทร: 123-456-7890\n'
              '• ติดตามเราบนโซเชียลมีเดีย: Facebook, Twitter, Instagram',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
