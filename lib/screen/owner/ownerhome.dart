import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dorm_app/screen/index.dart';
import 'package:dorm_app/screen/notification.dart';
import 'package:dorm_app/screen/owner/adddorm.dart';
import 'package:dorm_app/screen/owner/details.dart';
import 'package:dorm_app/screen/owner/dormitoryListScreen.dart';
import 'package:dorm_app/screen/owner/profile.dart';
import 'package:dorm_app/widgets/editpassword.dart';
import 'package:dorm_app/widgets/map.dart';
import 'package:flutter/material.dart';

class Ownerhome extends StatefulWidget {
  const Ownerhome({super.key});

  @override
  State<Ownerhome> createState() => _OwnerhomeState();
}

class _OwnerhomeState extends State<Ownerhome> {
  int index = 0;

  final List<Widget> _screens = [
    const Profileowner(),
    const DormitoryFormScreen(),
    const Details()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(index),
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
    );
  }

  AppBar getAppBar(int index) {
    return AppBar(
      title: getTitle(index),
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
    );
  }

  Text getTitle(int index) {
    switch (index) {
      case 0:
        return const Text('หน้าแรก');
      case 1:
        return const Text('หอพัก');
      default:
        return const Text('รายละเอียด');
    }
  }
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
            buildHeader(context), // ส่วนหัวของ Drawer
            buildMenuItems(context), // ส่วนรายการเมนู
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างส่วนหัวของ Drawer
  Widget buildHeader(BuildContext context) => Container(
        color: const Color.fromARGB(255, 153, 85, 240),
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: const Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'), // Update with actual URL
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

  // ฟังก์ชันสำหรับสร้างเมนูใน Drawer
  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        color: const Color.fromARGB(255, 252, 252, 252),
        child: Wrap(
          runSpacing: 16,
          children: [
            buildMenuItem(
              context,
              icon: Icons.person,
              text: 'ข้อมูลส่วนตัว',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const DormitoryListScreen()),
              ),
            ),
            buildMenuItem(
              context,
              icon: Icons.settings,
              text: 'การตั้งค่า',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MapScreen()),
              ),
            ),
            buildMenuItem(
              context,
              icon: Icons.logout,
              text: 'ออกจากระบบ',
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
                        onPressed: () => 
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const IndexScreen()),
                          (Route<dynamic> route) => false,
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

void main() {
  runApp(MaterialApp(
    home: const Ownerhome(),
    theme: ThemeData(
      primaryColor: const Color.fromARGB(255, 241, 229, 255),
    ),
  ));
}
