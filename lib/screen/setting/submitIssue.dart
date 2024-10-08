import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SubmitIssueScreen extends StatefulWidget {
  @override
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
      SnackBar(content: Text('User not found in Firestore')),
    );
    return;
  }

  final userData = userDoc.data();
  List<String> imageUrls = [];

  // Upload each selected image to Firebase Storage
  for (var image in _selectedImages) {
    // Create a reference to the Firebase Storage
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
    Reference storageRef = FirebaseStorage.instance.ref().child('issue_images/$fileName');

    // Upload the image
    UploadTask uploadTask = storageRef.putFile(File(image.path));
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();
    imageUrls.add(downloadUrl);
  }

  final issueData = {
    'userId': user.uid,
    'username': userData?['username'] ?? 'Unknown',
    'fullname': '${userData?['firstname'] ?? ''} ${userData?['lastname'] ?? ''}',
    'role': userData?['role'] ?? 'User', // Capture user role
    'issue': issueController.text,
    'description': descriptionController.text,
    'images': imageUrls, // Store image URLs
    'timestamp': FieldValue.serverTimestamp(),
  };

  // Add the issue to the 'issues' collection in Firestore
  await FirebaseFirestore.instance.collection('issues').add(issueData);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Issue submitted successfully')),
  );

  // Clear the form
  issueController.clear();
  descriptionController.clear();
  _selectedImages.clear();
  setState(() {}); // Refresh the UI
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
      appBar: AppBar(title: Text('Submit Issue')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: issueController,
              decoration: InputDecoration(labelText: 'ประเภทปัญหา'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'รายละเอียด'),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('แนบรูปภาพ'),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: List.generate(_selectedImages.length, (index) {
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
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeImage(index),
                    ),
                  ],
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitIssue,
              child: Text('ส่งปัญหา'),
            ),
          ],
        ),
      ),
    );
  }
}
