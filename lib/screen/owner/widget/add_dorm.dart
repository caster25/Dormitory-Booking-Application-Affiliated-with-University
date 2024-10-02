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
  final TextEditingController _roomTypeController = TextEditingController();
  final TextEditingController _occupantsController = TextEditingController();
  final TextEditingController _monthlyRentController = TextEditingController();
  final TextEditingController _maintenanceFeeController = TextEditingController();
  final TextEditingController _electricityRateController = TextEditingController();
  final TextEditingController _waterRateController = TextEditingController();
  final TextEditingController _furnitureFeeController = TextEditingController();
  final TextEditingController _securityDepositController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();

  List<File> _dormImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<String> _uploadedImageUrls = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (pickedFiles != null) {
      setState(() {
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

        UploadTask uploadTask = firebaseStorageRef.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;

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

      await _uploadImagesToFirebase();

      if (_uploadedImageUrls.isNotEmpty) {
        await FirebaseFirestore.instance.collection('dormitories').add({
          'name': _dormNameController.text,
          'price': double.parse(_dormPriceController.text),
          'availableRooms': int.parse(_availableRoomsController.text),
          'roomType': _roomTypeController.text,
          'occupants': int.parse(_occupantsController.text),
          'monthlyRent': double.parse(_monthlyRentController.text),
          'maintenanceFee': double.parse(_maintenanceFeeController.text),
          'electricityRate': double.parse(_electricityRateController.text),
          'waterRate': double.parse(_waterRateController.text),
          'furnitureFee': double.parse(_furnitureFeeController.text),
          'securityDeposit': double.parse(_securityDepositController.text),
          'equipment': _equipmentController.text,
          'imageUrl': _uploadedImageUrls,
          'rating': 0
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลหอพักเรียบร้อยแล้ว')),
        );

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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('ชื่อหอพัก', _dormNameController, 'กรุณากรอกชื่อหอพัก'),
                _buildTextField('ราคาหอพัก (บาท/เดือน)', _dormPriceController, 'กรุณากรอกราคาหอพัก', isNumber: true),
                _buildTextField('จำนวนห้องว่าง', _availableRoomsController, 'กรุณากรอกจำนวนห้องว่าง', isNumber: true),
                _buildTextField('ประเภทห้องพัก', _roomTypeController, 'กรุณากรอกประเภทห้องพัก'),
                _buildTextField('จำนวนคนพัก', _occupantsController, 'กรุณากรอกจำนวนคนพัก', isNumber: true),
                _buildTextField('อัตราค่าห้องพัก', _monthlyRentController, 'กรุณากรอกอัตราค่าห้องพัก', isNumber: true),
                _buildTextField('ค่าบำรุงหอ', _maintenanceFeeController, 'กรุณากรอกค่าบำรุงหอ', isNumber: true),
                _buildTextField('ค่าไฟ (หน่วยละ)', _electricityRateController, 'กรุณากรอกค่าไฟ', isNumber: true),
                _buildTextField('ค่าน้ำ (หน่วยละ)', _waterRateController, 'กรุณากรอกค่าน้ำ', isNumber: true),
                _buildTextField('ค่าเฟอร์นิเจอร์เพิ่มเติม', _furnitureFeeController, 'กรุณากรอกค่าเฟอร์นิเจอร์เพิ่มเติม', isNumber: true),
                _buildTextField('ค่าประกันความเสียหาย', _securityDepositController, 'กรุณากรอกค่าประกันความเสียหาย', isNumber: true),
                _buildTextField('อุปกรณ์ที่มีในห้องพัก', _equipmentController, 'กรุณากรอกอุปกรณ์ที่มีในห้องพัก'),

                // Add image picker and submit button
                const SizedBox(height: 16),
                _buildImagePicker(),
                if (_isUploading) const CircularProgressIndicator(),
                const SizedBox(height: 16),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String validationMessage, {bool isNumber = false}) {
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

  Widget _buildImagePicker() {
    return Row(
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
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        child: const Text('บันทึกข้อมูล'),
      ),
    );
  }
}
