import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DormitoryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> dormitory;
  final String dormitoryId;

  const DormitoryDetailsScreen({
    super.key,
    required this.dormitory,
    required this.dormitoryId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditDormitoryScreenState createState() => _EditDormitoryScreenState();
}

class _EditDormitoryScreenState extends State<DormitoryDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableRoomsController =
      TextEditingController();
  final TextEditingController _occupantsController = TextEditingController();
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
  // ignore: prefer_final_fields
  List<File> _selectedImages = [];
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
      });

      // อัปโหลดภาพไปยัง Firebase Storage
      String imageUrl = await _uploadImage(File(image.path));

      // บันทึก URL ลงใน Firestore
      setState(() {
        _imageUrls.add(imageUrl);
      });

      await FirebaseFirestore.instance
          .collection('dormitories')
          .doc(widget.dormitoryId)
          .update({'imageUrl': _imageUrls});
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
      // ignore: unnecessary_cast
      final currentData = docSnapshot.data() as Map<String, dynamic>?;

      if (currentData != null) {
        final newData = {
          'name': _nameController.text,
          'price': int.parse(_priceController.text.trim()),
          'availableRooms': int.parse(_availableRoomsController.text.trim()),
          'roomType': _selectedRoomType,
          'dormType': _selectedDormType,
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
          'imageUrl': _imageUrls // เพิ่ม URL รูปภาพใหม่ใน newData
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
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่มีการเปลี่ยนแปลงข้อมูล')),
          );
          return; // ออกจากฟังก์ชันโดยไม่บันทึกข้อมูล
        }

        // ถ้ามีการเปลี่ยนแปลงข้อมูล แสดงกล่องยืนยันการบันทึก
        bool confirmSave = await showDialog(
          // ignore: use_build_context_synchronously
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
          await docRef.update(newData);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ข้อมูลหอพักได้รับการอัปเดต')),
          );
          // ignore: use_build_context_synchronously
          Navigator.pop(context); // กลับไปหน้าก่อนหน้า
        }
      }
    } catch (e) {
      print('Error: $e'); // แสดงข้อผิดพลาดใน console
      // ignore: use_build_context_synchronously
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
        appBar: AppBar(
          title: const Text('แก้ไขข้อมูลหอพัก'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveDormitory,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'ชื่อหอพัก'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'ที่อยู่หอพัก'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'ราคา'),
                  keyboardType: TextInputType.number,
                ),

                TextField(
                  controller: _availableRoomsController,
                  decoration: const InputDecoration(labelText: 'ห้องว่าง'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _buildRoomTypeDropdown(),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                _buildDormTypeDropdown(),
                const SizedBox(height: 10),
                TextField(
                    controller: _occupantsController,
                    decoration: const InputDecoration(labelText: 'จำนวนคนพัก')),
                TextField(
                  controller: _electricityRateController,
                  decoration:
                      const InputDecoration(labelText: 'ค่าไฟ (หน่วยละ)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _waterRateController,
                  decoration:
                      const InputDecoration(labelText: 'ค่าน้ำ (หน่วยละ)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _furnitureFeeController,
                  decoration: const InputDecoration(
                      labelText: 'ค่าเฟอร์นิเจอร์เพิ่มเติม'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _securityDepositController,
                  decoration:
                      const InputDecoration(labelText: 'ค่าประกันความเสียหาย'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _ruleController,
                  decoration: const InputDecoration(labelText: 'กฎขอหอพัก'),
                ),
                TextField(
                  controller: _contaxtController,
                  decoration: const InputDecoration(labelText: 'ช่องทางติดต่อ'),
                ),
                TextField(
                  controller: _equipmentController,
                  decoration:
                      const InputDecoration(labelText: 'อุปกรณ์ที่มีในห้องพัก'),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                // Button to edit the location marker
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
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length + _imageUrls.length,
                    itemBuilder: (context, index) {
                      if (index < _selectedImages.length) {
                        // แสดงภาพที่ผู้ใช้เลือก
                        return Stack(
                          children: [
                            Image.file(
                              _selectedImages[index],
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            Image.network(
                              _imageUrls[index - _selectedImages.length],
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteImage(
                                    _imageUrls[index - _selectedImages.length]),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _addImage,
                  child: const Text('เพิ่มรูปภาพ'),
                ),
              ],
            ),
          ),
        ));
  }
}

class EditLocationScreen extends StatefulWidget {
  final LatLng initialLocation;

  const EditLocationScreen({super.key, required this.initialLocation});

  @override
  // ignore: library_private_types_in_public_api
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  LatLng _currentLocation = const LatLng(0, 0);
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    print("EditLocationScreen is being displayed");
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขตำแหน่งหมุด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _currentLocation);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14.0,
            ),
            onCameraMove: (CameraPosition position) {
              _currentLocation = position.target;
            },
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
