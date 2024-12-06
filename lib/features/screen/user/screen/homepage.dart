// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/index.dart';
import 'package:dorm_app/features/screen/user/screen/profile.dart';
import 'package:dorm_app/features/screen/user/widgets/dorm_user.dart';
import 'package:dorm_app/features/screen/user/widgets/feeds_user.dart';
import 'package:dorm_app/features/screen/user/widgets/porfile_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';

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
        color: ColorsApp.primary01,
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
                    child: userData['profilePictureURL'] == null
                        ? const Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextWidget.buildText( text: 
                    userData['username'] ?? 'User Name', fontSize: 18 ,isBold: true
                  ),
                  TextWidget.buildText( text: 
                    user.email ?? 'user@example.com',
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
                    title: TextWidget.buildText( text: 'ยืนยันการออกจากระบบ'),
                    content: TextWidget.buildText( text: 'คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?'),
                    actions: <Widget>[
                      // ปุ่มยกเลิก
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: TextWidget.buildText( text: 'ยกเลิก'),
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
                        child: TextWidget.buildText( text: 'ยืนยัน'),
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
      title: TextWidget.buildText( text: text),
      onTap: onTap,
    );
  }
}

class _HomepageState extends State<Homepage> {
  int index = 0;
  late User _currentUser;

   DateTime? _lastPressedAt;
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
      onWillPop: () async {
                final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          // ถ้ากด back ครั้งแรกจะอัพเดทเวลาปัจจุบัน
          _lastPressedAt = now;
          // แสดงข้อความให้ผู้ใช้ยืนยันการออกจากแอป
          _showExitDialog();
          return false; // หยุดการออกจากแอป
        }
        return true; // ถ้ากด back ครั้งที่สองแล้วให้ปิดแอป
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: IndexedStack(
          index: index,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    return index != 3
        ? getAppBar(
            context: context,
            currentUser: _currentUser,
            isOwner: false,
            index: index,
          )
        : null;
  }

  Widget? _buildDrawer() {
    return index != 3 ? NavigationDrawer(user: _currentUser) : null;
  }

  Widget _buildBottomNavigationBar() {
    return Theme(
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
        color: ColorsApp.primary01,
        buttonBackgroundColor: ColorsApp.primary01,
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
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ทำให้ไม่สามารถปิด dialog ได้ด้วยการแตะนอก dialog
      builder: (context) {
        return AlertDialog(
          title: TextWidget.buildText( text: 'ยืนยันการออกจากแอป'),
          content: TextWidget.buildText( text: 'คุณต้องการออกจากแอปหรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: TextWidget.buildText( text: 'ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
                SystemNavigator.pop(); // ปิดแอป
              },
              child: TextWidget.buildText( text: 'ออกจากแอป'),
            ),
          ],
        );
      },
    );
  }
}
