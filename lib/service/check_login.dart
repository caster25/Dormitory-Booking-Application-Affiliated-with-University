// import 'package:dorm_app/screen/index.dart';
// import 'package:dorm_app/screen/owner/screen/home_owner.dart';
// import 'package:dorm_app/screen/user/screen/homepage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class CheckLogin extends StatelessWidget {
//   final User user;

//   const CheckLogin({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     if (user.role == 'owner') {
//       return Ownerhome();
//     }
//     else if ( user.role == 'user'){
//       return const Homepage();
//     } 
//     else {
//       return const IndexScreen();
//     }
//   }
// }