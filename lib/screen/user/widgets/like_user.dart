// ignore_for_file: collection_methods_unrelated_type

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/screen/user/screen/detail.dart';
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
  List<DocumentSnapshot> favoritesList = [];
  final formatNumber = NumberFormat('#,##0');

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

        for (String dormId in favorites) {
          DocumentSnapshot dorm = await FirebaseFirestore.instance
              .collection('dormitories')
              .doc(dormId)
              .get();

          if (dorm.exists) {
            setState(() {
              likedDorms.add(dorm);
            });
          }
        }
      }
    }
  }

  Future<void> _toggleFavorite(String dormId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        List<dynamic> favoritesList = userSnapshot['favorites'] ?? [];
        if (favoritesList.contains(dormId)) {
          favoritesList.remove(dormId); // ลบหอพักออกจากรายการโปรด
        } else {
          favoritesList.add(dormId); // เพิ่มหอพักเข้ารายการโปรด
        }

        await userDoc.update({'favorites': favoritesList});
        setState(() {
          // Refresh liked dorms after toggling favorite
          likedDorms = []; // Reset list
          _fetchLikedDorms(); // Fetch updated liked dorms
        });
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
                String dormId = dorm.id; // ดึง dormId จาก DocumentSnapshot

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      // ใส่โค้ดที่คุณต้องการให้ทำงานเมื่อคลิกที่การ์ด
                      print('Card tapped for ${dorm['name']}');
                      // ตัวอย่าง: นำไปสู่หน้ารายละเอียดหอพัก
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DormallDetailScreen(
                              dormId:
                                  dormId), // เปลี่ยนไปที่หน้ารายละเอียดที่คุณต้องการ
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // PageView for images
                        SizedBox(
                          height: 200, // Adjust height as needed
                          child: PageView.builder(
                            itemCount: dorm['imageUrl'].length,
                            itemBuilder: (context, imageIndex) {
                              return Image.network(
                                dorm['imageUrl'][imageIndex],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']}) ',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                'ราคา: ${formatNumber.format(dorm['price'])} บาท/เทอม',
                              ),
                              Text(
                                dorm['rating'] != null && dorm['rating'] > 0
                                    ? 'คะแนน: ${dorm['rating'] % 1 == 0 ? dorm['rating'].toInt() : dorm['rating'].toStringAsFixed(1)}/5'
                                    : 'ยังไม่มีการรีวิว',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          trailing: GestureDetector(
                            onTap: () async {
                              await _toggleFavorite(dormId);
                              print('Icon tapped for ${dorm['name']}');
                            },
                            child: Icon(
                              favoritesList.contains(dormId)
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
