// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/data/src/service.dart';
import 'package:dorm_app/features/screen/user/data/src/service_dorm.dart';
import 'package:dorm_app/features/screen/user/widgets/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DormitoryDetailsScreen extends StatefulWidget {
  final String userId;

  const DormitoryDetailsScreen({super.key, required this.userId});

  @override
  State<DormitoryDetailsScreen> createState() => _DormitoryDetailsScreenState();
}

class _DormitoryDetailsScreenState extends State<DormitoryDetailsScreen> {
  final TextEditingController _currentDormController = TextEditingController();
  final TextEditingController _previousDormController = TextEditingController();
  final FirebaseServiceDorm firestoreServiceDorm = FirebaseServiceDorm();
  final FirestoreServiceUser firestoreServiceUser = FirestoreServiceUser();

  bool isLoading = true; // แสดงสถานะการโหลด
  String? currentDormitoryId; // เก็บ currentDormitoryId ถ้ามี
  String? previousDormitoryName; // ชื่อหอพักที่เคยพัก

  @override
  void initState() {
    super.initState();
    _fetchDormitoryDetails(); // ดึงข้อมูลหอพักของผู้ใช้
  }

  Future<void> _fetchDormitoryDetails() async {
    try {
      DocumentSnapshot userDoc =
          await firestoreServiceUser.getUserData(widget.userId);

      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          currentDormitoryId = userData['currentDormitoryId'];
          previousDormitoryName = userData['previousDormitory'];

          if (currentDormitoryId != null) {
            DocumentSnapshot dormitoryDoc = await FirebaseFirestore.instance
                .collection('dormitories')
                .doc(currentDormitoryId)
                .get();

            if (dormitoryDoc.exists) {
              Map<String, dynamic>? dormitoryData =
                  dormitoryDoc.data() as Map<String, dynamic>?;

              if (dormitoryData != null) {
                _currentDormController.text =
                    dormitoryData['name'] ?? 'ไม่พบชื่อหอพัก';
              }
            }
          }

          if (previousDormitoryName != null) {
            _previousDormController.text = previousDormitoryName!;
          }
        }
      }
    } catch (e) {
      print('Error fetching dormitory details: $e');
    } finally {
      setState(() {
        isLoading = false; // เมื่อโหลดเสร็จแล้ว เปลี่ยนสถานะเป็นไม่โหลด
      });
    }
  }

  void _navigateToChat(String dormitoryId, String ownerId,
    {bool isGroupChat = false}) async {
  // Get user data from Firestore
  DocumentSnapshot userSnapshot =
      await firestoreServiceUser.getUserData(widget.userId);

  if (userSnapshot.exists) {
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    List<dynamic>? userChatRoomIds = userData?['chatRoomId'];

    if (userChatRoomIds != null && userChatRoomIds.isNotEmpty) {
      DocumentSnapshot dormitorySnapshot =
          await firestoreServiceDorm.getOwnerDataOnce(dormitoryId);

      if (dormitorySnapshot.exists) {
        Map<String, dynamic>? dormitoryData =
            dormitorySnapshot.data() as Map<String, dynamic>?;

        List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomId'];
        String? chatId;

        if (isGroupChat) {
          chatId = dormitoryData?['chatGroupId']; // Assuming chatGroupId exists
        } else {
          // Find the matching chatRoomId
          for (var chatRoomId in userChatRoomIds) {
            if (dormitoryChatRoomIds?.contains(chatRoomId) == true) {
              chatId = chatRoomId;
              break;
            }
          }
        }

        if (chatId != null) {
          // Navigate to the chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: widget.userId,
                ownerId: ownerId,
                chatRoomId: chatId!,
                dormitoryId: dormitoryId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ยังไม่มีการสนทนาในห้องนี้')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบข้อมูลหอพัก')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยังไม่มีการสนทนาในห้องนี้')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
    );
  }
}


  void _showDormitoryDetails(String dormitoryId) async {
    // ดึงข้อมูลหอพักจาก Firebase
    DocumentSnapshot dormitorySnapshot =
        await firestoreServiceDorm.getOwnerDataOnce(dormitoryId);

    if (dormitorySnapshot.exists) {
      var dormitoryData = dormitorySnapshot.data() as Map<String, dynamic>;

      // ดึงข้อมูลภาพจาก Array
      List<dynamic> imageUrls = dormitoryData['imageUrl'] ?? [];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: TextWidget.buildHeader24('รายละเอียดหอพัก: ${dormitoryData['name']}'),
            content: SizedBox(
              width: double.maxFinite, // กำหนดความกว้างให้เต็มที่
              child: Column(
                mainAxisSize: MainAxisSize.min, // ปรับให้มีขนาดตามเนื้อหา
                children: <Widget>[
                  TextWidget.buildSubSection16('ที่อยู่: ${dormitoryData['address']}'),
                  TextWidget.buildSubSection16(
                      'จำนวนห้องว่าง: ${dormitoryData['availableRooms']} ห้อง'),
                  TextWidget.buildSubSection16('จำนวนห้องทั้งหมด: ${dormitoryData['totalRooms']} ห้อง'),
                  TextWidget.buildSubSection16('ประเภทหอพัก: ${dormitoryData['dormType']}'),
                  TextWidget.buildSubSection16('ราคาห้องพัก: ${dormitoryData['price']} บาท/เทอม'),
                  TextWidget.buildSubSection16('เงินประกัน: ${dormitoryData['securityDeposit']} บาท'),
                  TextWidget.buildSubSection16('ค่าบำรุงรักษา: ${dormitoryData['furnitureFee']} บาท'),
                  TextWidget.buildSubSection16('ค่าไฟ: ${dormitoryData['electricityRate']} บาท/หน่วย'),
                  TextWidget.buildSubSection16('ค่าน้ำ: ${dormitoryData['waterRate']} บาท/หน่วย'),
                  TextWidget.buildSubSection16('ประเภทห้อง: ${dormitoryData['roomType']}'),
                  TextWidget.buildSubSection16('จำนวนผู้อาศัย: ${dormitoryData['occupants']} คน'),
                  TextWidget.buildSubSection16('กฎของหอพัก: ${dormitoryData['rule']}'),
                  TextWidget.buildSubSection16('อุปกรณ์ในห้อง: ${dormitoryData['equipment']}'),

                  // ใช้ PageView เพื่อแสดงภาพทั้งหมด
                  // ignore: sized_box_for_whitespace
                  Container(
                    height: 200, // กำหนดความสูงของภาพ
                    child: PageView.builder(
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: TextWidget.buildSubSection16('ปิด'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TextWidget.buildSubSection16('ไม่พบข้อมูลหอพัก')),
      );
    }
  }

// ในฟังก์ชัน _showReviewDialog
  void _showReviewDialog(String dormitoryId) {
    TextEditingController reviewController = TextEditingController();
    double rating = 0;

    // ดึง userId จาก Firebase Authentication
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ไม่สามารถดึง userId ได้ ผู้ใช้ยังไม่ได้ล็อกอิน');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เขียนรีวิว'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewController,
                decoration:
                    const InputDecoration(hintText: 'ป้อนรีวิวของคุณที่นี่'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                String reviewText = reviewController.text.trim();
                if (reviewText.isNotEmpty && rating > 0) {
                  await _submitReview(dormitoryId, reviewText, rating, userId);
                  Navigator.of(context).pop();
                } else {
                  // แจ้งเตือนผู้ใช้กรณีที่ยังไม่ได้กรอกข้อมูลหรือคะแนนไม่ถูกต้อง
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: TextWidget.buildSubSection16('กรุณากรอกข้อความรีวิวและเลือกคะแนน')),
                  );
                }
              },
              child: const Text('ส่งรีวิว'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReview(String dormitoryId, String reviewText,
      double rating, String userId) async {
    try {
      // ตรวจสอบว่ามีการบันทึกรีวิวสำเร็จหรือไม่
      await FirebaseFirestore.instance.collection('reviews').doc(userId).set({
        'dormitoryId': dormitoryId,
        'reviewText': reviewText,
        'rating': rating,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // อัปเดตคะแนนรีวิวของหอพัก
      await updateDormitoryRating(dormitoryId);
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกรีวิว')),
      );
    }
  }

  Future<void> updateDormitoryRating(String dormitoryId) async {
    // Get all reviews for the dormitory
    final QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('dormitoryId', isEqualTo: dormitoryId)
        .get();

    // Calculate new rating and review count
    int reviewCount = reviewsSnapshot.docs.length;
    double totalRating = 0;

    for (var review in reviewsSnapshot.docs) {
      totalRating += review['rating'];
    }

    double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0;

    // Update dormitory document
    await firestoreServiceDorm.updateDormitory(dormitoryId, {
      'reviewCount': reviewCount,
      'rating': averageRating,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'รายละเอียดหอพักของคุณ', context: context),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // แสดง Loading เมื่อยังโหลดอยู่
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.buildHeader24(
                    'หอพักปัจจุบัน',
                    
                  ),
                  const SizedBox(height: 8),
                  currentDormitoryId != null &&
                          _currentDormController
                              .text.isNotEmpty // เช็คว่ามีข้อมูลหอพักปัจจุบัน
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(
                                16.0), // เพิ่ม Padding ให้กับ Card
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: TextWidget.buildSubSection16(
                                          'ชื่อหอพัก: ${_currentDormController.text} '),
                                      subtitle:
                                          TextWidget.buildSubSection14('ข้อมูลหอพักปัจจุบัน'),
                                    ),
                                    const SizedBox(
                                        height:
                                            8), // เพิ่มช่องว่างระหว่าง ListTile และปุ่ม

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .stretch, // ให้ปุ่มขยายเต็มความกว้าง
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            String ownerId = currentDormitoryId!;
                                            _navigateToChat(
                                                currentDormitoryId!, ownerId,
                                                isGroupChat: false);
                                          },
                                          child: TextWidget.buildSubSection14(
                                              'เข้าสู่การสนทนาเจ้าของหอพัก'),
                                        ),
                                        const SizedBox(
                                            height:
                                                8), // เพิ่มระยะห่างระหว่างปุ่ม
                                        ElevatedButton(
                                          onPressed: () {
                                            _navigateToChat(
                                                currentDormitoryId!, "",
                                                isGroupChat: true);
                                          },
                                          child: TextWidget.buildSubSection14('เข้าสู่แชทกลุ่ม'),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height:
                                            8), // เพิ่มช่องว่างระหว่างปุ่มแชทกับปุ่มรีวิว
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _showReviewDialog(
                                              currentDormitoryId!);
                                        },
                                        child: TextWidget.buildSubSection14('รีวิวหอพัก'),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons
                                        .info_outline), // ไอคอนสำหรับดูรายละเอียด
                                    onPressed: () {
                                      _showDormitoryDetails(
                                          currentDormitoryId!);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : TextWidget.buildSubSectionRed16(
                          'ตอนนี้คุณไม่มีหอพัก',
                        ),
                ],
              ),
            ),
    );
  }
}
