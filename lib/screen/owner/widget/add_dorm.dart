// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, unused_field

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/owner/widget/dormitory_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final TextEditingController _ruleController = TextEditingController();
  final TextEditingController _electricityRateController =
      TextEditingController();
  final TextEditingController _waterRateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _securityDepositController =
      TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  LatLng _dormitoryLocation = const LatLng(0, 0); // Default location

  List<File> _dormImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  late String _uploadedImageUrls;

  String? _selectedRoomType;
  String? _selectedDormType;

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
            'price': int.parse(_dormPriceController.text),
            'availableRooms': int.parse(_availableRoomsController.text),
            'roomType': _selectedRoomType,
            'dormType': _selectedDormType,
            'occupants': _occupantsController.text,
            'electricityRate': int.parse(_electricityRateController.text),
            'waterRate': int.parse(_waterRateController.text),
            'securityDeposit': int.parse(_securityDepositController.text),
            'equipment': _equipmentController.text,
            'rule': _ruleController.text,
            'imageUrl': _uploadedImageUrls,
            'rating': 0,
            'submittedBy': userId,
            'latitude': _dormitoryLocation.latitude,
            'longitude': _dormitoryLocation.longitude,
            'address': _addressController.text
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
      appBar: AppBar(
        title: const Text('เพิ่มหอพัก'),
        actions: [
          IconButton(onPressed: _submitForm, icon: const Icon(Icons.save))
        ],
      ),
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

                _buildTextField('ที่อยู่หอพัก', _addressController,
                    'กรุณากรอกที่อยู่หอพัก'),

                _buildTextField('ราคาหอพัก (บาท/เทอม)', _dormPriceController,
                    'กรุณากรอกราคาหอพัก',
                    isNumber: true),

                _buildTextField('จำนวนห้องว่าง', _availableRoomsController,
                    'กรุณากรอกจำนวนห้องว่าง',
                    isNumber: true),

                _buildRoomTypeDropdown(),
                const SizedBox(height: 32),

                _buildDormTypeDropdown(),
                const SizedBox(height: 32),

                _buildTextField('จำนวนคนพัก/ห้อง', _occupantsController,
                    'กรุณากรอกจำนวนคนพัก'),

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

                _buildTextField('กฎของหอพัก', _ruleController,
                    'กรุณาลงรายละเอียดกฎของหอพัก'),

                _buildImagePicker(),

                if (_isUploading) const CircularProgressIndicator(),
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
          return 'กรุณาเลือกประเภทหอพัก';
        }
        return null;
      },
    );
  }

  Widget _buildDormTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDormType,
      decoration: const InputDecoration(
        labelText: 'ประเภทหอพัก',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'หอชาย',
          child: Text('หอชาย'),
        ),
        DropdownMenuItem(
          value: 'หอหญิง',
          child: Text('หอหญิง'),
        ),
        DropdownMenuItem(
          value: 'หอรวม',
          child: Text('หอรวม'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedDormType = value!;
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

  Future<void> _navigateToEditLocation() async {
    final newLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditLocationScreen(initialLocation: _dormitoryLocation),
      ),
    );
    if (newLocation != null) {
      setState(() {
        _dormitoryLocation = newLocation;
      });
    }
  }

  Widget _buildImagePicker() {
    return Row(children: [
      ElevatedButton(
        onPressed: _pickImages,
        child: const Text('เลือกรูปภาพ'),
      ),
      ElevatedButton(
        onPressed: () {
          print("Navigating to Edit Location");
          _navigateToEditLocation();
        },
        child: const Text('แก้ไขตำแหน่งหมุด'),
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
}
