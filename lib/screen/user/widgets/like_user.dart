import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  List<DocumentSnapshot> likedDorms = [];

  @override
  void initState() {
    super.initState();
    _fetchLikedDorms();
  }

  Future<void> _fetchLikedDorms() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userFavoritesRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userDoc = await userFavoritesRef.get();

      if (userDoc.exists && userDoc.data()!.containsKey('favorites')) {
        List<dynamic> favorites = userDoc['favorites'];

        // ดึงข้อมูลหอพักที่อยู่ใน favorites
        for (String dormId in favorites) {
          DocumentSnapshot dorm = await FirebaseFirestore.instance
              .collection('dormitories')
              .doc(dormId)
              .get();

          if (dorm.exists) {
            setState(() {
              likedDorms.add(dorm); // เก็บข้อมูลหอพักที่ชอบ
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หอพักที่ถูกใจ'),
      ),
      body: likedDorms.isEmpty
          ? const Center(child: Text('ไม่มีหอพักที่ถูกใจ'))
          : ListView.builder(
              itemCount: likedDorms.length,
              itemBuilder: (context, index) {
                var dorm = likedDorms[index];

                return ListTile(
                  leading: Image.network(dorm['imageUrl'], fit: BoxFit.cover),
                  title: Text(dorm['name']),
                  subtitle: Text('ราคา: ${dorm['price']} บาท/เดือน\n'
                      'คะแนน: ${dorm['rating']}/5'),
                  trailing: const Icon(Icons.favorite, color: Colors.pink),
                );
              },
            ),
    );
  }
}
