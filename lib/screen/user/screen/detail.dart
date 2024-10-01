import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class DormallDetailScreen extends StatefulWidget {
  final String dormId;

  const DormallDetailScreen({super.key, required this.dormId});

  @override
  State<DormallDetailScreen> createState() => _DormallDetailScreenState();
}

class _DormallDetailScreenState extends State<DormallDetailScreen> {
  late Future<Map<String, dynamic>> dormitoryData;
  late Future<List<Map<String, dynamic>>> reviewsData;
  final TextEditingController reviewController = TextEditingController();
  double _rating = 0;
  User? currentUser;
  Map<String, dynamic>? userData;
  double? distanceInKm; // เพิ่มตัวแปรสำหรับเก็บระยะทาง
  final Completer<GoogleMapController> _mapController = Completer();
  Map<String, dynamic>? selectedDormitory;

  @override
  void initState() {
    super.initState();
    dormitoryData = _fetchDormitoryData();
    reviewsData = _fetchReviewsData();
    _loadUserData(); // ดึงข้อมูลผู้ใช้
    selectedDormitory = {
      'id': widget.dormId,
      'name': currentUser?.displayName,
    };
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchDormitoryData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(widget.dormId)
        .get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _fetchReviewsData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('dormId', isEqualTo: widget.dormId)
        .get();
    return querySnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }


  Future<void> _addReview() async {
    if (reviewController.text.isEmpty || _rating == 0 || currentUser == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'dormId': widget.dormId,
        'user': currentUser!.email,
        'date': DateTime.now().toString(),
        'text': reviewController.text,
        'rating': _rating,
        'likes': 0,
        'comments': 0
      });

      await _updateDormitoryReviews();

      reviewController.clear();
      setState(() {
        _rating = 0;
        reviewsData = _fetchReviewsData();
      });
    } catch (e) {
      print('Error adding review: $e');
    }
  }

  Future<void> _updateDormitoryReviews() async {
    try {
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('dormId', isEqualTo: widget.dormId)
          .get();

      int reviewCount = reviewsSnapshot.size;
      double totalRating = 0;

      for (var doc in reviewsSnapshot.docs) {
        totalRating +=
            (doc.data() as Map<String, dynamic>)['rating']?.toDouble() ?? 0;
      }

      double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0;

      await FirebaseFirestore.instance
          .collection('dormitories')
          .doc(widget.dormId)
          .update({
        'reviewCount': reviewCount,
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating dormitory reviews: $e');
    }
  }

  Future<void> _bookDormitory(String userId, String dormitoryId) async {
  try {
    // แสดง AlertDialog เพื่อยืนยันการจอง
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จองหอพัก'),
        content: const Text('คุณต้องการจองหอพักนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด Dialog ถ้ายกเลิก
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // ปิด Dialog ถ้ากดยืนยัน

              // เริ่มบันทึกข้อมูลการจอง
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                'bookedDormitory': dormitoryId, // บันทึกหอพักที่จองในฟิลด์ของผู้ใช้
              });

              // ลดจำนวนห้องว่างในคอลเล็กชั่นของหอพัก
              DocumentReference dormitoryRef = FirebaseFirestore.instance
                  .collection('dormitories')
                  .doc(dormitoryId);
              DocumentSnapshot dormitorySnapshot = await dormitoryRef.get();

              int availableRooms = dormitorySnapshot.get('availableRooms');

              if (availableRooms > 0) {
                // ถ้ายังมีห้องว่าง ลดจำนวนห้องว่างลง 1
                await dormitoryRef.update({
                  'availableRooms': availableRooms - 1,
                  'usersBooked': FieldValue.arrayUnion([userId]), // เพิ่ม userId ไปยังลิสต์ผู้ใช้ที่จองหอพัก
                });

                // แสดงข้อความแจ้งเตือนสำเร็จ
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('จองหอพักสำเร็จ')),
                );
              } else {
                // ถ้าไม่มีห้องว่าง แจ้งเตือนผู้ใช้
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('หอพักนี้ไม่มีห้องว่างแล้ว')),
                );
              }
            },
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  } catch (e) {
    // จัดการข้อผิดพลาดถ้ามี
    print('Error booking dormitory: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('เกิดข้อผิดพลาดในการจองหอพัก')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดหอพัก'),
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: dormitoryData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var dormitory = snapshot.data!;

                // Extract the data for the dormitory
                double? dormLat = (dormitory['latitude'] as num?)?.toDouble();
                double? dormLon = (dormitory['longitude'] as num?)?.toDouble();

                // Display the dormitory image
                return Column(
                  children: [
                    SizedBox(
                      height: 200, // Adjust as needed
                      width: double.infinity,
                      child: Image.network(
                        dormitory['imageUrl'] ??
                            '', // Make sure 'imageUrl' is the correct field name
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dormitory['name'] ?? 'ไม่มีชื่อ',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ราคา: ${dormitory['price']} บาท/เดือน',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: dormitory['rating']?.toDouble() ?? 0.0,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                                direction: Axis.horizontal,
                              ),
                              Text(
                                ' ${dormitory['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                ' (${dormitory['reviewCount']?.toString() ?? '0'} รีวิว)',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            dormitory['description'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: dormitoryData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var dormitory = snapshot.data!;
                double? dormLat = (dormitory['latitude'] as num?)?.toDouble();
                double? dormLon = (dormitory['longitude'] as num?)?.toDouble();

                if (dormLat == null || dormLon == null) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'ข้อมูลหอพักนี้ยังไม่ครบท้วน',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                }

                // ignore: no_leading_underscores_for_local_identifiers
                final CameraPosition _kDormitoryPosition = CameraPosition(
                  target: LatLng(dormLat, dormLon),
                  zoom: 14.0,
                );

                return SizedBox(
                  height: 300, // Adjust as needed
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kDormitoryPosition,
                    markers: {
                      Marker(
                        markerId: const MarkerId('dormitory'),
                        position: LatLng(dormLat, dormLon),
                        infoWindow: InfoWindow(
                          title: dormitory['name'] ?? 'ไม่มีชื่อ',
                        ),
                      ),
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('รีวิว'),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: reviewsData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var reviews = snapshot.data!;
                return Column(
                  children: reviews.map((review) {
                    return ListTile(
                      title: Text(review['user'] ?? 'ผู้ใช้ไม่ระบุชื่อ'),
                      subtitle: Text(review['text'] ?? ''),
                      trailing: RatingBarIndicator(
                        rating: review['rating']?.toDouble() ?? 0.0,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  labelText: 'แสดงความคิดเห็น',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addReview,
                child: const Text('เพิ่มรีวิว'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _bookDormitory(currentUser!.uid, selectedDormitory!['id']);
        },
        child: const Icon(Icons.book),
      ),
    );
  }
}
