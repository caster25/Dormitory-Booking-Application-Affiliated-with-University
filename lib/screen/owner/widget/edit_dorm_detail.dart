import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditDormitoryScreen extends StatefulWidget {
  final Map<String, dynamic> dormitory;
  final String dormitoryId;

  const EditDormitoryScreen({
    super.key,
    required this.dormitory,
    required this.dormitoryId,
  });

  @override
  _EditDormitoryScreenState createState() => _EditDormitoryScreenState();
}

class _EditDormitoryScreenState extends State<EditDormitoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableRoomsController =
      TextEditingController();
  final TextEditingController _roomTypeController = TextEditingController();
  final TextEditingController _occupantsController = TextEditingController();
  final TextEditingController _monthlyRentController = TextEditingController();
  final TextEditingController _maintenanceFeeController =
      TextEditingController();
  final TextEditingController _electricityRateController =
      TextEditingController();
  final TextEditingController _waterRateController = TextEditingController();
  final TextEditingController _furnitureFeeController = TextEditingController();
  final TextEditingController _securityDepositController =
      TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng _dormitoryLocation = const LatLng(0, 0); // Default location
  late final String _dormitoryId;

  @override
  void initState() {
    super.initState();
    _dormitoryId = widget.dormitoryId;
    _nameController.text = widget.dormitory['name'] ?? '';
    _priceController.text = widget.dormitory['price']?.toString() ?? '0';
    _availableRoomsController.text =
        widget.dormitory['availableRooms']?.toString() ?? '0';
    _roomTypeController.text = widget.dormitory['roomType'] ?? '';
    _occupantsController.text =
        widget.dormitory['occupants']?.toString() ?? '0';
    _monthlyRentController.text =
        widget.dormitory['monthlyRent']?.toString() ?? '0';
    _maintenanceFeeController.text =
        widget.dormitory['maintenanceFee']?.toString() ?? '0';
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
  }

  Future<void> _saveDormitory() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('dormitories')
          .doc(_dormitoryId);
      final dormitoryData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text.trim()),
        'availableRooms': int.parse(_availableRoomsController.text.trim()),
        'roomType': _roomTypeController.text,
        'occupants': int.parse(_occupantsController.text.trim()),
        'monthlyRent': double.parse(_monthlyRentController.text.trim()),
        'maintenanceFee': double.parse(_maintenanceFeeController.text.trim()),
        'electricityRate': double.parse(_electricityRateController.text.trim()),
        'waterRate': double.parse(_waterRateController.text.trim()),
        'furnitureFee': double.parse(_furnitureFeeController.text.trim()),
        'securityDeposit': double.parse(_securityDepositController.text.trim()),
        'equipment': _equipmentController.text,
        'latitude': _dormitoryLocation.latitude,
        'longitude': _dormitoryLocation.longitude,
      };

      await docRef.update(dormitoryData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ข้อมูลหอพักได้รับการอัปเดต')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
      );
    }
  }

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
              controller: _roomTypeController,
              decoration: const InputDecoration(labelText: 'ประเภทห้องพัก'),
            ),
            TextField(
              controller: _occupantsController,
              decoration: const InputDecoration(labelText: 'จำนวนคนพัก'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _monthlyRentController,
              decoration: const InputDecoration(labelText: 'อัตราค่าห้องพัก'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maintenanceFeeController,
              decoration: const InputDecoration(labelText: 'ค่าบำรุงหอ'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _electricityRateController,
              decoration: const InputDecoration(labelText: 'ค่าไฟ (หน่วยละ)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _waterRateController,
              decoration: const InputDecoration(labelText: 'ค่าน้ำ (หน่วยละ)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _furnitureFeeController,
              decoration:
                  const InputDecoration(labelText: 'ค่าเฟอร์นิเจอร์เพิ่มเติม'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _securityDepositController,
              decoration:
                  const InputDecoration(labelText: 'ค่าประกันความเสียหาย'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _equipmentController,
              decoration:
                  const InputDecoration(labelText: 'อุปกรณ์ที่มีในห้องพัก'),
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
          ],
        ),
      ),
    );
  }
}

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
    print("EditLocationScreen is being displayed");
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขตำแหน่งหมุด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(
                  context, _currentLocation); // ส่งตำแหน่งหมุดที่แก้ไขกลับไป
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
