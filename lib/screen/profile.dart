import 'package:dorm_app/model/Userprofile.dart';
import 'package:dorm_app/screen/owner/profile.dart';
import 'package:flutter/material.dart';
 // เปลี่ยนให้ตรงกับ path ของไฟล์ของคุณ

class ProfileScreen extends StatelessWidget {
  final UserProfile? userProfile;

  const ProfileScreen({super.key, this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: userProfile?.profilePictureURL != null
                      ? NetworkImage(userProfile!.profilePictureURL!)
                      : const NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สวัสดีค่ะ คุณ ${userProfile?.firstname ?? 'ชื่อผู้ใช้'} ${userProfile?.lastname ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(userProfile?.role ?? 'หอพักบ้านแสนสุข'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Column(
              children: [
                MenuItem(
                  icon: Icons.info_outline,
                  text: 'รายละเอียดหอพักของคุณ',
                ),
                MenuItem(
                  icon: Icons.favorite_border,
                  text: 'หอพักที่ถูกใจ',
                ),
                MenuItem(
                  icon: Icons.settings,
                  text: 'การตั้งค่า',
                ),
                MenuItem(
                  icon: Icons.notifications_none,
                  text: 'แจ้งเตือน',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
