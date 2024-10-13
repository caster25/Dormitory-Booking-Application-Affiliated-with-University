import 'package:dorm_app/screen/user/screen/detail.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FeedsScreen extends StatelessWidget {
  const FeedsScreen({super.key});

  // ฟังก์ชันสำหรับสร้างการ์ดแสดงข้อมูลของหอพัก
  Widget _buildDormitoryCard(QueryDocumentSnapshot dorm, String dormId, List<String> favorites) {
    bool isFavorite = favorites.contains(dormId); // ตรวจสอบสถานะของหัวใจ
    List<dynamic> images = dorm['imageUrl']; 

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              image: DecorationImage(
                image: NetworkImage(
                  images.isNotEmpty ? images[0] : '', 
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // เพิ่มข้อมูลอื่นๆ ของ dormitory ตามต้องการ
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
              'Price: ${dorm['price']} THB', // แสดงราคา
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // ปุ่มเพิ่ม/ลบจากรายการโปรด
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              // ฟังก์ชันสำหรับเพิ่มหรือลบจาก favorites
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 212, 253),
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
                    .where('rating', isGreaterThan: 4.5)
                    .limit(8) 
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dorms = snapshot.data!.docs;
                  if (dorms.length > 1) {
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
                                dormId: dormId, // Pass dormId to the detail screen
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
                                      'Price: ${dorm['price']} THB',
                                      style: const TextStyle(
                                        fontSize: 12, 
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2), 
                                    Text(
                                      'Rating: ${dorm['rating']}', 
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
                  } else if (dorms.length == 1) {
                    var dorm = dorms[0];
                    String dormId = dorm.id;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return DormallDetailScreen(
                            dormId: dormId, 
                          );
                        }));
                      },
                      child: Container(
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
                          child: Stack(
                            children: [
                              Image.network(
                                dorm['imageUrl'][0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 350,
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
                                      'Price: ${dorm['price']} THB', 
                                      style: const TextStyle(
                                        fontSize: 12, 
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2), 
                                    Text(
                                      'Rating: ${dorm['rating']}', 
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
                        ),
                      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                  color: Color.fromARGB(255, 153, 158, 158),
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
              // Display the dormitory cards
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('dormitories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dormitories = snapshot.data!.docs;
                  List<String> favorites = []; // Load from user preferences or Firestore
                  
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.7, // Adjust as necessary
                    ),
                    itemCount: dormitories.length,
                    itemBuilder: (context, index) {
                      var dorm = dormitories[index];
                      String dormId = dorm.id; // Get dormId from Document ID
                      return _buildDormitoryCard(dorm, dormId, favorites);
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
