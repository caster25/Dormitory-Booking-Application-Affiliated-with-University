// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

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
  // ignore: unused_field, prefer_final_fields
  double _rating = 0;
  User? currentUser;
  Map<String, dynamic>? userData;
  double? distanceInKm;
  final Completer<GoogleMapController> _mapController = Completer();
  Map<String, dynamic>? selectedDormitory;
  final formatNumber = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    dormitoryData = _fetchDormitoryData();
    reviewsData = _fetchReviewsData();
    _loadUserData();
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
        .where('dormitoryId', isEqualTo: widget.dormId)
        .get();
    return querySnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();
  }

  // ignore: unused_element
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

  // ignore: unused_element
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

  // ignore: unused_element
  Future<void> _updateDormitoryReviews() async {
    try {
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('dormitoryId', isEqualTo: widget.dormId)
          .get();

      int reviewCount = reviewsSnapshot.size;
      double totalRating = 0; // เปลี่ยน totalRating เป็น double

      for (var doc in reviewsSnapshot.docs) {
        totalRating +=
            (doc.data() as Map<String, dynamic>)['rating']?.toDouble() ?? 0;
      }

      // คำนวณค่าเฉลี่ยคะแนนให้เป็น int
      int averageRating =
          reviewCount > 0 ? (totalRating / reviewCount).toInt() : 0;

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

  String _createChatRoomId(String userId, String ownerId) {
    var bytes = utf8.encode('$userId$ownerId');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ignore: unused_element
  String _createChatGroupId(String userId, String ownerId) {
    var bytes = utf8.encode('$userId$ownerId');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _bookDormitory(
      BuildContext context, String userId, String dormitoryId) async {
    try {
      // Retrieve dormitory data to check available rooms
      DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
          .collection('dormitories')
          .doc(dormitoryId)
          .get();

      if (!dormitorySnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('หอพักไม่พบในระบบ')),
        );
        return;
      }

      int availableRooms = dormitorySnapshot.get('availableRooms');

      // If rooms are full, show a notification and prevent booking
      if (availableRooms <= 0) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ห้องพักเต็ม'),
            content: const Text('หอพักนี้ไม่มีห้องว่างแล้ว'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
        return;
      }

      // Retrieve user data to check for existing bookings
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ผู้ใช้นี้ไม่พบในระบบ')),
        );
        return;
      }

      // Check if the user already has a booking
      String? bookedDormitory =
          (userSnapshot.data() as Map<String, dynamic>)['bookedDormitory'];

      if (bookedDormitory != null && bookedDormitory.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('แจ้งเตือน'),
            content: const Text('คุณมีการจองหอพักไว้แล้วไม่สามารถจองเพิ่มได้'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('จองหอพัก'),
          content: const Text('คุณต้องการจองหอพักนี้หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog if canceled
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog if confirmed
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('การจองสำเร็จ'),
                    content: const Text(
                        'คุณได้จองหอพักเรียบร้อยแล้ว\nรอการยืนยันจากเจ้าของหอพัก\nหรือทำการติดต่อกับเจ้าของหอพัก'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('ตกลง'),
                      ),
                    ],
                  ),
                );

                // Create chatGroupId and chatRoomId
                String chatGroupId = dormitorySnapshot
                    .get('chatGroupId'); // Use dormitoryId as the chatGroupId
                String chatRoomId = _createChatRoomId(
                    userId, dormitoryId); // Generate unique chatRoomId

                // Update dormitory data
                await FirebaseFirestore.instance
                    .collection('dormitories')
                    .doc(dormitoryId)
                    .update({
                  'availableRooms': availableRooms - 1,
                  'usersBooked': FieldValue.arrayUnion([userId]),
                  'chatRoomId': FieldValue.arrayUnion([chatRoomId]),
                });

                // Update user data with booking information
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'bookedDormitory': dormitoryId,
                  'chatRoomId': FieldValue.arrayUnion([chatRoomId]),
                  'chatGroupId': chatGroupId,
                });

                // Create chatRoom entry in chatRooms collection
                await FirebaseFirestore.instance
                    .collection('chatRooms')
                    .doc(chatRoomId)
                    .set({
                  'participants': [userId, dormitoryId],
                  'createdAt': FieldValue.serverTimestamp(),
                  'lastMessage': '',
                  'lastMessageAt': FieldValue.serverTimestamp(),
                });

                // Add notification data to the notifications collection
                await FirebaseFirestore.instance
                    .collection('notifications')
                    .add({
                  'userId': userId,
                  'dormitoryId': dormitoryId,
                  'type': 'booking', // Type of notification
                  'message': 'การจองหอพักสำเร็จ',
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': 'unread', // Mark as unread initially
                });

                // Update user's notification field to track the notification
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'notifications': FieldValue.arrayUnion([
                    {
                      'dormitoryId': dormitoryId,
                      'type': 'booking',
                      'timestamp': FieldValue.serverTimestamp(),
                    }
                  ]),
                });
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle errors
      print('Error booking dormitory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการจองหอพัก')),
      );
    }
  }

  // ignore: unused_element
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดงรายละเอียดหอพัก
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
                double? dormLat = (dormitory['latitude'] as num?)?.toDouble();
                double? dormLon = (dormitory['longitude'] as num?)?.toDouble();

                List<String> imageUrls =
                    List<String>.from(dormitory['imageUrl'] ?? []);

                return Column(
                  children: [
                    // Section สำหรับเลื่อนรูปภาพ
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                      ),
                      items: imageUrls.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                // เมื่อกดรูปจะนำทางไปยังหน้าจอแสดงรูปขนาดใหญ่
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FullScreenImage(imageUrl: url),
                                  ),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dormitory Name
                                Text(
                                  dormitory['name'] ?? 'ไม่มีชื่อ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),

                                // Available rooms
                                Text(
                                  'จำนวนห้องว่าง: ${dormitory['availableRooms'] ?? 'ไม่มีข้อมูล'} ห้อง',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey[700]),
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Price per term
                                Text(
                                  'ราคา: ${formatNumber.format(dormitory['price'])} บาท/เทอม',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black87),
                                ),
                                const SizedBox(height: 10),

                                // Dormitory type
                                Text(
                                  'ประเภทหอพัก: ${dormitory['dormType'] ?? 'ไม่มีข้อมูล'}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 10),

                                // Room type
                                Text(
                                  'ประเภทห้อง: ${dormitory['roomType'] ?? 'ไม่มีข้อมูล'}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 10),

                                // Number of occupants
                                Text(
                                  'จำนวนคนพัก: ${dormitory['occupants'] ?? 'ไม่มีข้อมูล'} คน',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Electricity charge
                                Text(
                                  'ค่าไฟ: ${dormitory['electricityRate'] ?? 'ไม่มีข้อมูล'} บาท/หน่วย',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 10),

                                // Water charge
                                Text(
                                  'ค่าน้ำ: ${dormitory['waterRate'] ?? 'ไม่มีข้อมูล'} บาท/หน่วย',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Security deposit
                                Text(
                                  'ค่าประกันความเสียหาย: ${formatNumber.format(dormitory['securityDeposit'])} บาท',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 10),

                                // Dormitory rules
                                Text(
                                  'กฎของหอพัก:',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  dormitory['rule'] ?? 'ไม่มีข้อมูล',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Equipment in the room
                                Text(
                                  'อุปกรณ์ในห้องพัก:',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  dormitory['equipment'] != null &&
                                          dormitory['equipment'].isNotEmpty
                                      ? dormitory['equipment']
                                          .split('\n')
                                          .map((e) => '• $e')
                                          .join('\n')
                                      : 'ไม่มีข้อมูล',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Rating and Reviews
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: dormitory['rating']?.toDouble() ??
                                          0.0,
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 20.0,
                                      direction: Axis.horizontal,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      dormitory['rating'] != null
                                          ? dormitory['rating']
                                              .toStringAsFixed(1)
                                          : '0.0',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      ' (${dormitory['reviewCount'] ?? 0} รีวิว)',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Map Section
                    if (dormLat != null && dormLon != null) ...[
                      SizedBox(
                        height: 300, // Adjust as needed
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(dormLat, dormLon),
                            zoom: 14.0,
                          ),
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
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'ข้อมูลหอพักนี้ยังไม่ครบท้วน',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
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
                    // ดึงชื่อผู้ใช้จาก Firestore โดยใช้ userId
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users') // ชื่อคอลเลกชันผู้ใช้
                          .doc(review['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(
                              title: Text('กำลังโหลดชื่อผู้ใช้...'));
                        }

                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        String userName =
                            userData['username'] ?? 'ผู้ใช้ไม่ระบุชื่อ';

                        return ListTile(
                          title: Text(userName), // แสดงชื่อผู้ใช้
                          subtitle: Text(review['reviewText'] ?? ''),
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
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _bookDormitory(context, currentUser!.uid, selectedDormitory!['id']);
        },
        child: const Icon(Icons.book),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // ให้ผู้ใช้สามารถเลื่อนดูภาพได้
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
