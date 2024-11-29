// ignore_for_file: unused_field

import 'dart:io';

import 'package:dorm_app/model/Userprofile.dart';
import 'package:dorm_app/screen/owner/widget/dormitory_list_edit.dart';
import 'package:dorm_app/screen/setting/setting.dart';
import 'package:dorm_app/screen/setting/submitIssue.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class Profileowner extends StatefulWidget {
  const Profileowner({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileownerState createState() => _ProfileownerState();
}

class _ProfileownerState extends State<Profileowner> {
  File? _profileImage;
  File? _tempImage; // Temporary image to be saved
  String _userName = 'Unknown User';
  String? _profileImageUrl;
  @override
  void initState() {
    super.initState();
    _loadOwnerProfile();
  }

  Future<void> _loadOwnerProfile() async {
    try {
      final userProfile = await getUserProfile();
      setState(() {
        _userName = userProfile.username ?? 'Unknown User';
        _profileImageUrl = userProfile.profilePictureURL;
      });
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<UserProfile> getUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User profile not found');
    }

    final userData = userDoc.data()!;
    return UserProfile(
      email: userData['email'],
      numphone: userData['numphone'],
      username: userData['username'],
      fullname: userData['fullname'],
      profilePictureURL: userData['profilePictureURL'],
    );
  }

  // ฟังก์ชันสำหรับเลือกภาพ
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _tempImage = File(pickedFile.path); // Use a temporary image
      });
      _showConfirmationDialog(); // Show the confirmation dialog after image selection
    }
  }

  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการเปลี่ยนรูปโปรไฟล์'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tempImage != null
                  ? Image.file(
                      _tempImage!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              const Text('คุณแน่ใจว่าจะเปลี่ยนรูปโปรไฟล์?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
                setState(() {
                  _tempImage = null; // Revert to previous image
                });
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _uploadProfileImage(); // Upload the image if confirmed
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadProfileImage() async {
    if (_tempImage == null) return;

    try {
      final fileName = p.basename(_tempImage!.path);
      final destination = 'profiles/$fileName';
      final ref = FirebaseStorage.instance.ref(destination);
      final uploadTask = ref.putFile(_tempImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Update the profile picture URL in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profilePictureURL': downloadUrl});

      setState(() {
        _profileImageUrl = downloadUrl; // Update the profile image URL
        _tempImage = null; // Clear the temporary image
      });
      print('Profile image uploaded successfully');
    } catch (e) {
      print('Failed to upload profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: userId != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            } else {
              final userProfile = UserProfile.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundImage: (userProfile.profilePictureURL !=
                                      null &&
                                  userProfile.profilePictureURL!.isNotEmpty &&
                                  Uri.tryParse(userProfile.profilePictureURL!)
                                          ?.hasScheme ==
                                      true)
                              ? NetworkImage(userProfile.profilePictureURL!)
                              : null, // Don't provide a NetworkImage if URL is invalid
                          child: userProfile.profilePictureURL == null ||
                                  userProfile.profilePictureURL!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile.username ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(userProfile.fullname ?? 'No name provided'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 16), // เพิ่มระยะห่างระหว่างชื่อและการ์ด
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('รายละเอียดหอพัก'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DormitoryListEditScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('การตั้งค่า'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: const Text('แจ้งระบบต่างๆ'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubmitIssueScreen()),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
