import 'dart:io';

import 'package:dorm_app/model/Userprofile.dart';
import 'package:dorm_app/screen/owner/widget/dormitory_list_edit.dart';
import 'package:dorm_app/screen/setting/setting.dart';
import 'package:dorm_app/screen/setting/submitIssue.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // อย่าลืม import package นี้
// แก้ไขให้ตรงกับ path ของ UserProfile

class Profileowner extends StatefulWidget {
  const Profileowner({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileownerState createState() => _ProfileownerState();
}

class _ProfileownerState extends State<Profileowner> {
  // ignore: unused_field
  File? _profileImage;
  File? _tempImage; // Temporary image to be saved
  // ignore: unused_field
  String _userName = 'Unknown User';
  String? _profileImageUrl;
  String? userId; 

   @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadOwnerProfile();
  }

  Future<void> _loadOwnerProfile() async {
    try {
      final userProfile = await getUserProfile();
      setState(() {
        _userName = userProfile.username ?? 'Unknown User';
        _profileImageUrl = userProfile.profilePictureURL;
      });
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<UserProfile> getUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User profile not found');
    }

    final userData = userDoc.data()!;
    return UserProfile(
      email: userData['email'],
      numphone: userData['numphone'],
      username: userData['username'],
      fullname: userData['fullname'],
      profilePictureURL: userData['profilePictureURL'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: userId != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            } else {
              final userProfile = UserProfile.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: _tempImage != null
                              ? FileImage(_tempImage!)
                              : _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                          radius: 40,
                          child: _tempImage == null && _profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile.username ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(userProfile.fullname ?? 'No name provided'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 16), // เพิ่มระยะห่างระหว่างชื่อและการ์ด
                  _buildMenuItem(
                    context,
                    Icons.info_outline,
                    'รายละเอียดหอพัก',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DormitoryListEditScreen(),
                        ),
                      );
                    },
                  ),
                  // ถ้าต้องการเปิดใช้งานการ์ดรายชื่อผู้เช่า
                  // _buildMenuItem(
                  //   context,
                  //   Icons.account_box_outlined,
                  //   'รายชื่อผู้เช่า',
                  //   () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const OwnerDormListScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  _buildMenuItem(
                    context,
                    Icons.settings,
                    'การตั้งค่า',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.notifications_none,
                    'แจ้งระบบต่างๆ',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitIssueScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // ฟังก์ชันช่วยสำหรับสร้างเมนู
  Widget _buildMenuItem(
      BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }

  // ฟังก์ชันสำหรับเลือกภาพ
  void _pickImage() {
    // โค้ดเลือกภาพที่คุณจะเพิ่มเข้าไป
  }
}
