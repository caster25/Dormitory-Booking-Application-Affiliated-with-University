// ignore_for_file: prefer_final_fields, unused_field, use_build_context_synchronously, unnecessary_cast

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/imagepick/edit_image.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/location/edit_location.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DormitoryEditDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> dormitory;
  final String dormitoryId;

  const DormitoryEditDetailsScreen({
    super.key,
    required this.dormitory,
    required this.dormitoryId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditDormitoryScreenState createState() => _EditDormitoryScreenState();
}

class _EditDormitoryScreenState extends State<DormitoryEditDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableRoomsController =
      TextEditingController();
  final TextEditingController _occupantsController = TextEditingController();
  final TextEditingController _totalRoomsController = TextEditingController();
  final TextEditingController _electricityRateController =
      TextEditingController();
  final TextEditingController _waterRateController = TextEditingController();
  final TextEditingController _furnitureFeeController = TextEditingController();
  final TextEditingController _securityDepositController =
      TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _ruleController = TextEditingController();
  final TextEditingController _contaxtController = TextEditingController();
  String? _selectedRoomType;
  String? _selectedDormType;

  LatLng _dormitoryLocation = const LatLng(0, 0); // Default location
  late final String _dormitoryId;

  List<String> _imageUrls = []; // List สำหรับเก็บ URL ของรูปภาพ
  List<File> _selectedImages = [];
  List<File> _imagesToUpload = []; // สำหรับเก็บภาพที่ต้องการอัปโหลด
  final NumberFormat _formatter = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    _dormitoryId = widget.dormitoryId;
    _nameController.text = widget.dormitory['name'] ?? '';
    _priceController.text = widget.dormitory['price']?.toString() ?? '0';
    _availableRoomsController.text =
        widget.dormitory['availableRooms']?.toString() ?? '0';
    _selectedRoomType = widget.dormitory['roomType'];
    _selectedDormType = widget.dormitory['dormType'];
    _occupantsController.text = widget.dormitory['occupants'] ?? '';
    _electricityRateController.text =
        widget.dormitory['electricityRate']?.toString() ?? '0';
    _totalRoomsController.text =
        widget.dormitory['totalRooms']?.toString() ?? '0';
    _waterRateController.text =
        widget.dormitory['waterRate']?.toString() ?? '0';
    _furnitureFeeController.text =
        widget.dormitory['furnitureFee']?.toString() ?? '0';
    _securityDepositController.text =
        widget.dormitory['securityDeposit']?.toString() ?? '0';
    _equipmentController.text = widget.dormitory['equipment'] ?? '';
    _dormitoryLocation = LatLng(
      widget.dormitory['latitude'] ?? 0,
      widget.dormitory['longitude'] ?? 0,
    );
    _addressController.text = widget.dormitory['address'] ?? '';
    _ruleController.text = widget.dormitory['rule'] ?? '';
    _contaxtController.text = widget.dormitory['contaxt'] ?? '';
    _loadImages();
  }

  // ignore: unused_element
  void _formatPrice() {
    String text =
        _priceController.text.replaceAll(',', ''); // เอาเครื่องหมาย , ออกก่อน
    if (text.isNotEmpty) {
      double value = double.parse(text);
      String formatted = _formatter.format(value); // จัดรูปแบบใหม่
      _priceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
            offset: formatted.length), // ตั้งตำแหน่ง cursor ใหม่
      );
    }
  }

  Future<void> _loadImages() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('dormitories')
          .doc(widget.dormitoryId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _imageUrls = List<String>.from(docSnapshot['imageUrl'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  Future<void> _addImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        // เพิ่มไฟล์ที่เลือกไปยังรายการของไฟล์ภาพที่เลือก
        _selectedImages.add(File(image.path));
        // เพิ่ม URL ไฟล์ที่เลือกลงใน _imageUrls เพื่อใช้ในฟังก์ชันบันทึก
        _imageUrls.add(image.path); // หรือใช้ image.path ตามความเหมาะสม
      });
    }
  }

  Future<String> _uploadImage(File image) async {
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

  Future<void> _deleteImage(String imageUrl) async {
    setState(() {
      _imageUrls.remove(imageUrl);
    });

    // อัปเดต Firestore
    await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(widget.dormitoryId)
        .update({'imageUrl': _imageUrls});
  }

  Future<void> _saveDormitory() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('dormitories')
          .doc(_dormitoryId);

      // ดึงข้อมูลปัจจุบันจาก Firestore
      final docSnapshot = await docRef.get();
      final currentData = docSnapshot.data();

      if (currentData != null) {
        final newData = {
          'name': _nameController.text,
          'price': int.parse(_priceController.text.trim()),
          'availableRooms': int.parse(_availableRoomsController.text.trim()),
          'roomType': _selectedRoomType,
          'dormType': _selectedDormType,
          'totalRooms': int.parse(_totalRoomsController.text),
          'occupants': _occupantsController.text,
          'electricityRate': int.parse(_electricityRateController.text.trim()),
          'waterRate': int.parse(_waterRateController.text.trim()),
          'furnitureFee': int.parse(_furnitureFeeController.text.trim()),
          'securityDeposit': int.parse(_securityDepositController.text.trim()),
          'equipment': _equipmentController.text,
          'latitude': _dormitoryLocation.latitude,
          'longitude': _dormitoryLocation.longitude,
          'address': _addressController.text,
          'rule': _ruleController.text,
          'contaxt': _contaxtController.text,
        };

        // เช็คว่ามีการเปลี่ยนแปลงข้อมูลหรือไม่
        bool isDataChanged = false;
        newData.forEach((key, value) {
          if (currentData[key] != value) {
            isDataChanged = true;
          }
        });

        // เช็คการเปลี่ยนแปลงของ URL รูปภาพ
        if (currentData['imageUrl'].toString() != _imageUrls.toString()) {
          isDataChanged = true; // ถ้ารูปภาพมีการเปลี่ยนแปลง
        }

        if (!isDataChanged) {
          // หากไม่มีการเปลี่ยนแปลงข้อมูล
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่มีการเปลี่ยนแปลงข้อมูล')),
          );
          return; // ออกจากฟังก์ชันโดยไม่บันทึกข้อมูล
        }

        // ถ้ามีการเปลี่ยนแปลงข้อมูล แสดงกล่องยืนยันการบันทึก
        bool confirmSave = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ยืนยันการบันทึก'),
              content: const Text('คุณแน่ใจหรือไม่ว่าต้องการบันทึกข้อมูลนี้?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // ปิด dialog และไม่ยืนยัน
                  },
                  child: const Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // ปิด dialog และยืนยัน
                  },
                  child: const Text('ยืนยัน'),
                ),
              ],
            );
          },
        );

        // ถ้า confirmSave เป็น true ถึงจะดำเนินการบันทึกข้อมูล
        if (confirmSave == true) {
          // รักษา URL รูปภาพเก่าไว้
          List<String> allImageUrls = List.from(currentData['imageUrl'] ?? []);

          // อัปโหลดภาพที่เลือกทั้งหมดไปยัง Firebase Storage
          for (var image in _selectedImages) {
            String imageUrl = await _uploadImage(image);
            allImageUrls.add(imageUrl);
          }

          // อัปเดตข้อมูลใหม่รวมทั้ง URL รูปภาพที่อัปโหลด
          newData['imageUrl'] = allImageUrls;

          await docRef.update(newData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ข้อมูลหอพักได้รับการอัปเดต')),
          );
          Navigator.pop(context); // กลับไปหน้าก่อนหน้า
        }
      }
    } catch (e) {
      print('Error: $e'); // แสดงข้อผิดพลาดใน console
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
      );
    }
  }

  // ignore: unused_element
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _dormitoryLocation = LatLng(position.latitude, position.longitude);
    });

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(_dormitoryLocation));
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

  Widget _buildRoomTypeDropdown() {
    const EdgeInsets.all(20);
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
          _selectedRoomType = value;
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

  Widget _buildDormTypeDropdown() {
    const EdgeInsets.all(20);
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
          _selectedDormType = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
          title: 'แก้ไขข้อมูลหอพัก', onSave: _saveDormitory, context: context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFieldInput(
                controller: _nameController,
                labelText: 'ชื่อหอพัก',
              ),
              TextFieldInput(
                controller: _addressController,
                labelText: 'ที่อยู่หอพัก',
              ),
              TextFieldInput(
                controller: _priceController,
                labelText: 'ราคา',
                keyboardType: TextInputType.number,
              ),
              TextFieldInput(
                controller: _availableRoomsController,
                labelText: 'ห้องว่าง',
                keyboardType: TextInputType.number,
              ),
              TextFieldInput(
                controller: _totalRoomsController,
                labelText: 'จำนวนห้องทั้งหมด',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildRoomTypeDropdown(),
              const SizedBox(height: 10),
              _buildDormTypeDropdown(),
              const SizedBox(height: 10),
              TextFieldInput(
                controller: _occupantsController,
                labelText: 'จำนวนคนพัก',
              ),
              TextFieldInput(
                controller: _electricityRateController,
                labelText: 'ค่าไฟ (หน่วยละ)',
                keyboardType: TextInputType.number,
              ),
              TextFieldInput(
                controller: _waterRateController,
                labelText: 'ค่าน้ำ (หน่วยละ)',
                keyboardType: TextInputType.number,
              ),
              TextFieldInput(
                controller: _furnitureFeeController,
                labelText: 'ค่าเฟอร์นิเจอร์เพิ่มเติม',
                keyboardType: TextInputType.number,
              ),
              TextFieldInput(
                controller: _securityDepositController,
                labelText: 'ค่าประกันความเสียหาย',
                keyboardType: TextInputType.number,
              ),
              TextFieldInput(
                controller: _ruleController,
                labelText: 'กฎขอหอพัก',
              ),
              TextFieldInput(
                controller: _contaxtController,
                labelText: 'ช่องทางติดต่อ',
              ),
              TextFieldInput(
                controller: _equipmentController,
                labelText: 'อุปกรณ์ที่มีในห้องพัก',
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print("Navigating to Edit Location");
                  _navigateToEditLocation();
                },
                child: const Text('แก้ไขตำแหน่งหมุด'),
              ),
              const SizedBox(height: 16),
              Text('รูปภาพของหอพัก',
                  style: Theme.of(context).textTheme.titleMedium),
              ImagePickerRowd(
                selectedImages:
                    _imageUrls, // ใช้ _imageUrls โดยตรงที่เป็น List<String> ที่เก็บ URL
                onDeleteImage: (index) async {
                  String imageUrl = _imageUrls[index];
                  await _deleteImage(imageUrl);
                },
              ),  
              ElevatedButton(
                onPressed: _addImage,
                child: const Text('เพิ่มรูปภาพ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final int? maxLines;

  const TextFieldInput({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
