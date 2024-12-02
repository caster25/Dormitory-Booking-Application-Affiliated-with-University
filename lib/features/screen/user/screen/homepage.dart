// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/features/screen/index.dart';
import 'package:dorm_app/features/screen/user/screen/profile.dart';
import 'package:dorm_app/features/screen/user/widgets/dorm_user.dart';
import 'package:dorm_app/features/screen/user/widgets/feeds_user.dart';
import 'package:dorm_app/features/screen/user/widgets/notification_user.dart';
import 'package:dorm_app/features/screen/user/widgets/porfile_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.title = "Home"});

  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key, required this.user});

  final User user;

  Future<DocumentSnapshot> getUserData() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // ใช้ uid จาก Firebase Authentication
        .get();
  }

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
        child: FutureBuilder<DocumentSnapshot>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            } else if (snapshot.hasData && snapshot.data!.exists) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundImage: userData['profilePictureURL'] != null
                        ? NetworkImage(userData['profilePictureURL'])
                        : null,
                    child: userData['profilePictureURL'] ==
                            null
                        ? const Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userData['username'] ?? 'User Name',
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  Text(
                    user.email ?? 'user@example.com',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No user data found'));
            }
          },
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
            // buildMenuItem(
            //   context,
            //   icon: Icons.settings,
            //   text: 'การตั้งค่า',
            //   onTap: () => Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(builder: (context) => const SettingsScreen()),
            //   ),
            // ),
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
                      // ปุ่มยกเลิก
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                      // ปุ่มยืนยันการล็อกเอาต์
                      TextButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .signOut(); // ล็อกเอาต์จาก Firebase
                            // เปลี่ยนเส้นทางกลับไปยังหน้าหลัก (IndexScreen)
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const IndexScreen()),
                              (Route<dynamic> route) =>
                                  false, // ลบเส้นทางทั้งหมด
                            );
                          } catch (e) {
                            // จัดการข้อผิดพลาดถ้ามี
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                            );
                          }
                        },
                        child: const Text('ยืนยัน'),
                      ),
                    ],
                  );
                },
              ),
            )
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
    const FeedsScreen(),
    const DormScreen(),
    const ProfileScreen(),
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
        appBar: index != 3 ? getAppBar(index) : null,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        drawer: index != 3 ? NavigationDrawer(user: _currentUser) : null,
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
      backgroundColor: const Color.fromARGB(255, 153, 85, 240),
      title: getTitle(index),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return  NotificationUserScreen(user: _currentUser);
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
        return const Text('');
      default:
        return const Text('ข้อมูลส่วนตัว');
    }
  }
}
