import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  // ignore: prefer_final_fields
  FocusNode _focusNode = FocusNode();
  // ignore: prefer_final_fields
  ScrollController _scrollController = ScrollController();
  String? _editingMessageId;
  String? _deletedMessageText;
  String? _deletedMessageSenderId;
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  bool _isAtBottom = true;
  // ignore: prefer_final_fields, unused_field
  bool _isFirstTimeOpeningChat = true;
  DocumentSnapshot?
      _deletedMessageSnapshot; 

  String?
      currentUserId;
  // ignore: unused_field
  bool _showNewMessagesButton = false; 

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    _getCurrentUser();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isBottom = _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent;
        setState(() {
          _isAtBottom = isBottom;
          _showNewMessagesButton = !isBottom; // Hide button when at the bottom
        });
      } else {
        setState(() {
          _isAtBottom = false;
          _showNewMessagesButton = true; // Show button when user scrolls up
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
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

  /// Function to send a message (text or images)
  void _sendMessage({String? text, List<String>? imageUrls}) async {
    if ((text != null && text.isNotEmpty) ||
        (imageUrls != null && imageUrls.isNotEmpty)) {
      try {
        if (_editingMessageId != null) {
          // Update the existing message
          await _messagesCollection.doc(_editingMessageId).update({
            'text': _messageController.text,
            'createdAt': Timestamp.now(),
            'imageUrls': imageUrls ?? [],
          });
          setState(() {
            _editingMessageId = null; // Clear the editing state
          });
        } else {
          // Add a new message
          await _messagesCollection.add({
            'text': _messageController.text,
            'createdAt': Timestamp.now(),
            'senderId': currentUserId,
            'imageUrls': imageUrls ?? [],
          });
        }
        _scrollToBottom();
        _messageController.clear();
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
          ),
        );
      }
    }
  }

  /// Function to delete a message
  void _deleteMessage(DocumentSnapshot messageSnapshot) async {
    setState(() {
      _deletedMessageSnapshot = messageSnapshot;
      _deletedMessageText = messageSnapshot['text'];
      _deletedMessageSenderId = messageSnapshot['senderId'];
    });
    // Delete the message
    await _messagesCollection.doc(messageSnapshot.id).delete();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _undoDeleteMessage,
        ),
      ),
    );
  }

  void _undoDeleteMessage() async {
    if (_deletedMessageSnapshot != null) {
      await _messagesCollection.add({
        'text': _deletedMessageText ?? '',
        'createdAt': Timestamp.now(),
        'senderId': _deletedMessageSenderId,
        'imageUrls': _deletedMessageSnapshot!['imageUrls'] ?? '',
      });
      _deletedMessageSnapshot = null;
      _deletedMessageText = null;
      _deletedMessageSenderId = null;
    }
  }

  void _editMessage(DocumentSnapshot messageSnapshot) {
    setState(() {
      _editingMessageId = messageSnapshot.id;
      _messageController.text = messageSnapshot['text'] ?? '';
    });
  }

  /// Function to pick and send multiple images
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages =
        await picker.pickMultiImage();

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

  /// Function to upload image to Firebase Storage and get the URL
  Future<String> _uploadImageToFirebase(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageRef.putFile(imageFile);
    return await imageRef.getDownloadURL();
  }

  Future<String> _getUsername(String senderId) async {
    if (senderId.isEmpty) {
      return 'Unknown User';
    }
    try {
      final userDoc = await _usersCollection.doc(senderId).get();
      return userDoc['username'] ?? 'Unknown User';
    } catch (e) {
      print('Error getting username: $e');
      return 'Unknown User';
    }
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Image.network(imageUrl, fit: BoxFit.cover),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {}, // Add functionality if needed
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messagesCollection.orderBy('createdAt').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;

                if (_isAtBottom) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {});

                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final messageSnapshot = messages[index];
                    final bool isMe = message['senderId'] == currentUserId;

                    return FutureBuilder<String>(
                      future: _getUsername(message['senderId'] ?? ''),
                      builder: (context, usernameSnapshot) {
                        if (!usernameSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final username =
                            usernameSnapshot.data ?? 'Unknown User';

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: () =>
                                _showMessageOptions(context, messageSnapshot),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 14.0),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12.0),
                                  topRight: const Radius.circular(12.0),
                                  bottomLeft: isMe
                                      ? const Radius.circular(12.0)
                                      : Radius.zero,
                                  bottomRight: isMe
                                      ? Radius.zero
                                      : const Radius.circular(12.0),
                                ),
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
                                      children: (message['imageUrls']
                                              as List<dynamic>)
                                          .map((url) {
                                        return GestureDetector(
                                          onTap: () =>
                                              _showFullScreenImage(url),
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
                                        color: Colors.black87,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  const SizedBox(height: 5),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  Text(
                                    _formatTimestamp(message[
                                        'createdAt']), // แสดงเวลาส่งข้อความ
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
                  onPressed: _pickImages, // ฟังก์ชันสำหรับเลือกรูปภาพ
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: _editingMessageId == null
                          ? 'Send a message...'
                          : 'Edit your message...',
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
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(text: _messageController.text);
                      _messageController.clear();
                      _scrollToBottom(); // เลื่อนลงแชทล่าสุดเมื่อส่งข้อความ
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Function to show options to edit or delete a message
  void _showMessageOptions(
      BuildContext context, DocumentSnapshot messageSnapshot) {
    final message = messageSnapshot.data() as Map<String, dynamic>;
    final bool isMe = message['senderId'] == currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(messageSnapshot);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(messageSnapshot);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
