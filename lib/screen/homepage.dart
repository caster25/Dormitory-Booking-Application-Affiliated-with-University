// ignore: unused_import
import 'package:dorm_app/main.dart';
import 'package:dorm_app/screen/dorm.dart';
import 'package:dorm_app/screen/favorites.dart';
import 'package:dorm_app/screen/feeds.dart';
import 'package:dorm_app/screen/home.dart';
import 'package:dorm_app/screen/notification.dart';
import 'package:dorm_app/screen/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.title = "Home"});

  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(context),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Container(
        color: const Color.fromARGB(255, 153,85,240),
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Update with an actual URL
            ),
            SizedBox(height: 12),
            Text(
              'User Name', // Replace 'data' with an actual user name or relevant text
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            Text(
              'user@example.com', // Replace 'data' with an actual email or relevant text
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),color: const Color.fromARGB(255, 241,229,255),
        child: Wrap(
          runSpacing: 16,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('ข้อมูลส่วนตัว'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('การตั้งค่า'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const Homepage(title: 'การตั้งค่า'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('ออกจาระบบ'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ยืนยันการออกจากระบบ'),
                      content:
                          const Text('คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // ปิด dialog
                          },
                          child: const Text('ยกเลิก'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HomeScreen(), // หน้า HomeScreen ที่คุณต้องการ
                              ),
                            );
                          },
                          child: const Text('ยืนยัน'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // Add more menu items here
          ],
        ),
      );
}

class _HomepageState extends State<Homepage> {
  int index = 0;

  // List of screens corresponding to each tab
  final List<Widget> _screens = [
    const FeedsScreen(), // Ensure you have HomeScreen widget in home.dart
    const DormScreen(), // Ensure you have NotificationScreen widget in notification.dart
    const FavoritesScreen(), // Ensure you have FavoritesScreen widget in favorites.dart
    const ProfileScreen(), // Ensure you have ProfileScreen widget in profile.dart
  ];

  // Titles for each tab
  final List<String> titles = [
    'หน้าแรก',
    'การแจ้งเตือน',
    'รายการที่ชอบ',
    'โปรไฟล์'
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Return false to block the back button
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[index]),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const NotificationScreen();
                }));
              },
              icon: const Icon(Icons.notifications),
            ),
          ],
          backgroundColor: Color.fromARGB(255, 153,85,240),
        ),
        backgroundColor: Colors.white,
        drawer: const NavigationDrawer(),
        body: IndexedStack(
          index: index,
          children: _screens,
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: CurvedNavigationBar(
            index: index,
            height: 60.0,
            items: const [
              Icon(Icons.home, size: 30),
              Icon(Icons.domain_rounded, size: 30),
              Icon(Icons.star_sharp, size: 30),
              Icon(Icons.person, size: 30),
            ],
            color: const Color.fromARGB(255, 153,85,240),
            buttonBackgroundColor: const Color.fromARGB(255, 153,85,240),
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 600),
            onTap: (index) {
              setState(() {
                this.index = index;
              });
            },
            letIndexChange: (index) => true,
          ),
        ),
      ),
    );
  }
}
