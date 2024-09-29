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

  List<File> _dormImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<String> _uploadedImageUrls = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (pickedFiles != null) {
      setState(() {
        // เพิ่มรูปใหม่ที่เลือกเข้ามาในรายการรูปที่มีอยู่
        _dormImages.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
      });
    }
  }

  Future<void> _uploadImagesToFirebase() async {
    if (_dormImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      for (var image in _dormImages) {
        String fileName = path.basename(image.path);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('dormitory_images/$fileName');

        // Upload image file to Firebase Storage
        UploadTask uploadTask = firebaseStorageRef.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL of the uploaded image
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        _uploadedImageUrls.add(downloadUrl);
      }
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
      if (_dormImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกรูปภาพ')),
        );
        return;
      }

      // อัปโหลดรูปภาพไปยัง Firebase Storage
      await _uploadImagesToFirebase();

      if (_uploadedImageUrls.isNotEmpty) {
        // บันทึกข้อมูลหอพักลง Firestore พร้อม URL ของรูปภาพ
        await FirebaseFirestore.instance.collection('dormitories').add({
          'name': _dormNameController.text,
          'price': double.parse(_dormPriceController.text),
          'availableRooms': int.parse(_availableRoomsController.text),
          'imageUrl': _uploadedImageUrls,
          'rating': 0
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลหอพักเรียบร้อยแล้ว')),
        );

        // ล้างแบบฟอร์ม
        _formKey.currentState!.reset();
        setState(() {
          _dormImages = [];
          _uploadedImageUrls = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มข้อมูลหอพัก'),
        automaticallyImplyLeading: false, // Hide the back button
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
                      onPressed: _pickImages,
                      child: const Text('เลือกรูปหอพัก'),
                    ),
                    const SizedBox(width: 16),
                    if (_dormImages.isNotEmpty)
                      const Text(
                        'เลือกรูปภาพแล้ว',
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // แสดงรูปภาพที่เลือก
                if (_dormImages.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dormImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(
                                _dormImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _dormImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
