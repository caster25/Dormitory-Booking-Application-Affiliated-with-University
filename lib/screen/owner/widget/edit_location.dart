import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class EditLocationScreen extends StatefulWidget {
  final LatLng initialLocation;

  // ignore: use_super_parameters
  const EditLocationScreen({Key? key, required this.initialLocation}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // ตรวจสอบสถานะตำแหน่ง
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      } else {
        // จัดการเมื่อไม่ได้รับอนุญาต
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission to access location was denied')),
        );
      }
    } catch (e) {
      // จัดการข้อผิดพลาด
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dormitory Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, _currentLocation); // Return new location
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 15,
        ),
        onTap: (LatLng location) {
          setState(() {
            _currentLocation = location;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('dormLocation'),
            position: _currentLocation,
          ),
        },
      ),
    );
  }
}
