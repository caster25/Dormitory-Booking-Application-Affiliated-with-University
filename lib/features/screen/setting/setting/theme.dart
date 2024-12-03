import 'package:dorm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreenTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: SwitchListTile(
          title: Text('Dark Mode'),
          value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
          onChanged: (bool value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
      ),
    );
  }
}

