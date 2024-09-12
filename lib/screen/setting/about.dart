import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เกี่ยวกับเรา'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เกี่ยวกับแอปของเรา',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'แอปของเราถูกสร้างขึ้นเพื่อช่วยนักศึกษาในการจองหอพักในมหาวิทยาลัยโดยง่ายและสะดวก เรามีความมุ่งมั่นในการให้บริการที่ดีที่สุดแก่ผู้ใช้',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'วิสัยทัศน์และพันธกิจ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'วิสัยทัศน์ของเราคือการทำให้การจองหอพักเป็นเรื่องง่ายและสะดวกสำหรับนักศึกษา โดยการให้บริการที่มีคุณภาพและตอบสนองความต้องการของผู้ใช้',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'ฟีเจอร์หลักของแอป',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• ค้นหาหอพักที่ตรงกับความต้องการ\n'
              '• การจองหอพักออนไลน์\n'
              '• การจัดการข้อมูลหอพัก\n'
              '• การติดต่อผู้ดูแลหอพักได้โดยตรง',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'ทีมงานของเรา',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ทีมพัฒนาแอปของเราประกอบด้วยนักพัฒนาที่มีประสบการณ์และทีมออกแบบที่ทุ่มเทในการสร้างประสบการณ์ที่ดีที่สุดสำหรับผู้ใช้',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'ติดต่อเรา',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• อีเมล: support@dormapp.com\n'
              '• เบอร์โทร: 123-456-7890\n'
              '• ติดตามเราบนโซเชียลมีเดีย: Facebook, Twitter, Instagram',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
