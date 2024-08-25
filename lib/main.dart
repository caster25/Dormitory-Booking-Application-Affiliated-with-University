import 'package:dorm_app/screen/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // Ensure that Flutter services are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with FirebaseOptions
  await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: 'AIzaSyDA49g2xSyXOmG5SweyId42GnIRiUhNPEE',
    appId: '1:1014382826581:android:8640792bf386f56a8170dc',
    messagingSenderId: 'G-T3QSM1C2CH',
    projectId: 'accommoease-6ebe0',
    storageBucket: 'accommoease-6ebe0.appspot.com',
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect to API',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IndexScreen(),
    );
  }
}
