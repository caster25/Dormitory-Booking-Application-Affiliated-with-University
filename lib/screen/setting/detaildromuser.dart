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

  Future<void> _saveDormitoryDetails() async {
    String currentDorm = _currentDormController.text;
    String previousDorm = _previousDormController.text;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'currentDormitoryId': currentDorm, // บันทึก currentDormitoryId ใหม่
        'previousDormitory': previousDorm, // บันทึก previousDormitory
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
      );
    } catch (e) {
      print('Error saving dormitory details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
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
                  const Text(
                    'หอพักที่เคยพัก',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  previousDormitoryName != null // ถ้ามีข้อมูลหอพักที่เคยพัก
                      ? Card(
                          child: ListTile(
                            title: Text(
                                'ชื่อหอพัก: ${_previousDormController.text}'),
                            subtitle: const Text('ข้อมูลหอพักที่เคยพัก'),
                          ),
                        )
                      : TextField(
                          controller: _previousDormController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ชื่อหอพักที่เคยพัก',
                          ),
                        ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveDormitoryDetails,
                    child: const Text('บันทึก'),
                  ),
                ],
              ),
            ),
    );
  }
}
