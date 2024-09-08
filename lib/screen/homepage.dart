import 'package:dorm_app/screen/owner/chat.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dorm_app/screen/index.dart';
import 'package:dorm_app/screen/notification.dart';
import 'package:dorm_app/screen/user.dart';
import 'package:dorm_app/widgets/editpassword.dart';
import 'package:dorm_app/widgets/dorm.dart';
import 'package:dorm_app/widgets/feeds.dart';
import 'package:dorm_app/screen/profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.title = "Home"});

  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key, required this.user});

  final User user; // Add user parameter

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
          children: [
            CircleAvatar(
              radius: 52,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : const NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName ?? 'User Name',
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            Text(
              user.email ?? 'user@example.com',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      );

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
                MaterialPageRoute(builder: (context) => const UserScreen()),
              ),
            ),
            buildMenuItem(
              context,
              icon: Icons.settings,
              text: 'การตั้งค่า',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Editpassword()),
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
                        onPressed: () async {
                          await FirebaseAuth.instance
                              .signOut(); // Sign out from Firebase
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const IndexScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
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
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}

class _HomepageState extends State<Homepage> {
  int index = 0;
  late User _currentUser;

  final List<Widget> _screens = [
    const FeedsScreen(), // หน้าแรก
    const DormScreen(), // หอพัก
    const ChatScreen(), // รีวิวหอพัก
    const ProfileScreen(), // โปรไฟล์
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar:
            index != 3 ? getAppBar(index) : null, // Hide AppBar in Profile tab
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        drawer: index != 3
            ? NavigationDrawer(user: _currentUser)
            : null, // Hide NavigationDrawer in Profile tab
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
      case 2:
        return const Text('รีวิวหอพัก');
      default:
        return const Text('ข้อมูลส่วนตัว');
    }
  }
}
