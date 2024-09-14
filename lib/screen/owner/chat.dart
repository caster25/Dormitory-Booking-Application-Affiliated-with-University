import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection = FirebaseFirestore.instance.collection('messages');
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  String? _editingMessageId;
  String? _deletedMessageText;
  String? _deletedMessageSenderId;
  DocumentSnapshot? _deletedMessageSnapshot;

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get the current user's ID
  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid; // Get user ID
    });
  }

  void _sendMessage({String? imageUrl}) async {
    if (_messageController.text.isNotEmpty || imageUrl != null) {
      if (_editingMessageId != null) {
        await _messagesCollection.doc(_editingMessageId).update({
          'text': _messageController.text,
          'createdAt': Timestamp.now(),
          'imageUrl': imageUrl ?? '',
        });
        setState(() {
          _editingMessageId = null;
        });
      } else {
        await _messagesCollection.add({
          'text': _messageController.text,
          'createdAt': Timestamp.now(),
          'senderId': currentUserId,
          'imageUrl': imageUrl ?? '',
        });
      }
      _messageController.clear();
    }
  }

  void _deleteMessage(DocumentSnapshot messageSnapshot) async {
    setState(() {
      _deletedMessageSnapshot = messageSnapshot;
      _deletedMessageText = messageSnapshot['text'];
      _deletedMessageSenderId = messageSnapshot['senderId'];
    });

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

  void _undoDeleteMessage() {
    if (_deletedMessageSnapshot != null) {
      _messagesCollection.add({
        'text': _deletedMessageText ?? '',
        'createdAt': Timestamp.now(),
        'senderId': _deletedMessageSenderId,
        'imageUrl': _deletedMessageSnapshot!['imageUrl'] ?? '',
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String imageUrl = await _uploadImageToFirebase(imageFile);
      _sendMessage(imageUrl: imageUrl);
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageRef.putFile(imageFile);
    return await imageRef.getDownloadURL();
  }

  Future<String> _getUsername(String senderId) async {
  if (senderId.isEmpty) {
    return 'Unknown User'; // Handle empty senderId gracefully
  }
  
  try {
    final userDoc = await _usersCollection.doc(senderId).get();
    return userDoc['username'] ?? 'Unknown User'; // Provide default if username is null
  } catch (e) {
    print('Error getting username: $e');
    return 'Unknown User';
  }
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
            onPressed: () {},
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
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final messageSnapshot = messages[index];
                    final bool isMe = message['senderId'] == currentUserId;

                    return FutureBuilder<String>(
                      future: _getUsername(message['senderId'] ?? ''),
                      builder: (context, usernameSnapshot) {
                        if (!usernameSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final username = usernameSnapshot.data ?? 'Unknown User';

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: () => _showMessageOptions(context, messageSnapshot),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12.0),
                                  topRight: const Radius.circular(12.0),
                                  bottomLeft: isMe ? const Radius.circular(12.0) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(12.0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message['imageUrl'] != null && message['imageUrl'].isNotEmpty)
                                    Image.network(message['imageUrl']),
                                  if (message['text'] != null && message['text'].isNotEmpty)
                                    Text(
                                      message['text'],
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  const SizedBox(height: 5),
                                  Text(
                                    username, // Display username from users collection
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 12.0,
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
                  icon: const Icon(Icons.photo, color: Color.fromARGB(255, 153, 85, 240)),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
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
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, DocumentSnapshot messageSnapshot) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
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
          ],
        );
      },
    );
  }
}
