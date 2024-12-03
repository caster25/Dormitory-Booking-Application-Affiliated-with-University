import 'package:dorm_app/service/login_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with FirebaseOptions
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDNmyeh6dFL65qhXP2bkOowgl_97O4glkY',
      appId: '1:870658394151:android:db7be5de05075a91e5e602',
      messagingSenderId: 'G-T3QSM1C2CH',
      projectId: 'accommoease',
      storageBucket: 'accommoease.appspot.com',
    ),
  );

  // Run the app with the ThemeProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blueGrey,
          ),
          home: const LoginService(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  // เริ่มต้นให้ใช้ Light Mode
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();  // แจ้งให้ทุกคนที่ฟังการเปลี่ยนแปลงได้รับรู้
  }
}
