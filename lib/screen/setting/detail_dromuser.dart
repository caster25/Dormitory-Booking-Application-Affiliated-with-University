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
          // ตรวจสอบว่ามี currentDormitoryId หรือไม่
          currentDormitoryId = userData['currentDormitoryId'];
          previousDormitoryName = userData['previousDormitory'];

          // ถ้ามี currentDormitoryId ให้ดึงชื่อหอพัก
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

          // ตั้งค่าชื่อหอพักที่เคยพัก
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

  void _navigateToChat(String dormitoryId, String ownerId) async {
    // Get user data from Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userSnapshot.exists) {
      // Cast the data to a Map<String, dynamic>
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Get the chatRoomIds list from userData
      List<dynamic>? userChatRoomIds = userData?['chatRoomIds'];

      if (userChatRoomIds != null && userChatRoomIds.isNotEmpty) {
        // Get dormitory data to check its chatRoomIds
        DocumentSnapshot dormitorySnapshot = await FirebaseFirestore.instance
            .collection('dormitories')
            .doc(dormitoryId)
            .get();

        if (dormitorySnapshot.exists) {
          // Cast the data to a Map<String, dynamic>
          Map<String, dynamic>? dormitoryData =
              dormitorySnapshot.data() as Map<String, dynamic>?;

          // Get the chatRoomIds from dormitory data
          List<dynamic>? dormitoryChatRoomIds = dormitoryData?['chatRoomIds'];

          if (dormitoryChatRoomIds != null && dormitoryChatRoomIds.isNotEmpty) {
            // Find the matching chatRoomId that belongs to the current dormitory owner
            String? matchingChatRoomId;
            for (var chatRoomId in userChatRoomIds) {
              if (dormitoryChatRoomIds.contains(chatRoomId)) {
                matchingChatRoomId = chatRoomId;
                break;
              }
            }

            if (matchingChatRoomId != null) {
              // Navigate to the chat screen with the existing chatRoomId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userId: widget.userId,
                    ownerId: ownerId,
                    chatRoomId:
                        matchingChatRoomId!, // Pass the found chatRoomId
                  ),
                ),
              );
            } else {
              // If no matching chatRoomId found, show a message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ยังไม่มีการสนทนาในห้องนี้')),
              );
            }
          } else {
            // If dormitory chatRoomIds is empty, show a message
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
        // If user chatRoomIds is empty, show a message
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
                  currentDormitoryId != null // ถ้ามีข้อมูลหอพักปัจจุบัน
                      ? Card(
                          child: ListTile(
                            title: Text(
                                'ชื่อหอพัก: ${_currentDormController.text}'),
                            subtitle: const Text('ข้อมูลหอพักปัจจุบัน'),
                          ),
                        )
                      : TextField(
                          controller: _currentDormController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ชื่อหอพักปัจจุบัน',
                          ),
                        ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (currentDormitoryId != null) {
                        // Assuming you have a way to get the ownerId from the current dormitory data
                        String ownerId =
                            "owner_id_here"; // Replace with the actual ownerId
                        _navigateToChat(currentDormitoryId!, ownerId);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ไม่มีหอพักปัจจุบัน')),
                        );
                      }
                    },
                    child: const Text('เข้าสู่การสนทนา'),
                  ),
                ],
              ),
            ),
    );
  }
}
