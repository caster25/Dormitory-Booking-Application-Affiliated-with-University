// ignore_for_file: use_build_context_synchronously

import 'package:dorm_app/screen/owner/screen/home/screen/home_owner.dart';
import 'package:dorm_app/screen/owner/screen/home/profile/edit_owner_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileOwner extends StatefulWidget {
  const ProfileOwner({super.key});

  @override
  State<ProfileOwner> createState() => _ProfileOwnerState();
}

class _ProfileOwnerState extends State<ProfileOwner> {
  User? currentUser;
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

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Ownerhome()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 153, 85, 240),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.purple),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Ownerhome()),
              (route) => false,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: currentUser == null
              ? const Center(
                  child: CircularProgressIndicator()) // ถ้ากำลังโหลดข้อมูล
              : Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: (userData != null &&
                              userData!['profilePictureURL'] != null &&
                              userData!['profilePictureURL'].isNotEmpty &&
                              userData!['profilePictureURL'].startsWith('http'))
                          ? NetworkImage(userData!['profilePictureURL'])
                          : null,
                      child: (userData == null ||
                              userData!['profilePictureURL'] == null ||
                              userData!['profilePictureURL'].isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 52,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    ProfileInfoRow(
                      icon: Icons.person,
                      text: userData?['fullname'] ?? 'ไม่มีชื่อ',
                    ),
                    ProfileInfoRow(
                      icon: Icons.phone,
                      text: userData?['numphone'] ?? 'ไม่มีเบอร์โทร',
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditOwnerProfile(userId: currentUser!.uid)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 73, 177, 247),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('แก้ไขข้อมูล'),
                    ),
                  ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
