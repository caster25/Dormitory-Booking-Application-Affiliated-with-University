import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DormDetailScreen extends StatelessWidget {
  final String dormName;
  final String imageUrl;
  final String price;
  final String description;
  final double rating;

  const DormDetailScreen({
    super.key,
    required this.dormName,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(dormName),
          backgroundColor: Colors.purple,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'รายละเอียด'),
              Tab(text: 'รีวิวหอพัก'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Dorm Detail
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ส่วนรายละเอียดหอพัก
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dormName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ราคา: $price บาท/เดือน',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow),
                            Text('$rating/5'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const Divider(thickness: 1),
                        const SizedBox(height: 16),
                        const Text(
                          'รีวิวจากผู้ใช้งาน',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ReadReviewsScreen(),
                ],
              ),
            ),
            // Tab 2: Write Review
            const WriteReviewScreen(),
          ],
        ),
      ),
    );
  }
}

// Tab 1: Read Reviews
class ReadReviewsScreen extends StatelessWidget {
  const ReadReviewsScreen({super.key});

  Future<void> _likeReview(String reviewId, int currentLikes) async {
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .update({
      'likes': currentLikes + 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var reviews = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            var review = reviews[index];
            var reviewId = review.id;
            var currentLikes = review['likes'];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 229, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['user'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                        rating: review['rating'].toDouble(),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up,
                                    color: Colors.blue),
                                onPressed: () {
                                  _likeReview(reviewId, currentLikes);
                                },
                              ),
                              const SizedBox(width: 4),
                              Text('$currentLikes คน'),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.comment, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('ตอบกลับ (${review['comments']})'),
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
    );
  }
}

// Tab 2: Write Review
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;

  Future<void> _submitReview() async {
    String reviewText = _reviewController.text;

    if (reviewText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('reviews').add({
        'user': 'User Name', 
        'date': DateTime.now().toString(),
        'text': reviewText,
        'rating': _rating,
        'likes': 0,
        'comments': 0,
      });

      _reviewController.clear();
      setState(() {
        _rating = 3.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'รีวิวหอพัก:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'เขียนรีวิว...',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}
