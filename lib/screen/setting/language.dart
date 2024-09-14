import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกภาษา'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('ภาษาไทย'),
            onTap: () {
              // Code to change language to Thai
              _changeLanguage(context, 'th');
            },
          ),
          ListTile(
            title: const Text('English'),
            onTap: () {
              // Code to change language to English
              _changeLanguage(context, 'en');
            },
          ),
          // Add more languages here
        ],
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    // Function to change language
    // Example: Change app language and refresh the app
  }
}