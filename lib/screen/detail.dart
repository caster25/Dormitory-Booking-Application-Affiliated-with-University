import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DormallDetailScreen extends StatefulWidget {
  final String dormId;

  const DormallDetailScreen({super.key, required this.dormId});

  @override
  State<DormallDetailScreen> createState() => _DormDetailScreenState();
}

class _DormDetailScreenState extends State<DormallDetailScreen> {
  late Future<Map<String, dynamic>> dormitoryData;
  late Future<List<Map<String, dynamic>>> reviewsData;
  final TextEditingController reviewController = TextEditingController();
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    dormitoryData = _fetchDormitoryData();
    reviewsData = _fetchReviewsData();
  }

  Future<Map<String, dynamic>> _fetchDormitoryData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(widget.dormId)
        .get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _fetchReviewsData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('dormId', isEqualTo: widget.dormId)
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _addReview() async {
    if (reviewController.text.isEmpty || _rating == 0) return;

    await FirebaseFirestore.instance.collection('reviews').add({
      'dormId': widget.dormId,
      'user': 'User Name', // เปลี่ยนเป็นชื่อผู้ใช้จริง
      'date': DateTime.now().toString(),
      'text': reviewController.text,
      'rating': _rating,
      'likes': 0,
      'comments': 0
    });

    await _updateDormitoryReviews();

    // Clear the text field and reset rating
    reviewController.clear();
    setState(() {
      _rating = 0;
    });
  }

  Future<void> _updateDormitoryReviews() async {
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('dormId', isEqualTo: widget.dormId)
        .get();

    int reviewCount = reviewsSnapshot.size;

    await FirebaseFirestore.instance
        .collection('dormitories')
        .doc(widget.dormId)
        .update({
      'reviewCount': reviewCount,
    });
  }

  Future<void> _bookDormitory() async {
    // Add your booking logic here
    // For example, you could navigate to a booking form or show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จองหอพัก'),
        content: const Text('คุณต้องการจองหอพักนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              // Add booking logic here
              Navigator.of(context).pop();
            },
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดหอพัก'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: dormitoryData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var dormitory = snapshot.data!;
                return Column(
                  children: [
                    // ภาพหอพัก
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(dormitory['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ชื่อหอพัก
                          Text(
                            dormitory['name'] ?? 'ไม่มีชื่อ',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // ราคา
                          Text(
                            'ราคา: ${dormitory['price']} บาท/เดือน',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          // เรทติ้ง
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating:
                                    (dormitory['rating']?.toDouble() ?? 0.0),
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                                direction: Axis.horizontal,
                              ),
                              Text('${dormitory['rating']} / 5'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // จำนวนห้องว่าง
                          Text(
                            'ห้องว่าง: ${dormitory['availableRooms']} ห้อง',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          // ปุ่มจองหอพัก
                          ElevatedButton(
                            onPressed: _bookDormitory,
                            child: const Text('จองหอพัก'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.purple, // สีของข้อความปุ่ม
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1),
                          const SizedBox(height: 16),
                          const Text(
                            'รีวิวจากผู้ใช้งาน',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          // ส่วนรีวิว
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: reviewsData,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              var reviews = snapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  var review = reviews[index];
                                  var reviewId = review['id']; // แก้ไขให้ตรงกับคอลเล็กชันรีวิว
                                  var currentLikes = review['likes'];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 241, 229, 255),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      review['user'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(review['date']),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(review['text']),
                                            const SizedBox(height: 8),
                                            RatingBarIndicator(
                                              rating:
                                                  review['rating'].toDouble(),
                                              itemBuilder: (context, index) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 20.0,
                                              direction: Axis.horizontal,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.thumb_up,
                                                          color: Colors.blue),
                                                      onPressed: () {
                                                        _likeReview(reviewId,
                                                            currentLikes);
                                                      },
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text('$currentLikes คน'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.comment,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        'ตอบกลับ (${review['comments']})'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // ช่องสำหรับเขียนรีวิวใหม่
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'เขียนรีวิว',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                RatingBar.builder(
                                  initialRating: _rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      _rating = rating;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: reviewController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    hintText: 'เขียนรีวิวของคุณ...',
                                  ),
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _addReview,
                                  child: const Text('ส่งรีวิว'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _likeReview(String reviewId, int currentLikes) async {
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .update({
      'likes': currentLikes + 1,
    });
  }
}
