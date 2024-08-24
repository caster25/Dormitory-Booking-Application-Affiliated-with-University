import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 241, 229, 255),
              child: const TabBar(
                indicatorColor: Colors.purple,
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'อ่านรีวิว'),
                  Tab(text: 'รีวิวหอพัก'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3, // Update with actual item count
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 229, 255),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzmmPFs5rDiVo_R3ivU_J_-CaQGyvJj-ADNQ&s'
                                        ),
                                    ),
                                    SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'User Name',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text('14 ม.ค. 2567'),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text('หอพักดี ประเมินมากกก...'),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.thumb_up, color: Colors.blue),
                                        SizedBox(width: 4),
                                        Text('30 คน'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.comment, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text('ตอบกลับ (15)'),
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
                  ),
                  const Center(
                    child: Text('รีวิวหอพัก'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
