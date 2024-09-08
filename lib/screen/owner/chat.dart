import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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

  String? _editingMessageId; // To store the message ID being edited
  String? _deletedMessageText; // To store the deleted message text
  String? _deletedMessageSender; // To store the sender of the deleted message
  DocumentSnapshot? _deletedMessageSnapshot; // To store the deleted message snapshot

  String currentUser = 'น้องหมูเด้ง'; // Change this to 'owner' or 'tenant' based on the logged-in user

  /// Function to send a message (text or image)
  void _sendMessage({String? imageUrl}) async {
    if (_messageController.text.isNotEmpty || imageUrl != null) {
      if (_editingMessageId != null) {
        // Update the existing message
        await _messagesCollection.doc(_editingMessageId).update({
          'text': _messageController.text,
          'createdAt': Timestamp.now(),
          'imageUrl': imageUrl ?? '', // Update imageUrl if provided
        });
        setState(() {
          _editingMessageId = null; // Clear the editing state
        });
      } else {
        // Add a new message
        await _messagesCollection.add({
          'text': _messageController.text,
          'createdAt': Timestamp.now(),
          'sender': currentUser, // Use the current user's role ('tenant' or 'owner')
          'imageUrl': imageUrl ?? '',
        });
      }
      _messageController.clear(); // Clear the message input field
    }
  }

  /// Function to delete a message
  void _deleteMessage(DocumentSnapshot messageSnapshot) async {
    setState(() {
      _deletedMessageSnapshot = messageSnapshot;
      _deletedMessageText = messageSnapshot['text'];
      _deletedMessageSender = messageSnapshot['sender'];
    });

    // Delete the message
    await _messagesCollection.doc(messageSnapshot.id).delete();

    // Show a snackbar with an Undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _undoDeleteMessage,
        ),
      ),
    );
  }

  /// Function to undo a deleted message
  void _undoDeleteMessage() {
    if (_deletedMessageSnapshot != null) {
      _messagesCollection.add({
        'text': _deletedMessageText,
        'createdAt': Timestamp.now(),
        'sender': _deletedMessageSender,
        'imageUrl': _deletedMessageSnapshot!['imageUrl'] ?? '',
      });
      _deletedMessageSnapshot = null;
      _deletedMessageText = null;
      _deletedMessageSender = null;
    }
  }

  /// Function to edit a message
  void _editMessage(DocumentSnapshot messageSnapshot) {
    setState(() {
      _editingMessageId = messageSnapshot.id;
      _messageController.text = messageSnapshot['text'];
    });
  }

  /// Function to pick and send an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String imageUrl = await _uploadImageToFirebase(imageFile);
      _sendMessage(imageUrl: imageUrl);
    }
  }

  /// Function to upload image to Firebase Storage and get the URL
  Future<String> _uploadImageToFirebase(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageRef.putFile(imageFile);
    return await imageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
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
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final messageSnapshot = messages[index];
                    final bool isMe = message['sender'] == currentUser; // Check if the message sender is the current user

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
                                message['sender'],
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.purple),
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

  /// Function to show options to edit or delete a message
  void _showMessageOptions(BuildContext context, DocumentSnapshot messageSnapshot) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('แก้ไข'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(messageSnapshot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('ลบ'),
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
