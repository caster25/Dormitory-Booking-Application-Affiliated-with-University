import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  List<DocumentSnapshot> likedDorms = [];
  final formatNumber = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    _fetchLikedDorms();
  }

  Future<void> _fetchLikedDorms() async {
    final user = FirebaseAuth.instance.currentUser;
    final formatNumber = NumberFormat('#,##0');

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
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
        title: const Text('หอพักที่ถูกใจ'),
      ),
      body: likedDorms.isEmpty
          ? const Center(child: Text('ไม่มีหอพักที่ถูกใจ'))
          : ListView.builder(
              itemCount: likedDorms.length,
              itemBuilder: (context, index) {
                var dorm = likedDorms[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // PageView for images
                      SizedBox(
                        height: 200, // Adjust height as needed
                        child: PageView.builder(
                          itemCount:
                              dorm['imageUrl'].length, // Use list of image URLs
                          itemBuilder: (context, imageIndex) {
                            return Image.network(
                              dorm['imageUrl'][imageIndex],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      ListTile(
                        title: Text( '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']}) ',),
                        subtitle: Text(
                          'ราคา: ${formatNumber.format(dorm['price'])} บาท/เทอม\n'
                          '${dorm['rating'] != null && dorm['rating'] > 0 ? 'คะแนน: ${dorm['rating']?.toStringAsFixed(0)}/5' : 'ยังไม่มีการรีวิว'}',
                        ),
                        trailing:
                            const Icon(Icons.favorite, color: Colors.pink),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
