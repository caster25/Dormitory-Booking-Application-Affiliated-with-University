// ignore_for_file: use_build_context_synchronously, unnecessary_nullable_for_final_variable_declarations

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: use_key_in_widget_constructors
class SubmitIssueScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SubmitIssueScreenState createState() => _SubmitIssueScreenState();
}

class _SubmitIssueScreenState extends State<SubmitIssueScreen> {
  final TextEditingController issueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _submitIssue() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // Fetch user details from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found in Firestore')),
      );
      return;
    }

    final userData = userDoc.data();
    List<String> imageUrls = [];

    // Upload each selected image to Firebase Storage
    for (var image in _selectedImages) {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('issue_images/$fileName');

      UploadTask uploadTask = storageRef.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    final issueData = {
      'userId': user.uid,
      'username': userData?['username'] ?? 'Unknown',
      'fullname':
          '${userData?['firstname'] ?? ''} ${userData?['lastname'] ?? ''}',
      'role': userData?['role'] ?? 'User',
      'issue': issueController.text,
      'description': descriptionController.text,
      'images': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('issues').add(issueData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Issue submitted successfully')),
    );

    issueController.clear();
    descriptionController.clear();
    _selectedImages.clear();
    setState(() {});
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();

    if (selectedImages != null) {
      setState(() {
        _selectedImages.addAll(selectedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        title: const Text('Submit Issue')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: issueController,
                        decoration: InputDecoration(
                          labelText: 'ประเภทปัญหา',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'รายละเอียด',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'แนบรูปภาพ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImages,
                        child: const Text('เลือกรูปภาพ'),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        children:
                            List.generate(_selectedImages.length, (index) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                File(_selectedImages[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitIssue,
                  // ignore: sort_child_properties_last
                  child: const Text('ส่งปัญหา'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
