// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/buttons/button_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
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
  bool isLoading = true;
  late String originalName;
  late String originalFullName;
  late String originalPhone;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        originalName = userData['username'] ?? '';
        originalFullName = userData['fullname'] ?? '';
        originalPhone = userData['numphone'] ?? '';

        nameController.text = originalName;
        fullNameController.text = originalFullName;
        phoneController.text = originalPhone;
      } else {
        _showErrorDialog('ไม่พบข้อมูลผู้ใช้');
        Navigator.pop(context);
      }
    } catch (error) {
      _showErrorDialog('เกิดข้อผิดพลาด: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _hasChanges() {
    return nameController.text != originalName ||
           fullNameController.text != originalFullName ||
           phoneController.text != originalPhone;
  }

  void _confirmUpdate() {
    if (!_hasChanges()) {
      _showErrorDialog('ไม่มีการเปลี่ยนแปลงข้อมูล');
      return;
    }

    if (_validateInputs()) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: TextWidget.buildText(
              text: 'ยืนยันการเปลี่ยนแปลงข้อมูล',
              fontSize: 18,
            ),
            content: TextWidget.buildText(
                text: 'คุณแน่ใจว่าต้องการบันทึกการเปลี่ยนแปลงข้อมูลนี้?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateUserData();
                },
                child: TextWidget.buildText(text: 'ใช่'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: TextWidget.buildText(text: 'ไม่'),
              ),
            ],
          );
        },
      );
    }
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showErrorDialog('กรุณากรอกข้อมูลให้ครบถ้วน');
      return false;
    }

    if (phoneController.text.length < 10 || phoneController.text.length > 10) {
      _showErrorDialog('กรุณากรอกเบอร์โทร 10 หลัก');
      return false;
    }

    return true;
  }

  Future<void> _updateUserData() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'username': nameController.text,
        'fullname': fullNameController.text,
        'numphone': phoneController.text,
      });
      _showSuccessDialog();
    } catch (error) {
      _showErrorDialog('เกิดข้อผิดพลาด: $error');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget.buildText(text: 'ข้อผิดพลาด', fontSize: 18),
          content: TextWidget.buildText(text: message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: TextWidget.buildText(text: 'ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget.buildText(text: 'สำเร็จ', fontSize: 18),
          content: TextWidget.buildText(text: 'ข้อมูลได้รับการอัปเดตแล้ว'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
                Navigator.pop(context); // กลับไปหน้าก่อนหน้า
              },
              child: TextWidget.buildText(text: 'ตกลง'),
            ),
          ],
        );
      },
    );
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.buildText(text: 'ชื่อโปรไฟล์', fontSize: 18),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "ชื่อโปรไฟล์",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextWidget.buildText(text: 'ชื่อ-นามสกุล', fontSize: 18),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        hintText: "กรอกชื่อ-นามสกุล",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextWidget.buildText(text: 'เบอร์โทร', fontSize: 18),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: "กรอกเบอร์โทรใหม่",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                      ),
                      keyboardType: TextInputType.phone,
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
