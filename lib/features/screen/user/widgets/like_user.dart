// ignore_for_file: collection_methods_unrelated_type

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/screen/detail.dart';
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

        if (favorites.isNotEmpty) {
          QuerySnapshot dormsQuery = await FirebaseFirestore.instance
              .collection('dormitories')
              .where(FieldPath.documentId, whereIn: favorites)
              .get();

          setState(() {
            likedDorms = dormsQuery.docs;
          });
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
        setState(() {
          if (favoritesList.contains(dormId)) {
            favoritesList.remove(dormId);
            likedDorms.removeWhere((dorm) => dorm.id == dormId);
          } else {
            favoritesList.add(dormId);
            // Fetch the dorm and add to likedDorms
            FirebaseFirestore.instance
                .collection('dormitories')
                .doc(dormId)
                .get()
                .then((dorm) {
              if (dorm.exists) {
                setState(() {
                  likedDorms.add(dorm);
                });
              }
            });
          }
        });

        await userDoc.update({'favorites': favoritesList});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'หอพักที่ถูกใจ', context: context),
      body: likedDorms.isEmpty
          ? Center(child: TextWidget.buildText(text: 'ไม่มีหอพักที่ถูกใจ'))
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
                        SizedBox(
                          height: 200,
                          child: dorm['imageUrl'] != null &&
                                  dorm['imageUrl'].isNotEmpty
                              ? PageView.builder(
                                  itemCount: dorm['imageUrl'].length,
                                  itemBuilder: (context, imageIndex) {
                                    return Image.network(
                                      dorm['imageUrl'][imageIndex],
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Center(
                                  child: TextWidget.buildText(
                                      text: 'ไม่มีรูปภาพ')),
                        ),

                        ListTile(
                          title: TextWidget.buildText(
                              text:
                                  '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']}) ',
                              fontSize: 20),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.buildText(
                                text:
                                    'ราคา: ${dorm['price'] != null ? formatNumber.format(dorm['price']) : 'ไม่ระบุ'} บาท/เทอม',
                                color: ColorsApp.red,
                              ),
                              TextWidget.buildText(
                                text: dorm['rating'] != null &&
                                        dorm['rating'] > 0
                                    ? 'คะแนน: ${dorm['rating'] % 1 == 0 ? dorm['rating'].toInt() : dorm['rating'].toStringAsFixed(1)}/5'
                                    : 'ยังไม่มีการรีวิว',
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
