import 'package:dorm_app/screen/user.dart';
import 'package:dorm_app/screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.purple),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  
                  backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('สวัสดีค่ะ คุณ ....',
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
            SizedBox(height: 16),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                MenuItem(
                  icon: Icons.info_outline,
                  text: 'รายละเอียดหอพักของคุณ',
                ),
                MenuItem(
                  icon: Icons.favorite_border,
                  text: 'หอพักที่ถูกใจ',
                ),
                MenuItem(
                  icon: Icons.settings,
                  text: 'การตั้งค่า',
                ),
                MenuItem(
                  
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

  const MenuItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}