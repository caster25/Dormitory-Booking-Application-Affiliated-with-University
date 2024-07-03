import 'package:dorm_app/screen/user.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dorm_app/screen/dorm.dart';
import 'package:dorm_app/screen/favorites.dart';
import 'package:dorm_app/screen/feeds.dart';
import 'package:dorm_app/screen/home.dart';
import 'package:dorm_app/screen/notification.dart';
import 'package:dorm_app/screen/profile.dart';

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
        color: const Color.fromARGB(255, 153, 85, 240),
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Update with actual URL
            ),
            SizedBox(height: 12),
            Text(
              'User Name', // Replace with actual user name
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            Text(
              'user@example.com', // Replace with actual email
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        color: const Color.fromARGB(255, 241, 229, 255),
        child: Wrap(
          runSpacing: 16,
          children: [
            buildMenuItem(
              context,
              icon: Icons.person,
              text: 'ข้อมูลส่วนตัว',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const User()),
              ),
            ),
            buildMenuItem(
              context,
              icon: Icons.settings,
              text: 'การตั้งค่า',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Homepage(title: 'การตั้งค่า')),
              ),
            ),
            buildMenuItem(
              context,
              icon: Icons.logout,
              text: 'ออกจาระบบ',
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('ยืนยันการออกจากระบบ'),
                    content: const Text('คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        ),
                        child: const Text('ยืนยัน'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget buildMenuItem(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}

class _HomepageState extends State<Homepage> {
  int index = 0;

  final List<Widget> _screens = [
    const FeedsScreen(), // หน้าแรก
    const DormScreen(), // การแจ้งเตือน
    const FavoritesScreen(), // รายการที่ชอบ
    const ProfileScreen(), // โปรไฟล์
  ];

  AppBar? getAppBar(int index) {
    switch (index) {
      case 0:
        return AppBar(
          title: const Text('หน้าแรก'),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const NotificationScreen();
              })),
              icon: const Icon(Icons.notifications),
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        );
      case 1:
        return AppBar(
          title: const Text('การแจ้งเตือน'),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const NotificationScreen();
              })),
              icon: const Icon(Icons.notifications),
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        );
      case 2:
        return AppBar(
          title: const Text('รายการที่ชอบ'),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const NotificationScreen();
              })),
              icon: const Icon(Icons.notifications),
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        );
      case 3:
        return null; // No AppBar for the Profile tab
      default:
        return AppBar(
          title: const Text('หน้าแรก'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: index != 3 ? getAppBar(index) : null, // Hide AppBar in Profile tab
        backgroundColor: const Color.fromARGB(255, 186,176,248),
        drawer: index != 3 ? const NavigationDrawer() : null, // Hide NavigationDrawer in Profile tab
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
            color: const Color.fromARGB(255, 153, 85, 240),
            buttonBackgroundColor: const Color.fromARGB(255, 153, 85, 240),
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
