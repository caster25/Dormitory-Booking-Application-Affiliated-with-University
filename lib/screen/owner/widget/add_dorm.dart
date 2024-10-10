// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, unused_field

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _availableRoomsController =
      TextEditingController();
  final TextEditingController _occupantsController = TextEditingController();
  final TextEditingController _monthlyRentController = TextEditingController();
  final TextEditingController _electricityRateController =
      TextEditingController();
  final TextEditingController _waterRateController = TextEditingController();
  final TextEditingController _securityDepositController =
      TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();

  List<File> _dormImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  late String _uploadedImageUrls;

  String? _selectedRoomType;

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _dormImages
            .addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
      });
    }
  }

  Future<void> _uploadImagesToFirebase() async {
    if (_dormImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    String uploadedImageUrls = '';

    try {
      for (var i = 0; i < _dormImages.length; i++) {
        var image = _dormImages[i];
        String fileName = path.basename(image.path);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('dormitory_images/$fileName');

        UploadTask uploadTask = firebaseStorageRef.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;

        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        if (uploadedImageUrls.isNotEmpty) {
          uploadedImageUrls += ',';
        }
        uploadedImageUrls += downloadUrl;
      }

      _uploadedImageUrls = uploadedImageUrls;
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

      await _uploadImagesToFirebase();

      if (_uploadedImageUrls.isNotEmpty) {
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          String userId = currentUser.uid;

          await FirebaseFirestore.instance.collection('dormitories').add({
            'name': _dormNameController.text,
            'price': double.parse(_dormPriceController.text),
            'availableRooms': int.parse(_availableRoomsController.text),
            'roomType': _selectedRoomType, // Change here
            'occupants': int.parse(_occupantsController.text),
            'monthlyRent': double.parse(_monthlyRentController.text),
            'electricityRate': double.parse(_electricityRateController.text),
            'waterRate': double.parse(_waterRateController.text),
            'securityDeposit': double.parse(_securityDepositController.text),
            'equipment': _equipmentController.text,
            'imageUrl': _uploadedImageUrls,
            'rating': 0,
            'submittedBy': userId,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('บันทึกข้อมูลหอพักเรียบร้อยแล้ว')),
          );

          _formKey.currentState!.reset();
          setState(() {
            _dormImages = [];
            _uploadedImageUrls = '';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาล็อกอินก่อนเพิ่มหอพัก')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    'ชื่อหอพัก', _dormNameController, 'กรุณากรอกชื่อหอพัก'),

                _buildTextField('ราคาหอพัก (บาท/เทอม)', _dormPriceController,
                    'กรุณากรอกราคาหอพัก',
                    isNumber: true),

                _buildTextField('จำนวนห้องว่าง', _availableRoomsController,
                    'กรุณากรอกจำนวนห้องว่าง',
                    isNumber: true),

                // Dropdown for room type
                _buildRoomTypeDropdown(),
                const SizedBox(height: 32), // เพิ่มระยะห่างเฉพาะที่นี่

                _buildTextField(
                    'จำนวนคนพัก', _occupantsController, 'กรุณากรอกจำนวนคนพัก',
                    isNumber: true),

                _buildTextField('อัตราค่าห้องพัก', _monthlyRentController,
                    'กรุณากรอกอัตราค่าห้องพัก',
                    isNumber: true),

                _buildTextField('ค่าไฟ (หน่วยละ)', _electricityRateController,
                    'กรุณากรอกค่าไฟ',
                    isNumber: true),

                _buildTextField(
                    'ค่าน้ำ (หน่วยละ)', _waterRateController, 'กรุณากรอกค่าน้ำ',
                    isNumber: true),

                _buildTextField('ค่าประกันความเสียหาย',
                    _securityDepositController, 'กรุณากรอกค่าประกันความเสียหาย',
                    isNumber: true),

                _buildTextField('อุปกรณ์ที่มีในห้องพัก', _equipmentController,
                    'กรุณากรอกอุปกรณ์ที่มีในห้องพัก'),

                _buildImagePicker(),

                if (_isUploading) const CircularProgressIndicator(),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String validationMessage,
      {bool isNumber = false}) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validationMessage;
            }
            if (isNumber && double.tryParse(value) == null) {
              return 'กรุณากรอกตัวเลขที่ถูกต้อง';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRoomTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRoomType,
      decoration: const InputDecoration(
        labelText: 'ประเภทห้องพัก',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'ห้องพัดลม',
          child: Text('ห้องพัดลม'),
        ),
        DropdownMenuItem(
          value: 'ห้องแอร์',
          child: Text('ห้องแอร์'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRoomType = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาเลือกประเภทห้องพัก';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker() {
    return Row(children: [
      ElevatedButton(
        onPressed: _pickImages,
        child: const Text('เลือกรูปภาพ'),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _dormImages
                .map((image) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    ]);
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      child: const Text('บันทึกข้อมูล'),
    );
  }
}
