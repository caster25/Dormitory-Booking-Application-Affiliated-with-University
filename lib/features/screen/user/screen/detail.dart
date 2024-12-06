// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/data/src/service.dart';
import 'package:dorm_app/features/screen/user/data/src/service_dorm.dart';
import 'package:dorm_app/features/screen/user/screen/featurres/image/image_full.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirestoreServiceUser firestoreServiceUser = FirestoreServiceUser();
  final FirebaseServiceDorm firestoreServiceDorm = FirebaseServiceDorm();
  // ignore: unused_field, prefer_final_fields
  double _rating = 0;
  User? currentUser;
  Map<String, dynamic>? userData;
  double? distanceInKm;
  final Completer<GoogleMapController> _mapController = Completer();
  Map<String, dynamic>? selectedDormitory;
  Map<String, dynamic>? ownerData;
  final formatNumber = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    dormitoryData = _fetchDormitoryData();
    reviewsData = _fetchReviewsData();
    _loadUserData();
    _fetchOwnerData();
    selectedDormitory = {
      'id': widget.dormId,
      'name': currentUser?.displayName,
    };
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await firestoreServiceUser.getUserStream(currentUser!.uid).first;
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchDormitoryData() async {
    DocumentSnapshot doc =
        await firestoreServiceDorm.getOwnerDataOnce(widget.dormId);
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> _fetchOwnerData() async {
    DocumentSnapshot dormitoryDoc =
        await firestoreServiceDorm.getOwnerDataOnce(widget.dormId);

    Map<String, dynamic>? dormitoryData =
        dormitoryDoc.data() as Map<String, dynamic>?;

    if (dormitoryData != null) {
      String ownerId = dormitoryData['submittedBy'] ?? '';

      if (ownerId.isNotEmpty) {
        DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(ownerId)
            .get();

        if (ownerDoc.exists) {
          setState(() {
            ownerData = ownerDoc.data() as Map<String, dynamic>;
          });
        }
      }
    }
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
      DocumentSnapshot dormitorySnapshot =
          await firestoreServiceDorm.getOwnerDataOnce(dormitoryId);

      if (!dormitorySnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TextWidget.buildText(text: 'หอพักไม่พบในระบบ')),
        );
        return;
      }

      int availableRooms = dormitorySnapshot.get('availableRooms');

      // If rooms are full, show a notification and prevent booking
      if (availableRooms <= 0) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: TextWidget.buildText(text: 'ห้องพักเต็ม'),
            content: TextWidget.buildText(text: 'หอพักนี้ไม่มีห้องว่างแล้ว'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: TextWidget.buildText(text: 'ตกลง'),
              ),
            ],
          ),
        );
        return;
      }

      // Retrieve user data to check for existing bookings
      DocumentSnapshot userSnapshot =
          await firestoreServiceUser.getUserStream(userId).first;

      if (!userSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TextWidget.buildText(text: 'ผู้ใช้นี้ไม่พบในระบบ')),
        );
        return;
      }

      // Check if the user already has a booking
      String? bookedDormitory =
          (userSnapshot.data() as Map<String, dynamic>)['bookedDormitory'];

      String? currentDormitoryId =
          (userSnapshot.data() as Map<String, dynamic>)['currentDormitoryId'];

      if ((bookedDormitory != null && bookedDormitory.isNotEmpty)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: TextWidget.buildText(text: 'แจ้งเตือน'),
            content: TextWidget.buildText(text: 
                'คุณมีการจองหอพักแล้วไม่สามารถจองเพิ่มได้'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: TextWidget.buildText(text: 'ตกลง'),
              ),
            ],
          ),
        );
      } else if (currentDormitoryId != null && currentDormitoryId.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: TextWidget.buildText(text: 'แจ้งเตือน'),
            content: TextWidget.buildText(text: 
                'คุณมีหอพักอยู่แล้ว ไม่สามารถทำการจองใหม่ได้'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: TextWidget.buildText(text: 'ตกลง'),
              ),
            ],
          ),
        );
      } else {
        // Show the booking confirmation dialog if no booking or current dormitory exists
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: TextWidget.buildText(text: 'จองหอพัก'),
            content: TextWidget.buildText(text: 'คุณต้องการจองหอพักนี้หรือไม่?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog if canceled
                },
                child: TextWidget.buildText(text: 'ยกเลิก'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog if confirmed
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: TextWidget.buildText(text: 'การจองสำเร็จ'),
                      content: TextWidget.buildText(text: 
                          'คุณได้จองหอพักเรียบร้อยแล้ว\nรอการยืนยันจากเจ้าของหอพัก\nหรือทำการติดต่อกับเจ้าของหอพัก'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: TextWidget.buildText(text: 'ตกลง'),
                        ),
                      ],
                    ),
                  );

                  // Create chatGroupId and chatRoomId
                  String chatGroupId = dormitorySnapshot.get('chatGroupId');
                  String chatRoomId = _createChatRoomId(userId, dormitoryId);

                  // Update dormitory data
                  await firestoreServiceUser.updateDormitoryBooking(
                      dormitoryId, userId, availableRooms, chatRoomId);

                  // Update user data with booking information
                  await firestoreServiceUser.updateUserBooking(
                      userId, dormitoryId, chatRoomId, chatGroupId);

                  // Create chatRoom entry in chatRooms collection
                  await firestoreServiceUser.createChatRoom(
                      chatRoomId, userId, dormitoryId);

                  // Add notification data to the notifications collection
                  await firestoreServiceUser.addBookingNotification(
                      userId, dormitoryId);

                  // Update user's notification field to track the notification
                  await firestoreServiceUser.updateUserNotifications(
                      userId, dormitoryId);
                },
                child: TextWidget.buildText(text: 'ยืนยัน'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle errors
      print('Error booking dormitory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TextWidget.buildText(text: 'เกิดข้อผิดพลาดในการจองหอพัก')),
      );
    }
  }

  // ignore: unused_element
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget.buildText(text: title),
        content: TextWidget.buildText(text: content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: TextWidget.buildText(text: 'ตกลง'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดงรายละเอียดหอพัก
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'รายอะเอียดหอพัก', context: context),
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
                    imageUrls.length == 1
                        ? Image.network(
                            imageUrls[0],
                            height: 200.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        // Section สำหรับเลื่อนรูปภาพ
                        : CarouselSlider(
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
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                TextWidget.buildText( text: 
                                  dormitory['name'] ?? 'ไม่มีชื่อ',fontSize: 24, isBold: true
                                  // style: Theme.of(context)
                                  //     .textTheme
                                  //     .headlineMedium
                                  //     ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),

                                // Available rooms
                                TextWidget.buildText( text: 
                                  'จำนวนห้องว่าง: ${dormitory['availableRooms'] ?? 'ไม่มีข้อมูล'} ห้อง',

                                ),
                                TextWidget.buildText( text: 
                                  'จำนวนห้องทั้งหมด: ${dormitory['totalRooms'] ?? 'ไม่มีข้อมูล'} ห้อง',
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Price per term
                                TextWidget.buildText( text: 
                                  'ราคา: ${formatNumber.format(dormitory['price'])} บาท/เทอม',fontSize: 24, isBold: true
                                ),
                                const SizedBox(height: 10),

                                // Dormitory type
                                TextWidget.buildText( text: 
                                  'ประเภทหอพัก: ${dormitory['dormType'] ?? 'ไม่มีข้อมูล'}',
                                ),
                                const SizedBox(height: 10),

                                // Room type
                                TextWidget.buildText( text: 
                                  'ประเภทห้อง: ${dormitory['roomType'] ?? 'ไม่มีข้อมูล'}',
                                ),
                                const SizedBox(height: 10),

                                // Number of occupants
                                TextWidget.buildText( text: 
                                  'จำนวนคนพัก: ${dormitory['occupants'] ?? 'ไม่มีข้อมูล'} คน',
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Electricity charge
                                TextWidget.buildText( text: 
                                  'ค่าไฟ: ${dormitory['electricityRate'] ?? 'ไม่มีข้อมูล'} บาท/หน่วย',
                                ),
                                const SizedBox(height: 10),

                                // Water charge
                                TextWidget.buildText( text: 
                                  'ค่าน้ำ: ${dormitory['waterRate'] ?? 'ไม่มีข้อมูล'} บาท/หน่วย',

                                ),
                                const Divider(height: 20, thickness: 2),

                                // Security deposit
                                TextWidget.buildText( text: 
                                  'ค่าประกันความเสียหาย: ${formatNumber.format(dormitory['securityDeposit'])} บาท',fontSize: 24, isBold: true
                                ),
                                const SizedBox(height: 10),

                                // Dormitory rules
                                TextWidget.buildText( text: 
                                  'กฎของหอพัก:',fontSize: 24, isBold: true

                                ),
                                TextWidget.buildText( text: 
                                  dormitory['rule'] ?? 'ไม่มีข้อมูล',
                                ),
                                const Divider(height: 20, thickness: 2),

                                // Equipment in the room
                                TextWidget.buildText( text: 
                                  'อุปกรณ์ในห้องพัก:',fontSize: 24, isBold: true

                                ),
                                const SizedBox(height: 5),
                                TextWidget.buildText( text: 
                                  dormitory['equipment'] != null &&
                                          dormitory['equipment'].isNotEmpty
                                      ? dormitory['equipment']
                                          .split('\n')
                                          .map((e) => '• $e')
                                          .join('\n')
                                      : 'ไม่มีข้อมูล',
                                ),
                                const Divider(height: 20, thickness: 2),
                                TextWidget.buildText( text: 
                                  'ช่องทางการติดต่อ:',fontSize: 24, isBold: true
                                ),
                                const SizedBox(height: 8),
                                ownerData != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget.buildText( text: 
                                            'อีเมล: ${ownerData?['email'] ?? 'ไม่พบข้อมูล'}',

                                          ),
                                          TextWidget.buildText( text: 
                                            'เบอร์โทร: ${ownerData?['numphone'] ?? 'ไม่พบข้อมูล'}',

                                          ),
                                        ],
                                      )
                                    : const CircularProgressIndicator(), // แสดงวงกลมโหลดข้อมูลในขณะที่กำลังดึงข้อมูล

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
                                    TextWidget.buildText( text: 
                                      dormitory['rating'] != null
                                          ? dormitory['rating']
                                              .toStringAsFixed(1)
                                          : '0.0',fontSize: 24, isBold: true
                                    ),
                                    TextWidget.buildText( text: 
                                      ' (${dormitory['reviewCount'] ?? 0} รีวิว)',fontSize: 24, isBold: true

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
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextWidget.buildText( text: 
                          'ข้อมูลหอพักนี้ยังไม่ครบท้วน',
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
              child: Text(
                'รีวิว',
                style: TextStyle(fontSize: 24),
              ),
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
