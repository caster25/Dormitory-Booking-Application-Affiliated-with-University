import 'package:dorm_app/screen/user/screen/detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FeedsScreen extends StatelessWidget {
  const FeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider for recommended dormitories
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('dormitories')
                    .where('rating',
                        isGreaterThan: 4.5) // กรองหอพักที่มีคะแนนมากกว่า 4.5
                    .limit(8) // ดึงข้อมูลไม่เกิน 8 รายการ
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dorms = snapshot.data!.docs;

                  return CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {},
                    ),
                    itemCount: dorms.length,
                    itemBuilder: (context, index, realIndex) {
                      var dorm = dorms[index];
                      String dormId = dorm.id; // ดึง dormId จาก Document ID

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DormallDetailScreen(
                              dormId: dormId, // ส่ง dormId ไปยังหน้ารายละเอียด
                            );
                          }));
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                                  dorm['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Text(
                                dorm['name'],
                                style: const TextStyle(
                                  fontSize: 18,
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
                            ),
                          ],
                        ),
                      );
                    },
                  );
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
                                      BorderRadius.all(Radius.circular(1.0))),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 5.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                child: Row(
                  children: [
                    Icon(Icons.recommend, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'แนะนำ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('dormitories')
                        .where('rating',
                            isGreaterThanOrEqualTo:
                                4.0) // กรองหอพักที่มีคะแนนรีวิวตั้งแต่ 4.0 ขึ้นไป
                        .limit(10) // ดึงข้อมูลไม่เกิน 10 รายการ
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final dorms = snapshot.data!.docs;

                      return Row(
                        children: List.generate(dorms.length, (index) {
                          var dorm = dorms[index];
                          String dormId = dorm.id; // ดึง dormId จาก Document ID

                          return Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 200,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 241, 229, 255),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 170,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    image: DecorationImage(
                                      image: dorm['imageUrl'] != null
                                          ? NetworkImage(dorm['imageUrl'])
                                          : const AssetImage(
                                                  'assets/images/placeholder.png')
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dorm['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'ราคาเริ่มต้น ${dorm['price']} บาท/เดือน',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return DormallDetailScreen(
                                            dormId: dormId);
                                      }));
                                    },
                                    child: const Text('เพิ่มเติม'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
