import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FeedsScreen(),
    );
  }
}

class FeedsScreen extends StatelessWidget {
  const FeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // ปิด appbar
        child: Container(), // ปิด appbar
      
      ),
      backgroundColor: const Color.fromARGB(255, 186,176,248),
      body: Stack(
        children: [
          // Container with BoxDecoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 241,229,255),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              height:
                  300, // Height to cover the AppBar and some additional space
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // จัดการวางแนวตั้งด้านล่าง
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 320, // ปรับตำแหน่งของข้อความ
            left: 16,
            right: 16,
            child: Row(
              children: [
                const Icon(Icons.collections_bookmark_outlined,
                    color: Colors.yellow), // เพิ่ม Icon ตรงนี้
                const SizedBox(width: 8), // ระยะห่างระหว่าง Icon กับ Text
                Text(
                  'แนะนำ', // ข้อความที่ต้องการแสดง
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBox('Box 1'),
                  const SizedBox(width: 16),
                  _buildBox('Box 2'),
                  const SizedBox(width: 16),
                  _buildBox('Box 3'),
                  const SizedBox(width: 16),
                  _buildBox('Box 4'),
                  const SizedBox(width: 16),
                  _buildBox('Box 5'),
                  const SizedBox(width: 16),
                  _buildBox('Box 6'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(String text) {
    return Container(
      width: 180,
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
