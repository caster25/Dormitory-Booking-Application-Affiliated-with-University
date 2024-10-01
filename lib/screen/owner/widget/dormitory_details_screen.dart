import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DormitoryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> dormitory;
  final String dormitoryId;

  const DormitoryDetailsScreen({
    super.key,
    required this.dormitory,
    required this.dormitoryId,
  });

  @override
  _DormitoryDetailsScreenState createState() => _DormitoryDetailsScreenState();
}

class _DormitoryDetailsScreenState extends State<DormitoryDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableRoomsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng _dormitoryLocation = const LatLng(0, 0); // ตำแหน่งหมุด
  late final String _dormitoryId;

  @override
  void initState() {
    super.initState();
    _dormitoryId = widget.dormitoryId;
    _nameController.text = widget.dormitory['name'] ?? '';
    _priceController.text = widget.dormitory['price']?.toString() ?? '0';
    _availableRoomsController.text = widget.dormitory['availableRooms']?.toString() ?? '0';
    _addressController.text = widget.dormitory['address'] ?? '';
    _dormitoryLocation = LatLng(
      widget.dormitory['latitude'] ?? 0,
      widget.dormitory['longitude'] ?? 0,
    );
  }

  // ฟังก์ชันดึงตำแหน่งจาก GPS
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

  // ฟังก์ชันบันทึกข้อมูลหอพัก
  Future<void> _saveDormitory() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('dormitories').doc(_dormitoryId);
      final dormitoryData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text.trim()),
        'availableRooms': int.parse(_availableRoomsController.text.trim()),
        'address': _addressController.text,
        'latitude': _dormitoryLocation.latitude,  // ใช้ตำแหน่งหมุดที่เลือก
        'longitude': _dormitoryLocation.longitude, // ใช้ตำแหน่งหมุดที่เลือก
      };

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update(dormitoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ข้อมูลหอพักได้รับการอัปเดต')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบเอกสารหอพัก')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print('Error saving dormitory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
      );
    }
  }

  // หน้าจอแก้ไขตำแหน่งหมุด
  Future<void> _navigateToEditLocation() async {
    final newLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => EditLocationScreen(initialLocation: _dormitoryLocation),
      ),
    );
    if (newLocation != null) {
      setState(() {
        _dormitoryLocation = newLocation;
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
            ElevatedButton(
              onPressed: _navigateToEditLocation,
              child: const Text('แก้ไขตำแหน่งหมุด'),
            ),
          ],
        ),
      ),
    );
  }
}

// หน้าจอแก้ไขตำแหน่งหมุด
class EditLocationScreen extends StatefulWidget {
  final LatLng initialLocation;

  const EditLocationScreen({super.key, required this.initialLocation});

  @override
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขตำแหน่งหมุด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _currentLocation); // ส่งตำแหน่งหมุดที่แก้ไขกลับไป
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
              _currentLocation = position.target; // อัปเดตตำแหน่งหมุด
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
