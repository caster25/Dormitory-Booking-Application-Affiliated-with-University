import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DormitoryFormScreen extends StatefulWidget {
  const DormitoryFormScreen({super.key});

  @override
  State<DormitoryFormScreen> createState() => _DormitoryFormScreenState();
}

class _DormitoryFormScreenState extends State<DormitoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _dormNameController = TextEditingController();
  final TextEditingController _dormPriceController = TextEditingController();
  final TextEditingController _availableRoomsController = TextEditingController();
  
  File? _dormImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _dormImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // ดำเนินการหลังจากตรวจสอบข้อมูลว่าถูกต้อง
      print('ชื่อหอพัก: ${_dormNameController.text}');
      print('ราคาหอพัก: ${_dormPriceController.text}');
      print('ห้องว่าง: ${_availableRoomsController.text}');
      if (_dormImage != null) {
        print('มีรูปภาพหอพักที่เลือกแล้ว');
      }
      // ส่งข้อมูลไปยังฐานข้อมูลหรือดำเนินการอื่น ๆ
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
