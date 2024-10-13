// ignore_for_file: prefer_final_fields, use_build_context_synchronously, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class UserAllChatScreen extends StatefulWidget {
  final String ownerId;
  final String userId;
  final String chatGroupId;

  const UserAllChatScreen({
    required this.ownerId,
    required this.userId,
    required this.chatGroupId, 
    super.key, String? chatRoomId, required String dormitoryId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UserAllChatScreenState createState() => _UserAllChatScreenState();
}

class _UserAllChatScreenState extends State<UserAllChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
        _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid;
    });

    // เช็คว่า currentUserId มีสิทธิ์เข้าถึง chatGroupId หรือไม่
    await _checkChatAccess();
  }

  Future<void> _checkChatAccess() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        // เช็คว่า chatGroupId ของผู้ใช้ตรงกับ chatGroupId ที่ส่งมา
        if (userDoc['chatGroupIds'] != null && 
            (userDoc['chatGroupIds'] as List).contains(widget.chatGroupId)) {
          // ผู้ใช้มีสิทธิ์เข้าถึงแชทนี้
          print('Access granted to chat group.');
        } else {
          // ผู้ใช้ไม่มีสิทธิ์เข้าถึงแชทนี้
          print('Access denied to chat group.');
          Navigator.of(context).pop(); // หรือไปที่หน้าที่เหมาะสม
        }
      }
    } catch (e) {
      print('Error checking chat access: $e');
    }
  }

void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage({String? text, List<String>? imageUrls}) async {
    if ((text != null && text.isNotEmpty) ||
        (imageUrls != null && imageUrls.isNotEmpty)) {
      try {
        await _messagesCollection
            .doc(widget.chatGroupId)
            .collection('messages')
            .add({
          'text': text ?? '',
          'createdAt': Timestamp.now(),
          'senderId': currentUserId,
          'imageUrls': imageUrls ?? [],
          'chatGroupId': widget.chatGroupId,
        });

        _scrollToBottom();
        _messageController.clear();
      } catch (e) {
        // เพิ่มการล็อกข้อผิดพลาด
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (pickedImages != null && pickedImages.isNotEmpty) {
      List<String> imageUrls = [];
      for (var pickedImage in pickedImages) {
        File imageFile = File(pickedImage.path);
        String imageUrl = await _uploadImageToFirebase(imageFile);
        imageUrls.add(imageUrl);
      }
      _sendMessage(imageUrls: imageUrls);
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageRef.putFile(imageFile);
    return await imageRef.getDownloadURL();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แชทกับผู้ใช้ที่จองหอพัก'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection
                  .doc(widget.chatGroupId)
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final bool isMe = message['senderId'] == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message['imageUrls'] != null && (message['imageUrls'] as List<dynamic>).isNotEmpty)
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: (message['imageUrls'] as List<dynamic>).map((url) {
                                  return GestureDetector(
                                    onTap: () => _showFullScreenImage(url),
                                    child: Image.network(
                                      url,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }).toList(),
                              ),
                            if (message['text'] != null && message['text'].isNotEmpty)
                              Text(
                                message['text'],
                                style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                              ),
                            const SizedBox(height: 5),
                            FutureBuilder<String>(
                              future: _getUsername(message['senderId']),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'Unknown User',
                                  style: const TextStyle(color: Colors.black45, fontSize: 12.0),
                                );
                              },
                            ),
                            Text(
                              _formatTimestamp(message['createdAt']),
                              style: const TextStyle(color: Colors.black45, fontSize: 10.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.purple),
                  onPressed: _pickImages,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: 'ส่งข้อความ...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _sendMessage(text: _messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getUsername(String senderId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();

      return userDoc.exists
          ? userDoc['username'] ?? 'Unknown User'
          : 'Unknown User';
    } catch (e) {
      print('Error getting username: $e');
      return 'Unknown User'; // Default value if user does not exist
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
