import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DormitoryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> dormitory;
  final String dormitoryId; // เพิ่มตัวแปรเพื่อรับ ID ของหอพัก

  const DormitoryDetailsScreen({
    super.key,
    required this.dormitory,
    required this.dormitoryId, // รับ ID ของหอพัก
  });

  @override
  _DormitoryDetailsScreenState createState() => _DormitoryDetailsScreenState();
}

class _DormitoryDetailsScreenState extends State<DormitoryDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableRoomsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _reviewCountController = TextEditingController();
  final TextEditingController _favoritesController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng _selectedLocation = const LatLng(0, 0); // ตำแหน่งเริ่มต้น
  late final String _dormitoryId;

  @override
  void initState() {
    super.initState();
    _dormitoryId = widget.dormitoryId; // ใช้ ID ที่ส่งมาจากหน้าจอก่อนหน้า
    _nameController.text = widget.dormitory['name'] ?? '';
    _priceController.text = widget.dormitory['price']?.toString() ?? '0';
    _availableRoomsController.text = widget.dormitory['availableRooms']?.toString() ?? '0';
    _addressController.text = widget.dormitory['address'] ?? '';
    _imageUrlController.text = widget.dormitory['imageUrl'] ?? '';
    _ratingController.text = widget.dormitory['rating']?.toString() ?? '0';
    _reviewCountController.text = widget.dormitory['reviewCount']?.toString() ?? '0';
    _favoritesController.text = widget.dormitory['favorites'] ?? '';
    _selectedLocation = LatLng(
      widget.dormitory['latitude'] ?? 0,
      widget.dormitory['longitude'] ?? 0,
    );
  }

  Future<void> _saveDormitory() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('dormitories').doc(_dormitoryId);

      // ข้อมูลที่ต้องการบันทึก
      final name = _nameController.text;
      final priceText = _priceController.text.trim();
      final availableRoomsText = _availableRoomsController.text.trim();
      final address = _addressController.text;
      final latitude = _selectedLocation.latitude;
      final longitude = _selectedLocation.longitude;
      final imageUrl = _imageUrlController.text;
      final ratingText = _ratingController.text.trim();
      final reviewCountText = _reviewCountController.text.trim();
      final favorites = _favoritesController.text;

      double price = 0;
      int availableRooms = 0;


      // ตรวจสอบและแปลงค่า
      if (priceText.isNotEmpty) {
        try {
          price = double.parse(priceText);
        } catch (e) {
          print('Invalid price format: $e');
        }
      }

      if (availableRoomsText.isNotEmpty) {
        try {
          availableRooms = int.parse(availableRoomsText);
        } catch (e) {
          print('Invalid availableRooms format: $e');
        }
      }

      final dormitoryData = {
        'name': name,
        'price': price,
        'availableRooms': availableRooms,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
      };

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(dormitoryData);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ข้อมูลหอพักได้รับการอัปเดต')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบเอกสารหอพัก')),
        );
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      print('Error saving dormitory: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
      );
    }
  }

  Future<void> _selectLocation() async {
    final GoogleMapController mapController = await _mapController.future;
    final LatLng currentLatLng = _selectedLocation;

    mapController.animateCamera(
      CameraUpdate.newLatLng(currentLatLng),
    );

    if (mounted) {
      setState(() {
        _selectedLocation = currentLatLng;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dormitory['name'] ?? 'ไม่มีชื่อ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDormitory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ชื่อหอพัก'),
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
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'ที่อยู่'),
            ),

            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('selectedLocation'),
                    position: _selectedLocation,
                    infoWindow: const InfoWindow(title: 'ตำแหน่งปัจจุบัน'),
                  ),
                },
                onTap: (LatLng latLng) {
                  setState(() {
                    _selectedLocation = latLng;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: _selectLocation,
              child: const Text('เลือกตำแหน่งใหม่'),
            ),
          ],
        ),
      ),
    );
  }
}
