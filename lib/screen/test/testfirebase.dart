import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseTestScreen extends StatefulWidget {
  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isFirebaseInitialized = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _isFirebaseInitialized = true;
      });
    } catch (e) {
      setState(() {
        _message = 'Error initializing Firebase: $e';
      });
    }
  }

  Future<void> _testFirestore() async {
    try {
      CollectionReference testCollection = FirebaseFirestore.instance.collection('test');
      DocumentSnapshot snapshot = await testCollection.doc('test_doc').get();
      if (snapshot.exists) {
        setState(() {
          _message = 'Document data: ${snapshot.data()}';
        });
      } else {
        setState(() {
          _message = 'No such document!';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching document: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
      ),
      body: Center(
        child: _isFirebaseInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _testFirestore,
                    child: const Text('Test Firestore Connection'),
                  ),
                  const SizedBox(height: 20),
                  Text(_message),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
