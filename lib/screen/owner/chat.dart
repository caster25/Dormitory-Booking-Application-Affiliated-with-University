import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDNmyeh6dFL65qhXP2bkOowgl_97O4glkY',
      appId: '1:870658394151:android:db7be5de05075a91e5e602',
      messagingSenderId: 'G-T3QSM1C2CH',
      projectId: 'accommoease',
      storageBucket: 'accommoease.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  String? _editingMessageId; // To store the message ID being edited

  String currentUser = 'มี๊เจ๋ง'; // Change this to 'owner' or 'tenant' based on the logged-in user

  /// Function to send a message (text or images)
  void _sendMessage({String? text, List<String>? imageUrls}) async {
    if ((text != null && text.isNotEmpty) || (imageUrls != null && imageUrls.isNotEmpty)) {
      if (_editingMessageId != null) {
        // Update the existing message
        await _messagesCollection.doc(_editingMessageId).update({
          'text': text ?? '',
          'createdAt': Timestamp.now(),
          'imageUrls': imageUrls ?? [], // Update imageUrls if provided
        });
        setState(() {
          _editingMessageId = null; // Clear the editing state
        });
      } else {
        // Add a new message
        await _messagesCollection.add({
          'text': text ?? '',
          'createdAt': Timestamp.now(),
          'sender': currentUser,
          'imageUrls': imageUrls ?? [],
        });
      }
      _messageController.clear(); // Clear the message input field
    }
  }

  /// Function to delete a message
  void _deleteMessage(DocumentSnapshot messageSnapshot) async {
    // Delete the message
    await _messagesCollection.doc(messageSnapshot.id).delete();
  }

  /// Function to edit a message
  void _editMessage(DocumentSnapshot messageSnapshot) {
    setState(() {
      _editingMessageId = messageSnapshot.id;
      _messageController.text = messageSnapshot['text'];
    });
  }

  /// Function to pick and send multiple images
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage(); // Allows picking multiple images

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
    final imageRef = storageRef.child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageRef.putFile(imageFile);
    return await imageRef.getDownloadURL();
  }

  /// Function to show a full-screen image in a dialog
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
                  icon: Icon(Icons.close, color: Colors.white),
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
        backgroundColor: Colors.purple,
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
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
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final messageSnapshot = messages[index];
                    final bool isMe = message['sender'] == currentUser;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () => _showMessageOptions(context, messageSnapshot),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                              bottomLeft: isMe ? Radius.circular(12.0) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : Radius.circular(12.0),
                            ),
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
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                  ),
                                ),
                              SizedBox(height: 5),
                              Text(
                                message['sender'],
                                style: TextStyle(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo, color: Colors.purple),
                  onPressed: _pickImages, // Updated to pick multiple images
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
                  icon: Icon(Icons.send, color: Colors.purple),
                  onPressed: () => _sendMessage(text: _messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Function to show options to edit or delete a message
  void _showMessageOptions(BuildContext context, DocumentSnapshot messageSnapshot) {
    final message = messageSnapshot.data() as Map<String, dynamic>;
    final bool isMe = message['sender'] == currentUser;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('แก้ไข'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(messageSnapshot);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('ลบ'),
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
