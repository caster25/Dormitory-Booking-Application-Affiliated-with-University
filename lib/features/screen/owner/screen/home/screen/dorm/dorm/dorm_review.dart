import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DormReview extends StatefulWidget {
  final Map<String, dynamic> dormitory;
  final String dormitoryId;

  const DormReview({
    Key? key,
    required this.dormitory,
    required this.dormitoryId,
  }) : super(key: key);

  @override
  _DormReviewState createState() => _DormReviewState();
}

class _DormReviewState extends State<DormReview> {
  late Future<Map<String, String>> users;

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
  }

  Future<Map<String, String>> fetchUsers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    Map<String, String> usersMap = {};

    for (var doc in querySnapshot.docs) {
      usersMap[doc.id] = doc['username']; // สมมุติว่ามีฟิลด์ username
    }

    return usersMap;
  }

  Stream<List<Map<String, dynamic>>> fetchReviews() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('dormitoryId', isEqualTo: widget.dormitoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'userId': doc['userId'],
          'rating': doc['rating'].toString(),
          'reviewText': doc['reviewText'],
          'timestamp': doc['timestamp'].toDate().toString(),
        };
      }).toList();
    });
  }

  void _viewFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'หน้ารายละเอียดหอพัก', context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.buildText(text: 
                        'ชื่อหอพัก: ${widget.dormitory['name']}',fontSize: 18, isBold: true
                      ),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 'ที่อยู่: ${widget.dormitory['address']}',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 
                          'จำนวนห้องว่าง: ${widget.dormitory['availableRooms']}',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 'ประเภทหอพัก: ${widget.dormitory['dormType']}',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 
                          'ราคาห้อง: ${widget.dormitory['price']} บาทต่อเดือน',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 
                          'ค่าไฟต่อหน่วย: ${widget.dormitory['electricityRate']} บาท',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 
                          'ค่าอัตราน้ำต่อหน่วย: ${widget.dormitory['waterRate']} บาท',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 
                          'เงินมัดจำ: ${widget.dormitory['securityDeposit']} บาท',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 'อุปกรณ์ในห้อง: ${widget.dormitory['equipment']}',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 'ผู้เข้าพัก: ${widget.dormitory['occupants']} คน',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 'กฏของหอพัก: ${widget.dormitory['rule']} คน',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 
                          'จำนวนห้องทั้งหมด: ${widget.dormitory['totalRooms']}',fontSize: 16),
                      const SizedBox(height: 10),
                      TextWidget.buildText(text: 'รูปภาพ:',fontSize: 18),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.dormitory['imageUrl'].length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _viewFullImage(
                                    widget.dormitory['imageUrl'][index]);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    widget.dormitory['imageUrl'][index],
                                    fit: BoxFit.cover,
                                    width: 150, // กำหนดขนาดที่ต้องการ
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.buildText(text: 
                        'รีวิวหอพัก: คะแนน ${widget.dormitory['rating'].toDouble().toStringAsFixed(1).replaceAll('.0', '')}',fontSize: 18
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<Map<String, String>>(
                        future: users,
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (userSnapshot.hasError) {
                            return Text(
                                'เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้: ${userSnapshot.error}');
                          }

                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream: fetchReviews(),
                            builder: (context, reviewSnapshot) {
                              if (reviewSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (reviewSnapshot.hasError) {
                                return Text(
                                    'เกิดข้อผิดพลาด: ${reviewSnapshot.error}');
                              } else if (!reviewSnapshot.hasData ||
                                  reviewSnapshot.data!.isEmpty) {
                                return const Text('ยังไม่มีรีวิว');
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviewSnapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final review = reviewSnapshot.data![index];
                                  final userName =
                                      userSnapshot.data![review['userId']] ??
                                          'ไม่ทราบชื่อ';

                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(top: 10),
                                    child: ListTile(
                                      title: TextWidget.buildText(text: 'ผู้ใช้: $userName',fontSize: 16),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                           TextWidget.buildText(text: 'คะแนน: ${review['rating']}'),
                                           TextWidget.buildText(text: 
                                              'รีวิว: ${review['reviewText']}'),
                                           TextWidget.buildText(text: 
                                              'วันที่: ${review['timestamp']}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
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

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.primary01,
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
