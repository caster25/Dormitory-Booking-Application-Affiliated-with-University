// ignore_for_file: library_private_types_in_public_api

import 'package:dorm_app/screen/user/screen/detail.dart';
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

  Widget _buildDormitoryCard(DocumentSnapshot dorm, String dormId) {
    bool isFavorite = favorites.contains(dormId); // ตรวจสอบสถานะของหัวใจ
    List<dynamic> images = dorm['imageUrl'];
    final formatNumber = NumberFormat('#,##0');

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 229, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dorm images - ดึงรูปแรกจาก list
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              image: DecorationImage(
                image: NetworkImage(
                  images.isNotEmpty ? images[0] : '',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dorm['name'], // แสดงชื่อ dormitory
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'ราคา: ${formatNumber.format(dorm['price'])} บาท', // แสดงราคา
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () async {
              await _toggleFavorite(dormId);
              setState(() {
                // อัปเดต favorites ที่จะทำให้ UI เปลี่ยนแปลง
                isFavorite = !isFavorite;
                if (isFavorite) {
                  favorites.add(dormId); // เพิ่มหอพักใน favorites
                } else {
                  favorites.remove(dormId); // ลบหอพักออกจาก favorites
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchFavorites(); // เรียกใช้ฟังก์ชันเพื่อดึง favorites
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
      backgroundColor: const Color.fromARGB(255, 223, 212, 253),
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
                        enlargeCenterPage: true,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dorm['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ราคา: ${formatNumber.format(dorm['price'])} บาท',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'คะแนน: ${dorm['rating']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text("No dormitories available."));
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'ค้นหาหอพัก',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 153, 158, 158),
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Display the dormitory cards
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('dormitories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dormitories = snapshot
                      .data!.docs; // This is where 'dormitories' is defined.

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount:
                        dormitories.length, // Accessing 'dormitories' here.
                    itemBuilder: (context, index) {
                      var dorm =
                          dormitories[index]; // This line is causing the error.
                      String dormId = dorm.id; // Get dormId from Document ID
                      return _buildDormitoryCard(dorm, dormId);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
