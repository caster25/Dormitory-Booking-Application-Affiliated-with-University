import 'package:dorm_app/features/screen/owner/screen/home/screen/dorm/dorm/dormitory_edit_details_screen.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/location/edit_location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddLocation extends StatefulWidget {
  final Function(LatLng) onLocationChanged;
  final LatLng? initialLocation; // สามารถเป็น null ได้

  const AddLocation({
    super.key,
    required this.onLocationChanged,
    this.initialLocation,
  });

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  late LatLng _currentLocation;
  bool _isLocationServiceEnabled = false;
  bool _isLocationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // ตรวจสอบการเปิดใช้บริการตำแหน่งและการอนุญาต
  Future<void> _checkLocationPermission() async {
    // ตรวจสอบการเปิดใช้บริการตำแหน่ง
    _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_isLocationServiceEnabled) {
      _showLocationServiceDisabledDialog();
      return;
    }

    // ตรวจสอบสิทธิ์การเข้าถึงตำแหน่ง
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      bool userAccepted = await _showPermissionDialog();
      if (userAccepted) {
        permission = await Geolocator.requestPermission();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDeniedForeverDialog();
      return;
    }

    setState(() {
      _isLocationPermissionGranted =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;
    });

    if (_isLocationPermissionGranted) {
      _currentLocation = await _getCurrentLocation();
      setState(() {}); // อัปเดต UI
    }
  }

  Future<void> _showLocationServiceDisabledDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ไม่สามารถเปิดบริการตำแหน่ง'),
        content: const Text('โปรดเปิดบริการตำแหน่งในการตั้งค่าอุปกรณ์ของคุณ'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ขอสิทธิ์เข้าถึงตำแหน่ง'),
            content: const Text(
              'แอปนี้ต้องการเข้าถึงตำแหน่งของคุณเพื่อระบุตำแหน่งของหมุดในแผนที่ คุณต้องการอนุญาตหรือไม่?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ปฏิเสธ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('อนุญาต'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showPermissionDeniedForeverDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ไม่สามารถเข้าถึงตำแหน่งได้'),
        content: const Text(
          'คุณได้บล็อกการเข้าถึงตำแหน่ง หากต้องการเปิดใช้งาน โปรดไปที่การตั้งค่าและอนุญาตสิทธิ์ให้แอปนี้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text('ไปที่การตั้งค่า'),
          ),
        ],
      ),
    );
  }

  Future<LatLng> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _navigateToEditLocation(BuildContext context) async {
    final newLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditLocationScreen(initialLocation: _currentLocation),
      ),
    );
    if (newLocation != null) {
      widget.onLocationChanged(newLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLocationPermissionGranted
          ? () {
              _navigateToEditLocation(context);
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('โปรดให้สิทธิ์เข้าถึงตำแหน่ง')),
              );
            },
      child: const Text('แก้ไขตำแหน่งหมุด'),
    );
  }
}