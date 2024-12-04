// ignore_for_file: use_build_context_synchronously

import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/buttons/button_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/screen/homepage.dart';
import 'package:dorm_app/features/screen/user/widgets/edit_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? currentUser; // เก็บข้อมูลผู้ใช้ที่ล็อกอิน
  Map<String, dynamic>? userData; // เก็บข้อมูลเพิ่มเติมจาก Firestore
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _numphoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // ดึงข้อมูลผู้ใช้เมื่อหน้าจอโหลด
  }

  Future<void> _loadUserData() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          userData =
              userDoc.data() as Map<String, dynamic>; // Update userData here

          // Set values to the TextEditingControllers
          _fullnameController.text = userData?['fullname'] ?? '';
          _numphoneController.text = userData?['numphone'] ?? '';
          setState(() {}); // Trigger a rebuild to update UI
        } else {
          print('Document does not exist');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // ignore: unused_element
  Future<void> _updateUserData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'fullname': _fullnameController.text,
        'numphone': _numphoneController.text,
      });
      Navigator.pop(context); // กลับไปหน้าก่อนหลังจากบันทึก
    } catch (e) {
      // แสดงข้อความข้อผิดพลาดถ้ามี
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Homepage()),
      (route) => false,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: getAppBarUserProfile(title: '', context: context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: currentUser == null
              ? const Center(
                  child: CircularProgressIndicator()) // ถ้ากำลังโหลดข้อมูล
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundImage: userData?['profilePictureURL'] != null
                            ? NetworkImage(userData!['profilePictureURL'])
                            : null,
                        child: userData?['profilePictureURL'] == null
                            ? const Icon(
                                Icons.person,
                                size: 52,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextWidget.buildSection24(
                        userData?['username'] ?? 'ไม่มีชื่อผู้ใช้',
                      ),
                      const SizedBox(height: 16),
                      ProfileInfoRow(
                        icon: Icons.person,
                        text: userData?['fullname'] ?? 'ไม่มีข้อมูล',
                      ),
                      ProfileInfoRow(
                        icon: Icons.phone,
                        text: userData?['numphone'] ?? 'ไม่มีเบอร์โทร',
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                          label: 'แก้ไขข้อมูล',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditUser(userId: currentUser!.uid)));
                          })
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: TextWidget.buildSection16(
              text,
            ),
          ),
        ],
      ),
    );
  }
}
