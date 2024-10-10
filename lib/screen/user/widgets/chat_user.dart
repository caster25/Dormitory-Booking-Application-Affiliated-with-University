import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String ownerId;
  final String chatRoomId;

  const ChatScreen(
      {required this.userId,
      required this.ownerId,
      super.key,
      required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  // ignore: unused_field
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  // ignore: unused_field
  String? _editingMessageId;
  // ignore: unused_field
  String? _deletedMessageText;
  // ignore: unused_field
  String? _deletedMessageSenderId;
  String? currentUserId;
  // ignore: unused_field
  bool _isAtBottom = true;
  // ignore: unused_field
  DocumentSnapshot? _deletedMessageSnapshot;

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

    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.atEdge) {
      bool isBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      setState(() {
        _isAtBottom = isBottom;
      });
    }
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
        // ส่งข้อความไปยังห้องแชทที่กำหนด
        await _messagesCollection
            .doc(widget.chatRoomId) // ใช้ chatRoomId จาก widget
            .collection('messages')
            .add({
          'text': text ?? '',
          'createdAt': Timestamp.now(),
          'senderId': currentUserId,
          'imageUrls': imageUrls ?? [],
          'chatRoomId': widget.chatRoomId, // เก็บ chatRoomId
        });

        _scrollToBottom();
        _messageController.clear();
      } catch (e) {
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
        title: const Text('แชทกับเจ้าของหอพัก'),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesCollection
                    .doc(widget.chatRoomId) // Accessing chatRoomId from widget
                    .collection('messages')
                    .orderBy('createdAt')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  print('Chat Room ID: ${widget.chatRoomId}');

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
                    icon: const Icon(Icons.send, color: Colors.blue),
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

  Future<String> _getUsername(String senderId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();

    if (userDoc.exists) {
      return userDoc['username'] ??
          'Unknown User'; // Ensure a non-null return value
    }
    return 'Unknown User'; // Default value if user does not exist
  }

  void _showMessageOptions(BuildContext context, DocumentSnapshot message) {
    final currentUserUid =
        FirebaseAuth.instance.currentUser?.uid; // รับ uid ของผู้ใช้ปัจจุบัน

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ตัวเลือกสำหรับแก้ไขข้อความ หากผู้ใช้เป็นผู้ส่งข้อความ
            if (currentUserUid == message['senderId'])
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _startEditingMessage(message);
                },
              ),
            // ตัวเลือกสำหรับลบข้อความ หากผู้ใช้เป็นผู้ส่งข้อความ
            if (currentUserUid == message['senderId'])
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to delete this message?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // ปิด dialog
                            },
                          ),
                          TextButton(
                            child: const Text('Delete'),
                            onPressed: () {
                              Navigator.of(context).pop(); // ปิด dialog
                              _deleteMessage(message); // ดำเนินการลบข้อความ
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            // ตัวเลือกสำหรับดูรายละเอียดข้อความ
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _viewMessageDetails(message); // เรียกดูรายละเอียดของข้อความ
              },
            ),
          ],
        );
      },
    );
  }

  void _viewMessageDetails(DocumentSnapshot message) {
    // สร้าง UI หรือหน้าต่างใหม่เพื่อแสดงรายละเอียดของข้อความ
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sender: ${message['senderName']}'), // แสดงชื่อผู้ส่ง
              Text('Message: ${message['content']}'), // แสดงเนื้อความ
              // เพิ่มรายละเอียดอื่น ๆ ที่คุณต้องการแสดง
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _startEditingMessage(DocumentSnapshot message) {
    setState(() {
      _editingMessageId = message.id;
      _messageController.text = message['text'];
    });
  }

  void _deleteMessage(DocumentSnapshot message) async {
    // Delete image from Firebase Storage if it exists
    if (message['imageUrls'] != null) {
      for (String url in message['imageUrls']) {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      }
    }
    // Then delete the message from Firestore
    _messagesCollection.doc(message.id).delete();
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
