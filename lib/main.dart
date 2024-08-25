
import 'package:dorm_app/screen/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dorm_app/screen/owner/details.dart';

void main() async {
  // Ensure that Flutter services are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with FirebaseOptions
  await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: 'AIzaSyDNmyeh6dFL65qhXP2bkOowgl_97O4glkY',
    appId: '1:870658394151:android:db7be5de05075a91e5e602',
    messagingSenderId: 'G-T3QSM1C2CH',
    projectId: 'accommoease',
    storageBucket: 'accommoease.appspot.com',
  ));

  runApp( details());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(

      debugShowCheckedModeBanner: false,
      //home: IndexScreen(),

      home: MyApp(),
    );
  }
}
