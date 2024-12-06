// ignore_for_file: library_private_types_in_public_api, unused_element
import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/screen/detail.dart';
import 'package:dorm_app/features/screen/user/utils/build_dorm_end.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({super.key});

  @override
  _FeedsScreenState createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  List<String> favorites = []; // สร้างรายการ favorites ใน state

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        setState(() {
          favorites = List<String>.from(userSnapshot['favorites'] ?? []);
        });
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatNumber = NumberFormat('#,##0');
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // ปรับ padding ให้เหมาะสม
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider for recommended dormitories
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('dormitories')
                    .where('rating', isGreaterThan: 4.5)
                    .limit(8)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dorms = snapshot.data!.docs;
                  if (dorms.isNotEmpty) {
                    return CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 350,
                        autoPlay: true,
                        viewportFraction: 0.8,
                        aspectRatio: 2.0,
                        onPageChanged: (index, reason) {},
                      ),
                      itemCount: dorms.length,
                      itemBuilder: (context, index, realIndex) {
                        var dorm = dorms[index];
                        String dormId = dorm.id; // Get dormId from Document ID

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return DormallDetailScreen(
                                dormId:
                                    dormId, // Pass dormId to the detail screen
                              );
                            }));
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    dorm['imageUrl'][0],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 350,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      10), // เพิ่ม padding เพื่อให้ข้อความไม่ติดขอบ
                                  color: Colors.black.withOpacity(
                                      0.6), // เปลี่ยนสีพื้นหลังให้ทึบขึ้น
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget.buildText(
                                          text:
                                              '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']}) ',
                                          fontSize: 18),
                                      const SizedBox(height: 4),
                                      TextWidget.buildText(
                                          text:
                                              'ราคา: ${formatNumber.format(dorm['price'])} บาท',
                                          color: ColorsApp.red),
                                      const SizedBox(height: 2),
                                      TextWidget.buildText(
                                        text: dorm['rating'] != null &&
                                                dorm['rating'] > 0
                                            ? 'คะแนน ${dorm['rating'] % 1 == 0 ? dorm['rating'].toStringAsFixed(0) : dorm['rating'].toStringAsFixed(1)}/5' // แสดงคะแนนตามเงื่อนไข
                                            : 'ยังไม่มีการรีวิว',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                        child: TextWidget.buildText(
                      text: "No dormitories available.",
                    ));
                  }
                },
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // จัดให้อยู่กลาง
                    children: [
                      Icon(
                        Icons.hotel, // เลือกไอคอนที่ต้องการ
                        color: Colors.purple, // สีของไอคอน
                        size: 24, // ขนาดของไอคอน
                      ),
                      SizedBox(width: 8), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
                      TextWidget.buildText(
                        text: 'หอพักที่แนะนำ',
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              CardDorm()
            ],
          ),
        ),
      ),
    );
  }
}
