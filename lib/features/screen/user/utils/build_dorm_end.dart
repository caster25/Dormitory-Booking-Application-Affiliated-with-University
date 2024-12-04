import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/user/screen/detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CardDorm extends StatelessWidget {
  CardDorm ({super.key});
  List<String> favorites = []; // สร้างรายการ favorites ใน state

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dormitories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Accessing the dormitory data from Firestore
        final dormitories = snapshot.data!.docs;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.65,
          ),
          itemCount: dormitories.length,
          itemBuilder: (context, index) {
            var dorm = dormitories[index];
            Map<String, dynamic> dormData = dorm.data() as Map<String, dynamic>;
            String dormId = dorm.id;

            // ส่ง context หลักเข้าไป
            return _buildDormitoryCard(dorm, dormId, context);
          },
        );
      },
    );
  }

  Widget _buildDormitoryCard(DocumentSnapshot dorm, String dormId, BuildContext parentContext) {
    bool isFavorite =
        favorites.contains(dormId); // Check if the dormitory is a favorite
    List<dynamic> images = dorm['imageUrl'];
    final formatNumber = NumberFormat('#,##0');

    return InkWell(
      onTap: () {
        Navigator.push(parentContext, MaterialPageRoute(builder: (context) {
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
        elevation: 9, // Add shadow to the card
        child: LayoutBuilder(
          builder: (context, constraints) {

            return Column(
              mainAxisSize:
                  MainAxisSize.max, // Use appropriate size for the Column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Container(
                    height: 111,
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
                              TextWidget.buildSubSectionBold14(
                                '${dorm['name']} (${dorm['dormType']} ${dorm['roomType']})',
                              ),
                              const SizedBox(height: 5),
                              TextWidget.buildSubSection12(
                                'จำนวนห้องที่ว่าง ${dorm['availableRooms']} ห้อง',
                              ),
                              const SizedBox(height: 5),
                              TextWidget.buildSubSection12(
                                'จำนวนห้องทั้งหมด ${dorm['totalRooms']} ห้อง',
                              ),
                              const SizedBox(height: 5),
                              TextWidget.buildSubSection12(
                                'ราคา: ${formatNumber.format(dorm['price'])} บาท',
                              ),
                              const SizedBox(height: 5),
                              TextWidget.buildSubSection12(
                                dorm['rating'] != null && dorm['rating'] > 0
                                    ? 'คะแนน ${dorm['rating'] % 1 == 0 ? dorm['rating'].toStringAsFixed(0) : dorm['rating'].toStringAsFixed(1)}/5'
                                    : 'ยังไม่มีการรีวิว',
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
}
