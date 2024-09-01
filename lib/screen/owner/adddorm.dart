import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class DormitoryFormScreen extends StatefulWidget {
  const DormitoryFormScreen({super.key});

  @override
  State<DormitoryFormScreen> createState() => _DormitoryFormScreenState();
}

class _DormitoryFormScreenState extends State<DormitoryFormScreen> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dormNameController = TextEditingController();
  final TextEditingController _dormPriceController = TextEditingController();
  final TextEditingController _availableRoomsController = TextEditingController();

  File? _dormImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _dormImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_dormImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = path.basename(_dormImage!.path);
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('dormitory_images/$fileName');

      // Upload image file to Firebase Storage
      UploadTask uploadTask = firebaseStorageRef.putFile(_dormImage!);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_dormImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกรูปภาพ')),
        );
        return;
      }

      // อัปโหลดรูปภาพไปยัง Firebase Storage
      await _uploadImageToFirebase();

      if (_uploadedImageUrl != null) {
        // บันทึกข้อมูลหอพักลง Firestore พร้อม URL ของรูปภาพ
        await FirebaseFirestore.instance.collection('dormitories').add({
          'name': _dormNameController.text,
          'price': double.parse(_dormPriceController.text),
          'availableRooms': int.parse(_availableRoomsController.text),
          'imageUrl': _uploadedImageUrl,
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลหอพักเรียบร้อยแล้ว')),
        );

        // ล้างแบบฟอร์ม
        _formKey.currentState!.reset();
        setState(() {
          _dormImage = null;
          _uploadedImageUrl = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มข้อมูลหอพัก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ฟิลด์สำหรับชื่อหอพัก
                TextFormField(
                  controller: _dormNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อหอพัก',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อหอพัก';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ฟิลด์สำหรับราคาหอพัก
                TextFormField(
                  controller: _dormPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ราคาหอพัก (บาท/เดือน)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกราคาหอพัก';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ฟิลด์สำหรับห้องที่ว่าง
                TextFormField(
                  controller: _availableRoomsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'จำนวนห้องว่าง',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกจำนวนห้องว่าง';
                    }
                    if (int.tryParse(value) == null) {
                      return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ปุ่มเลือกรูปภาพหอพัก
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('เลือกรูปหอพัก'),
                    ),
                    const SizedBox(width: 16),
                    if (_dormImage != null)
                      const Text(
                        'เลือกรูปภาพแล้ว',
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // แสดงสถานะการอัปโหลดรูปภาพ
                if (_isUploading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                ],

                // ปุ่มส่งข้อมูล
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('บันทึกข้อมูล'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
