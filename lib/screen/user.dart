import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dorm_app/widgets/edituser.dart';
import 'package:dorm_app/screen/homepage.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? currentUser; // เก็บข้อมูลผู้ใช้ที่ล็อกอิน
  Map<String, dynamic>? userData; // เก็บข้อมูลเพิ่มเติมจาก Firestore

  @override
  void initState() {
    super.initState();
    _loadUserData(); // ดึงข้อมูลผู้ใช้เมื่อหน้าจอโหลด
  }

  Future<void> _loadUserData() async {
    currentUser =
        FirebaseAuth.instance.currentUser; // ดึงข้อมูลผู้ใช้จาก FirebaseAuth

    if (currentUser != null) {
      // ดึงข้อมูลผู้ใช้จาก Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Homepage()),
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['username'] ?? 'ชื่อผู้ใช้',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ProfileInfoRow(
                    icon: Icons.person,
                    text: userData?['username'] ?? 'ไม่ทราบ',
                  ),
                  ProfileInfoRow(
                    icon: Icons.email,
                    text: currentUser?.email ?? 'ไม่มีอีเมล',
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
                            builder: (context) => const EditUser()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 73, 177, 247),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('แก้ไขข้อมูล'),
                  ),
                ],
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
            onPressed: () {
              // Handle edit action
            },
          ),
        ],
      ),
    );
  }
}
