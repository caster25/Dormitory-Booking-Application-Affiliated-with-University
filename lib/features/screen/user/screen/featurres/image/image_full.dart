import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ตั้งพื้นหลังเป็นสีดำเพื่อเน้นภาพ
      appBar: AppBar(
        backgroundColor: Colors.black, // สีพื้นหลังของ AppBar
        elevation: 0, // ลบเงาของ AppBar
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // ปิดหน้าเต็มจอ
          },
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // ให้เลื่อนดูภาพได้
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0, // กำหนดการซูมสูงสุด
          child: AspectRatio(
            aspectRatio: 1, // รักษาสัดส่วนของภาพ
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain, // ปรับภาพให้พอดีกับหน้าจอ
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const Center(
                  child: CircularProgressIndicator(), // แสดง Loading ขณะโหลดภาพ
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'ไม่สามารถโหลดภาพได้',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
