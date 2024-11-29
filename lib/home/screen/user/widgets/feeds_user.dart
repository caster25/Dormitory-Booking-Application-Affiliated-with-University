// ignore_for_file: library_private_types_in_public_api, unused_element

import 'package:dorm_app/home/screen/user/screen/detail.dart';
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
    bool isFavorite =
        favorites.contains(dormId); // Check if the dormitory is a favorite
    List<dynamic> images = dorm['imageUrl'];
    final formatNumber = NumberFormat('#,##0');

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return DormallDetailScreen(
            dormId: dormId, // Pass dormId to the detail screen
          );
        }));
      },
      child: Card(
        margin:
            const EdgeInsets.symmetric(vertical: 8.0), // Add margin for spacing
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Card shape
        ),
        elevation: 7, // Add shadow to the card
        child: LayoutBuilder(
          builder: (context, constraints) {
            double fontSize = constraints.maxWidth < 200
                ? 12
                : 14; // Adjust font size based on card width

            return Column(
              mainAxisSize:
                  MainAxisSize.max, // Use appropriate size for the Column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          images.isNotEmpty
                              ? images[0]
                              : 'URL_placeholder_image',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    // Allow scrolling if needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']})',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Prevent text overflow
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'จำนวนห้องที่ว่าง ${dorm['availableRooms']} ห้อง',
                                style: TextStyle(fontSize: fontSize),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'จำนวนห้องทั้งหมด ${dorm['totalRooms']} ห้อง',
                                style: TextStyle(fontSize: fontSize),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'ราคา: ${formatNumber.format(dorm['price'])} บาท',
                                style: TextStyle(fontSize: fontSize),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                dorm['rating'] != null && dorm['rating'] > 0
                                    ? 'คะแนน ${dorm['rating'] % 1 == 0 ? dorm['rating'].toStringAsFixed(0) : dorm['rating'].toStringAsFixed(1)}/5'
                                    : 'ยังไม่มีการรีวิว',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

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
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      8), // เพิ่ม padding เพื่อให้ข้อความไม่ติดขอบ
                                  color: Colors.black.withOpacity(
                                      0.5), // เปลี่ยนสีพื้นหลังให้ทึบขึ้น
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']}) ',
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
                                        dorm['rating'] != null &&
                                                dorm['rating'] > 0
                                            ? 'คะแนน ${dorm['rating'] % 1 == 0 ? dorm['rating'].toStringAsFixed(0) : dorm['rating'].toStringAsFixed(1)}/5' // แสดงคะแนนตามเงื่อนไข
                                            : 'ยังไม่มีการรีวิว',
                                        style:
                                            const TextStyle(color: Colors.red),
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
                    mainAxisAlignment:
                        MainAxisAlignment.start, // จัดให้อยู่กลาง
                    children: [
                      Icon(
                        Icons.hotel, // เลือกไอคอนที่ต้องการ
                        color: Colors.purple, // สีของไอคอน
                        size: 24, // ขนาดของไอคอน
                      ),
                      SizedBox(width: 8), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
                      Text(
                        'หอพักที่แนะนำ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
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

                  // Accessing the dormitory data from Firestore
                  final dormitories = snapshot.data!.docs;

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
                    itemCount: dormitories.length,
                    itemBuilder: (context, index) {
                      // Extract data for each dormitory
                      var dorm = dormitories[index];
                      Map<String, dynamic> dormData = dorm.data()
                          as Map<String, dynamic>; // Cast the data properly
                      String dormId =
                          dorm.id; // Get the dormitory ID from the document ID

                      // Build the dormitory card with the necessary data
                      return _buildDormitoryCard(dorm,
                          dormId); // Pass dormData instead of dorm directly
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
