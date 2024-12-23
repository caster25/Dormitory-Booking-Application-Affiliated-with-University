// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/index.dart';
import 'package:dorm_app/features/screen/owner/screen/home/profile/profile_owner.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/dorm/dormitory_list_screen.dart';
import 'package:dorm_app/features/screen/owner/screen/home/home/ownerdorm_list_screen.dart';
import 'package:dorm_app/features/screen/owner/screen/home/home/profile_owner.dart';
import 'package:dorm_app/features/screen/user/data/src/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ownerhome extends StatefulWidget {
  const Ownerhome({super.key, this.title = "Home"});

  final String title;

  @override
  State<Ownerhome> createState() => _OwnerhomeState();
}

class NavigationDrawer extends StatelessWidget {
  NavigationDrawer({super.key, required this.user});
  final FirestoreServiceUser firestoreServiceUser = FirestoreServiceUser();

  final User user;

  Future<DocumentSnapshot> getUserData() async {
    return await firestoreServiceUser.getUserData(user.uid);
  }

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
                    backgroundImage: (userData['profilePictureURL'] != null &&
                            userData['profilePictureURL'] != "null" &&
                            userData['profilePictureURL']!.isNotEmpty)
                        ? NetworkImage(userData['profilePictureURL'])
                        : null,
                    child: (userData['profilePictureURL'] == null ||
                            userData['profilePictureURL'] == "null" ||
                            userData['profilePictureURL']!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextWidget.buildText(text: 
                    userData['username'] ?? 'User Name',fontSize: 18, isBold: true
                  ),
                  TextWidget.buildText(text: 
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
                MaterialPageRoute(builder: (context) => const ProfileOwner()),
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
      title: TextWidget.buildText(text: text),
      onTap: onTap,
    );
  }
}

class _OwnerhomeState extends State<Ownerhome> {
  int index = 0;
  late User _currentUser;
  DateTime? _lastPressedAt;

  final List<Widget> _screens = [
    const DormitoryListScreen(),
    const OwnerDormListScreen(),
    const Profileowner(),
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
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          _showExitDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: index != 3
            ? getAppBar(
                isOwner: true,
                context: context,
                currentUser: _currentUser,
                index: index,
              )
            : null,
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
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('ยืนยันการออกจากแอป'),
          content: Text('คุณต้องการออกจากแอปหรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
                SystemNavigator.pop(); // ปิดแอป
              },
              child: Text('ออกจากแอป'),
            ),
          ],
        );
      },
    );
  }
}
