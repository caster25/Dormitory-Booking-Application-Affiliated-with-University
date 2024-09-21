import 'package:dorm_app/model/Userprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // User Registration
  Future<void> registerUser({
    required String email,
    required String password,
    required String username,
    required String fullname,
    required String numphone,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Create a UserProfile instance
        UserProfile userProfile = UserProfile(
          idusers: currentUser.uid,
          email: email,
          username: username,
          fullname: fullname,
          numphone: numphone,
          role: 'user',  // Assuming a default role of 'user'
        );

        // Save user data to Firestore using UserProfile's toMap method
        await _usersCollection.doc(currentUser.uid).set(userProfile.toMap());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'อีเมลนี้มีการใช้งานแล้ว กรุณาใช้อีเมลอื่น',
        );
      } else {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: e.message ?? 'An unknown error occurred',
        );
      }
    }
  }
}
