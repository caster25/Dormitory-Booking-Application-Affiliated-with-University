// ignore_for_file: unused_field, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/dialogs/card_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/model/Userprofile.dart';
import 'package:dorm_app/features/screen/setting/setting/detail_dromuser.dart';
import 'package:dorm_app/features/screen/setting/setting/setting.dart';
import 'package:dorm_app/features/screen/setting/submitIssue.dart';
import 'package:dorm_app/features/screen/user/screen/featurres/book_dorm/book_dorm.dart';
import 'package:dorm_app/features/screen/user/widgets/like_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  File? _tempImage; // Temporary image to be saved
  String _userName = 'Unknown User';
  String? _profileImageUrl;
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
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

  Future<void> _pickImage() async {
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
          title: TextWidget.buildText( text: 'ยืนยันการเปลี่ยนรูปโปรไฟล์'),
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
              TextWidget.buildText( text: 'คุณแน่ใจว่าจะเปลี่ยนรูปโปรไฟล์?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: TextWidget.buildText( text: 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
                setState(() {
                  _tempImage = null; // Revert to previous image
                });
              },
            ),
            ElevatedButton(
              child: TextWidget.buildText( text: 'Save'),
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
                            TextWidget.buildText( text: 
                              userProfile.username ?? 'Unknown User', fontSize: 18
                            ),
                          TextWidget.buildText( text: userProfile.fullname ?? 'No name provided'),
                          ],
                        ),
                      ],
                    ),
                  ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     // นำผู้ใช้ไปยังหน้าจอการยืนยันตัวตน
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) =>
                        //             EmailOtpVerificationScreen(), // ไปยังหน้าจอยืนยันตัวตน
                        //       ),
                        //     );
                        //   },
                        //   child: const Text('ยืนยันตัวตน'),
                        //   style: ElevatedButton.styleFrom(
                        //     foregroundColor: Colors.white,
                        //     backgroundColor: Colors.blue, // สีข้อความของปุ่ม
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius:
                        //           BorderRadius.circular(8), // รูปทรงของปุ่ม
                        //     ),
                        //   ),
                        // ),
                      
                  CardWidget(
                    title: 'รายละเอียดหอพักของคุณ',
                    leadingIcon: Icon(Icons.info_outline),
                    nextScreen: DormitoryDetailsScreen(userId: userId!),
                  ),
                  CardWidget(
                      title: 'หอพักของคุณ',
                      leadingIcon: Icon(Icons.domain_add_rounded),
                      nextScreen: BookDorm(userId: userId)),
                  CardWidget(
                      title: 'หอพักที่คุณถูกใจ',
                      leadingIcon: Icon(Icons.favorite_border),
                      nextScreen: LikeScreen()),
                  CardWidget(
                      title: 'การตั้งค่า',
                      leadingIcon: Icon(Icons.settings),
                      nextScreen: SettingsScreen()),
                  CardWidget(
                      title: 'แจ้งระบบต่างๆ',
                      leadingIcon: Icon(Icons.notifications_none),
                      nextScreen: SubmitIssueScreen()),
                ]
              );
            }
          },
        ),
      ),
    );
  }
}
