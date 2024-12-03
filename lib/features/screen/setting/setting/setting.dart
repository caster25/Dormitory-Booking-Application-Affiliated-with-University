import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/features/screen/setting/about.dart';
import 'package:dorm_app/features/screen/setting/setting/account.dart';
import 'package:dorm_app/features/screen/setting/setting/language.dart';
import 'package:dorm_app/features/screen/setting/setting/theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'การตั้งค่า', context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuItem(
              icon: Icons.account_circle_outlined,
              text: 'ข้อมูลบัญชี',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountInfoScreen(),
                  ),
                );
              },
            ),
            MenuItem(
              icon: Icons.language_outlined,
              text: 'ภาษา',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );
              },
            ),
            MenuItem(
              icon: Icons.info_outline,
              text: 'เกี่ยวกับเรา',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            MenuItem(
              icon: Icons.info_outline,
              text: 'theme',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  SettingsScreenTheme(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap; // Add onTap to allow for navigation

  const MenuItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}