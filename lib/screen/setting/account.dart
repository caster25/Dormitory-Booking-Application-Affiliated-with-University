import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/model/Userprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late Future<UserProfile> _userProfile;
  final bool _isPasswordVisible = false; // Control visibility of password
  final _newPasswordController =
      TextEditingController(); // New password controller

  @override
  void initState() {
    super.initState();
    _userProfile = getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลบัญชี'),
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('ไม่พบข้อมูล'));
          } else {
            final userProfile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountInfoItem(
                      'อีเมล', userProfile.email ?? 'ไม่ระบุ'),
                  _buildAccountInfoItem(
                      'เบอร์โทร', userProfile.numphone ?? 'ไม่ระบุ'),
                  _buildAccountInfoItem(
                      'ชื่อบัญชี', userProfile.username ?? 'ไม่ระบุ'),
                  _buildAccountInfoItem(
                      'ชื่อ-นามสกุล', userProfile.fullname ?? 'ไม่ระบุ'),
                  const Divider(height: 20, thickness: 1),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showPasswordChangeDialog(context);
                    },
                    icon: const Icon(Icons.lock, size: 18),
                    label: const Text('เปลี่ยนรหัสผ่าน'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 239, 239, 239),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAccountInfoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
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

    // ตรวจสอบฟิลด์ password และกำหนดค่าเริ่มต้นหากเป็น null
    return UserProfile(
      email: userData['email'] ?? 'Unknown',
      numphone: userData['numphone'] ?? 'Unknown',
      username: userData['username'] ?? 'Unknown',
      fullname: userData['fullname'] ?? '',
      password: userData['password'] ?? '-',
    );
  }

  // Function to display dialog for password change
  void _showPasswordChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เปลี่ยนรหัสผ่าน'),
          content: TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                _changePassword(_newPasswordController.text);
                Navigator.of(context).pop();
              },
              child: const Text('เปลี่ยนรหัสผ่าน'),
            ),
          ],
        );
      },
    );
  }

  // Function to change password
  Future<void> _changePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }
}
