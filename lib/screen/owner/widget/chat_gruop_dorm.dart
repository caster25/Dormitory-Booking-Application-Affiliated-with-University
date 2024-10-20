// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class OwnerAllChatScreen extends StatefulWidget {
  final String ownerId;
  final String userId;
  final String chatGroupId;

  // ignore: use_super_parameters
  const OwnerAllChatScreen({
    required this.ownerId,
    required this.userId,
    required this.chatGroupId,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OwnerAllChatScreenState createState() => _OwnerAllChatScreenState();
}

class _OwnerAllChatScreenState extends State<OwnerAllChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  // ignore: prefer_final_fields
  FocusNode _focusNode = FocusNode();
  // ignore: prefer_final_fields
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
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        title: const Text('กลุ่มหอพัก'), // แสดงชื่อหอพัก
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesCollection
                    .doc(widget.chatGroupId)
                    .collection('messages')
                    .orderBy('createdAt')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      final bool isMe = message['senderId'] == currentUserId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: () =>
                              _showMessageOptions(context, messages[index]),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 14.0),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message['imageUrls'] != null &&
                                    (message['imageUrls'] as List<dynamic>)
                                        .isNotEmpty)
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children:
                                        (message['imageUrls'] as List<dynamic>)
                                            .map((url) {
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
                                if (message['text'] != null &&
                                    message['text'].isNotEmpty)
                                  Text(
                                    message['text'],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 16.0),
                                  ),
                                const SizedBox(height: 5),
                                FutureBuilder<String>(
                                  future: _getUsername(message['senderId']),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Unknown User',
                                      style: const TextStyle(
                                          color: Colors.black45,
                                          fontSize: 12.0),
                                    );
                                  },
                                ),
                                Text(
                                  _formatTimestamp(message['createdAt']),
                                  style: const TextStyle(
                                      color: Colors.black45, fontSize: 10.0),
                                ),
                              ],
                            ),
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
                        labelText: 'Send a message...',
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
                    icon: const Icon(Icons.send, color: Colors.purple),
                    onPressed: () =>
                        _sendMessage(text: _messageController.text),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<String> _getUsername(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['username'] ?? 'Unknown';
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Image.network(imageUrl),
        );
      },
    );
  }

  void _showMessageOptions(
      BuildContext context, QueryDocumentSnapshot message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: const Text('Delete Message'),
              onTap: () {
                _deleteMessage(message.id);
                Navigator.pop(context); // ปิด Bottom Sheet
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _messagesCollection
          .doc(widget.chatGroupId)
          .collection('messages')
          .doc(messageId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete message: $e')),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
