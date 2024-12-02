// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, unused_field

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/dorm/dormitory_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
// ignore: unused_import
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
  final TextEditingController _totalRoomsController = TextEditingController();
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
  List<String> _uploadedImageUrls = [];

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

  Future<String> _uploadImagesToFirebase(File image) async {
    try {
      String fileName = image.path.split('/').last;
      Reference storageReference =
          FirebaseStorage.instance.ref().child('dormitory_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _uploadAllImagesToFirebase() async {
    if (_dormImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    List<String> uploadedImageUrls = [];

    try {
      for (var image in _dormImages) {
        String downloadUrl = await _uploadImagesToFirebase(image);
        if (downloadUrl.isNotEmpty) {
          uploadedImageUrls.add(downloadUrl);
        }
      }

      // เก็บ URL ทั้งหมดใน _uploadedImageUrls
      _uploadedImageUrls = uploadedImageUrls;

      // แสดง URLs ที่อัปโหลดสำเร็จ
      print('Uploaded Image URLs: $_uploadedImageUrls');
    } catch (e) {
      print('Error uploading images: $e');
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

      await _uploadAllImagesToFirebase();

      if (_uploadedImageUrls.isNotEmpty) {
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          String userId = currentUser.uid;

          // เพิ่มข้อมูลหอพักใน collection dormitories
          DocumentReference dormitoryRef =
              await FirebaseFirestore.instance.collection('dormitories').add({
            'name': _dormNameController.text,
            'price': int.parse(_dormPriceController.text),
            'availableRooms': int.parse(_availableRoomsController.text),
            'totalRooms': int.parse(_totalRoomsController.text),
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
            'address': _addressController.text,
          });

          String dormitoryId = dormitoryRef.id;

          // สร้าง chatRoomId จาก userId และ dormitoryId
          String chatRoomId = _createChatRoomId(userId, dormitoryId);

          // อัปเดตข้อมูล dormitory ด้วย chatRoomId ที่สร้างขึ้น
          await dormitoryRef.update({'chatRoomId': chatRoomId});

          // เพิ่มข้อมูลห้องแชทใน collection chatRooms
          await FirebaseFirestore.instance
              .collection('chatRooms')
              .doc(chatRoomId)
              .set({
            'chatRoomId': chatRoomId,
            'dormitoryId': dormitoryId,
            'ownerId': userId,
            'lastMessageTime': FieldValue.serverTimestamp(),
          });

          // สร้าง chatGroupId
          String chatGroupId = _createChatGroupId(userId, dormitoryId);

          // อัปเดตข้อมูล dormitory ด้วย chatGroupId ที่สร้างขึ้น
          await dormitoryRef.update({'chatGroupId': chatGroupId});

          // เพิ่มข้อมูลกลุ่มแชทใน collection chatGroups
          await FirebaseFirestore.instance
              .collection('chatGroups')
              .doc(chatGroupId)
              .set({
            'chatGroupId': chatGroupId,
            'dormitoryId': dormitoryId,
            'ownerId': userId,
            'lastMessageTime': FieldValue.serverTimestamp(),
          });

          // เพิ่มข้อความเริ่มต้นใน collection messages
          await FirebaseFirestore.instance.collection('messages').add({
            'chatRoomId': chatRoomId,
            'chatGroupId': chatGroupId,
            'senderId': userId,
            'message': 'ยินดีต้อนรับสู่ห้องสนทนาของหอพักนี้!',
            'timestamp': FieldValue.serverTimestamp(),
          });

          // เพิ่ม chatRoomId ลงในผู้ใช้
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'chatRoomId': FieldValue.arrayUnion([chatRoomId]),
            'chatGroupId': chatGroupId
          });

          // แสดง popup ว่าการเพิ่มข้อมูลเสร็จสิ้น
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('สำเร็จ'),
                content:
                    const Text('เพิ่มข้อมูลหอพักและสร้างห้องแชทเรียบร้อยแล้ว'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // เคลียร์ช่องข้อมูล
                      _formKey.currentState!.reset();
                      setState(() {
                        _dormImages = [];
                        _uploadedImageUrls = [];
                      });
                      Navigator.of(context).pop(); // ปิด dialog
                    },
                    child: const Text('ตกลง'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาล็อกอินก่อนเพิ่มหอพัก')),
          );
        }
      }
    }
  }

  String _createChatRoomId(String userId, String ownerId) {
    var bytes = utf8.encode('$userId$ownerId-room');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _createChatGroupId(String userId, String ownerId) {
    var bytes = utf8.encode('$userId$ownerId-group');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        title: const Text('เพิ่มหอพัก'),
        actions: [
          IconButton(
            onPressed: () {
              // แสดง popup เพื่อยืนยันการเพิ่มข้อมูล
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('ยืนยันการเพิ่มข้อมูล'),
                    content: const Text('คุณแน่ใจหรือไม่ว่าจะเพิ่มข้อมูลนี้?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          // ปิด dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () {
                          // เรียกใช้ฟังก์ชันเพิ่มข้อมูล
                          _submitForm();
                          // ปิด dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text('ยืนยัน'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.save),
          ),
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
                _buildTextField('จำนวนห้องทั้งหมด', _totalRoomsController,
                    'กรุณากรอกจำนวนห้องทั้งหมด',
                    isNumber: true),
                _buildRoomTypeDropdown(),
                const SizedBox(height: 16),
                _buildDormTypeDropdown(),
                const SizedBox(height: 16),
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
