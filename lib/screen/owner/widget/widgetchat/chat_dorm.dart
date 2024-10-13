import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSelectionScreen extends StatefulWidget {
  final String chatGroupId;

  // ignore: use_key_in_widget_constructors
  const ChatSelectionScreen({required this.chatGroupId});

  @override
  // ignore: library_private_types_in_public_api
  _ChatSelectionScreenState createState() => _ChatSelectionScreenState();
}

class _ChatSelectionScreenState extends State<ChatSelectionScreen> {
  bool isChatRoomSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดแชท'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              // ignore: sort_child_properties_last
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Chat Rooms'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Chat Groups'),
                ),
              ],
              isSelected: [isChatRoomSelected, !isChatRoomSelected],
              onPressed: (int index) {
                setState(() {
                  isChatRoomSelected = index == 0;
                });
              },
            ),
          ),
          // แสดงข้อมูลตามการเลือก
          Expanded(
            child: isChatRoomSelected ? _buildChatRooms() : _buildChatGroups(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRooms() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('chatGroups')
          .doc(widget.chatGroupId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('ไม่มีข้อมูลห้องแชท'));
        }

        // ดึงข้อมูลจาก snapshot
        var data = snapshot.data!.data() as Map<String, dynamic>;
        var chatRoomIds = List<String>.from(data['chatRoomId'] ?? []);

        // ตรวจสอบว่ามี chatRoomIds หรือไม่
        if (chatRoomIds.isEmpty) {
          return const Center(child: Text('ไม่มีห้องแชทในกลุ่มนี้'));
        }

        return ListView.builder(
          itemCount: chatRoomIds.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('ห้องแชท: ${chatRoomIds[index]}'),
              onTap: () {
                // นำทางไปยังห้องแชทที่เลือก
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatRoomScreen(chatRoomId: chatRoomIds[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatGroups() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('chatGroups')
          .doc(widget.chatGroupId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('ไม่มีข้อมูลกลุ่มแชท'));
        }

        // ดึงข้อมูลจาก snapshot
        var data = snapshot.data!.data() as Map<String, dynamic>;
        var groupDetails = data['groupDetails'] ?? [];

        // ตรวจสอบว่ามี groupDetails หรือไม่
        if (groupDetails.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลกลุ่มแชทในกลุ่มนี้'));
        }

        return ListView.builder(
          itemCount: groupDetails.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('กลุ่มแชท: ${groupDetails[index]}'),
              onTap: () {
                // นำทางไปยังกลุ่มแชทที่เลือก
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatGroupScreen(groupId: groupDetails[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ChatRoomScreen extends StatelessWidget {
  final String chatRoomId;

  // ignore: use_key_in_widget_constructors
  const ChatRoomScreen({required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ห้องแชท: $chatRoomId'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDormitories(), // เรียกใช้ฟังก์ชันเพื่อดึงข้อมูลห้องพัก
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีห้องพัก'));
          } else {
            final dormitories = snapshot.data!;
            return ListView.builder(
              itemCount: dormitories.length,
              itemBuilder: (context, index) {
                final dormitory = dormitories[index];
                return ListTile(
                  title: Text(dormitory['name'] ?? 'ไม่มีชื่อห้องพัก'),
                  onTap: () {
                    // ทำการนำทางไปยังหน้าจอแสดงรายละเอียดห้องพัก (สามารถปรับได้)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DormitoryDetailScreen(dormitoryId: dormitory['id']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDormitories() async {
    final dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .get();

    final List<Map<String, dynamic>> dormitoriesList = [];
    for (var doc in dormitorySnapshot.docs) {
      dormitoriesList.add({
        'id': doc.id,
        'name': doc['name'], // สมมุติว่ามีฟิลด์ชื่อว่า 'name'
      });
    }
    return dormitoriesList;
  }
}

// สมมุติว่ามีหน้าจอสำหรับแสดงรายละเอียดห้องพัก
class DormitoryDetailScreen extends StatelessWidget {
  final String dormitoryId;

  DormitoryDetailScreen({required this.dormitoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดห้องพัก: $dormitoryId'),
      ),
      body: const Center(
        child: Text('แสดงรายละเอียดห้องพักที่นี่'),
      ),
    );
  }
}

class ChatGroupScreen extends StatelessWidget {
  final String groupId;

  ChatGroupScreen({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('กลุ่มแชท: $groupId'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDormitories(), // เรียกใช้ฟังก์ชันเพื่อดึงข้อมูลหอพัก
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีหอพัก'));
          } else {
            final dormitories = snapshot.data!;
            return ListView.builder(
              itemCount: dormitories.length,
              itemBuilder: (context, index) {
                final dormitory = dormitories[index];
                return ListTile(
                  title: Text(dormitory['name'] ?? 'ไม่มีชื่อหอพัก'),
                  onTap: () {
                    // ทำการนำทางไปยังหน้าจอแสดงรายละเอียดหอพัก (สามารถปรับได้)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DormitoryDetailScreen(dormitoryId: dormitory['id']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDormitories() async {
    final user = FirebaseAuth.instance.currentUser; // ดึงข้อมูลผู้ใช้ปัจจุบัน
    if (user == null) {
      return []; 
    }

    final dormitorySnapshot = await FirebaseFirestore.instance
        .collection('dormitories')
        .where('submittedBy', isEqualTo: user.uid) // ตรวจสอบว่า submittedBy เป็นของผู้ใช้ปัจจุบัน
        .get();

    final List<Map<String, dynamic>> dormitoriesList = [];
    for (var doc in dormitorySnapshot.docs) {
      dormitoriesList.add({
        'id': doc.id,
        'name': doc['name'], // สมมุติว่ามีฟิลด์ชื่อว่า 'name'
      });
    }
    return dormitoriesList;
  }
}


