// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/buttons/button_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/screen/homepage.dart';
import 'package:flutter/material.dart';

class EditUser extends StatefulWidget {
  final String userId;

  const EditUser({super.key, required this.userId});

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  late TextEditingController nameController;
  late TextEditingController fullNameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    var userData = userDoc.data() as Map<String, dynamic>;

    nameController.text = userData['username'] ?? '';
    fullNameController.text = userData['fullname'] ?? '';
    phoneController.text = userData['numphone'] ?? '';
  }

  void _confirmUpdate() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget.buildHeader24('ยืนยันการเปลี่ยนแปลงข้อมูล'),
          content:
              TextWidget.buildSubSection14('คุณแน่ใจว่าต้องการบันทึกการเปลี่ยนแปลงข้อมูลนี้?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
                _updateUserData();
              },
              child: TextWidget.buildSection16('ใช่'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: TextWidget.buildSection16('ไม่'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'username': nameController.text,
        'fullname': fullNameController.text,
        'numphone': phoneController.text,
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  TextWidget.buildHeader24('สำเร็จ'),
            content:  TextWidget.buildSection16('ข้อมูลได้รับการอัปเดตแล้ว'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด Dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Homepage()),
                    (route) => false,
                  );
                },
                child: TextWidget.buildSubSection16('ตกลง'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // แสดง Popup Dialog เมื่อเกิดข้อผิดพลาด
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ข้อผิดพลาด'),
            content: Text('เกิดข้อผิดพลาด: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด Dialog
                },
                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'แก้ไขข้อมูลส่วนตัว', context: context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.buildSubSectionBold20('ชื่อโปรไฟล์'),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "ชื่อโปรไฟล์",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              TextWidget.buildSubSectionBold20('ชื่อ-นามสกุล'),
              const SizedBox(height: 10),
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: "กรอกชื่อ-นามสกุล",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              TextWidget.buildSubSectionBold20('เบอร์โทร'),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: "กรอกเบอร์โทรใหม่",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    label: 'บันทึก',
                    onPressed: _confirmUpdate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
