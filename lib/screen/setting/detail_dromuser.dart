// ignore_for_file: use_build_context_synchronously

import 'package:dorm_app/screen/user/widgets/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DormitoryDetailsScreen extends StatefulWidget {
  final String userId;

  const DormitoryDetailsScreen({super.key, required this.userId});

  @override
  State<DormitoryDetailsScreen> createState() => _DormitoryDetailsScreenState();
}

class _DormitoryDetailsScreenState extends State<DormitoryDetailsScreen> {
  final TextEditingController _currentDormController = TextEditingController();
  final TextEditingController _previousDormController = TextEditingController();

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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

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
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      List<dynamic>? userChatRoomIds = userData?['chatRoomId'];

      if (userChatRoomIds != null && userChatRoomIds.isNotEmpty) {
        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(dormitoryId)
            .get();

        if (dormitorySnapshot.exists) {
          Map<String, dynamic>? dormitoryData =
              dormitorySnapshot.data() as Map<String, dynamic>?;

          List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomId'];
          String? chatId;

          if (isGroupChat) {
            chatId = dormitoryData?[
                'chatGroupId']; // Assuming chatGroupId exists in the dormitory data
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
    DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(dormitoryId)
        .get();

    if (dormitorySnapshot.exists) {
      var dormitoryData = dormitorySnapshot.data() as Map<String, dynamic>;

      // ดึงข้อมูลภาพจาก Array
      List<dynamic> imageUrls = dormitoryData['imageUrl'] ?? [];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('รายละเอียดหอพัก: ${dormitoryData['name']}'),
            content: SizedBox(
              width: double.maxFinite, // กำหนดความกว้างให้เต็มที่
              child: Column(
                mainAxisSize: MainAxisSize.min, // ปรับให้มีขนาดตามเนื้อหา
                children: <Widget>[
                  Text('ที่อยู่: ${dormitoryData['address']}'),
                  Text(
                      'จำนวนห้องว่าง: ${dormitoryData['availableRooms']} ห้อง'),
                  Text('ประเภทหอพัก: ${dormitoryData['dormType']}'),
                  Text('ราคาห้องพัก: ${dormitoryData['price']} บาท/เดือน'),
                  Text('เงินประกัน: ${dormitoryData['securityDeposit']} บาท'),
                  Text('ค่าบำรุงรักษา: ${dormitoryData['furnitureFee']} บาท'),
                  Text('ค่าไฟ: ${dormitoryData['electricityRate']} บาท/หน่วย'),
                  Text('ค่าน้ำ: ${dormitoryData['waterRate']} บาท/หน่วย'),
                  Text('ประเภทห้อง: ${dormitoryData['roomType']}'),
                  Text('จำนวนผู้อาศัย: ${dormitoryData['occupants']} คน'),
                  Text('กฎของหอพัก: ${dormitoryData['rule']}'),
                  Text('อุปกรณ์ในห้อง: ${dormitoryData['equipment']}'),

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
                child: const Text('ปิด'),
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
        const SnackBar(content: Text('ไม่พบข้อมูลหอพัก')),
      );
    }
  }

  // ฟังก์ชันสำหรับแสดงกล่องโต้ตอบรีวิว
  void _showReviewDialog(String dormitoryId) {
    TextEditingController reviewController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เขียนรีวิว'),
          content: TextField(
            controller: reviewController,
            decoration:
                const InputDecoration(hintText: 'ป้อนรีวิวของคุณที่นี่'),
            maxLines: 3,
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
                String review = reviewController.text.trim();
                if (review.isNotEmpty) {
                  await _submitReview(dormitoryId, review);
                  Navigator.of(context).pop();
                  // อาจเพิ่มการแจ้งเตือนหรืออัปเดต UI ที่นี่
                }
              },
              child: const Text('ส่งรีวิว'),
            ),
          ],
        );
      },
    );
  }

// ฟังก์ชันสำหรับบันทึกรีวิวลง Firestore
  Future<void> _submitReview(String dormitoryId, String review) async {
    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'dormitoryId': dormitoryId,
        'review': review,
        'timestamp': FieldValue.serverTimestamp(),
        // อาจเพิ่มข้อมูลผู้ใช้ที่ส่งรีวิว เช่น userId, username เป็นต้น
      });
      print('รีวิวถูกบันทึกเรียบร้อยแล้ว');
    } catch (e) {
      print('เกิดข้อผิดพลาดในการบันทึกรีวิว: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดหอพักของคุณ'),
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // แสดง Loading เมื่อยังโหลดอยู่
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'หอพักปัจจุบัน',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                      title: Text(
                                          'ชื่อหอพัก: ${_currentDormController.text}'),
                                      subtitle:
                                          const Text('ข้อมูลหอพักปัจจุบัน'),
                                    ),
                                    const SizedBox(
                                        height:
                                            8), // เพิ่มช่องว่างระหว่าง ListTile และปุ่ม

                                    // ปุ่มสำหรับเข้าสู่การสนทนา
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            String ownerId =
                                                "owner_id_here"; // เปลี่ยนเป็น ownerId ที่แท้จริง
                                            _navigateToChat(
                                                currentDormitoryId!, ownerId,
                                                isGroupChat: false);
                                          },
                                          child: const Text(
                                              'เข้าสู่การสนทนาเจ้าของหอพัก'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _navigateToChat(
                                                currentDormitoryId!, "",
                                                isGroupChat:
                                                    true); // ปรับให้ไม่มี ownerId สำหรับแชทกลุ่ม
                                          },
                                          child: const Text('เข้าสู่แชทกลุ่ม'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height:
                                            8), // เพิ่มช่องว่างระหว่างปุ่มและรีวิว

                                    // ปุ่มรีวิว
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _showReviewDialog(
                                              currentDormitoryId!);
                                        },
                                        child: const Text('รีวิวหอพัก'),
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
                                      // ฟังก์ชันสำหรับดูรายละเอียดหอพัก
                                      _showDormitoryDetails(
                                          currentDormitoryId!);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Text(
                          'ตอนนี้คุณไม่มีหอพัก',
                          style: TextStyle(
                              fontSize: 16, color: Colors.red), // ข้อความเตือน
                        ),
                ],
              ),
            ),
    );
  }
}
