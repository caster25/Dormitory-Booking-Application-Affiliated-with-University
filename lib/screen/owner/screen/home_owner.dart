import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dorm_app/screen/index.dart';
import 'package:dorm_app/screen/notification.dart';
import 'package:dorm_app/screen/owner/widget/dormitory_list_screen.dart';
import 'package:dorm_app/screen/owner/screen/profile_owner.dart';
import 'package:dorm_app/screen/owner/widget/profile_owner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ownerhome extends StatefulWidget {
  const Ownerhome({super.key});

  @override
  State<Ownerhome> createState() => _OwnerhomeState();
}

class _OwnerhomeState extends State<Ownerhome> {
  int index = 0;
  User? _currentUser; // Allow null value
  Future<DocumentSnapshot>? userData;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // This can be null
    if (_currentUser != null) {
      userData = getUserData();
    }
  }

  final List<Widget> _screens = [
    const Profileowner(),
    const DormitoryListScreen(),
  ];

  Future<DocumentSnapshot> getUserData() async {
    if (_currentUser != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
    } else {
      throw Exception("User is not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: index != 2 ? getAppBar(index) : null,
        drawer: index != 2
            ? NavigationDrawer(user: _currentUser, userData: userData)
            : null,
        body: IndexedStack(
          index: index,
          children: _screens,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: index,
          height: 60.0,
          items: const [
            Icon(Icons.home, size: 30),
            Icon(Icons.domain_rounded, size: 30),
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
        return const Text('รายการหอพัก');
      default:
        return const Text('เพิ่มข้อมูลหอพัก');
    }
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer(
      {super.key, required this.user, required this.userData});

  final User? user;
  final Future<DocumentSnapshot>? userData;

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
        color: const Color.fromARGB(255, 153, 85, 240),
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: userData,
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
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userData['username'] ?? 'User Name',
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  Text(
                    user?.email ??
                        'user@example.com', // Update to use optional user
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
                MaterialPageRoute(
                    builder: (context) => const ProfileOwner()),
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
                          MaterialPageRoute(
                              builder: (context) => const IndexScreen()),
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
