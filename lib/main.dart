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

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const IndexScreen(),
      // body: const IndexScreen(),
    );
  }
}

class NevigationDrawer extends StatelessWidget {
  const NevigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
