import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // สีหลักและสีรอง
    const primaryColor = Color.fromARGB(255, 153, 85, 240);
    const secondaryColor = Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('เกี่ยวกับเรา'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวข้อ "เกี่ยวกับแอปของเรา"
            _buildSectionTitle('เกี่ยวกับแอปของเรา', Icons.info, primaryColor),
            const SizedBox(height: 8),
            _buildCard(
              'แอปของเราถูกสร้างขึ้นเพื่อช่วยนักศึกษาในการจองหอพักในมหาวิทยาลัยโดยง่ายและสะดวก เรามีความมุ่งมั่นในการให้บริการที่ดีที่สุดแก่ผู้ใช้',
            ),

            const SizedBox(height: 16),

            // ส่วนหัวข้อ "วิสัยทัศน์และพันธกิจ"
            _buildSectionTitle('วิสัยทัศน์และพันธกิจ', Icons.crisis_alert, primaryColor),
            const SizedBox(height: 8),
            _buildCard(
              'วิสัยทัศน์ของเราคือการทำให้การจองหอพักเป็นเรื่องง่ายและสะดวกสำหรับนักศึกษา โดยการให้บริการที่มีคุณภาพและตอบสนองความต้องการของผู้ใช้',
            ),

            const SizedBox(height: 16),

            // ส่วนหัวข้อ "ฟีเจอร์หลักของแอป"
            _buildSectionTitle('ฟีเจอร์หลักของแอป', Icons.star, primaryColor),
            const SizedBox(height: 8),
            _buildCard(
              '• ค้นหาหอพักที่ตรงกับความต้องการ\n'
              '• การจองหอพักออนไลน์\n'
              '• การจัดการข้อมูลหอพัก\n'
              '• การติดต่อผู้ดูแลหอพักได้โดยตรง',
            ),

            const SizedBox(height: 16),

            // ส่วนหัวข้อ "ทีมงานของเรา"
            _buildSectionTitle('ทีมงานของเรา', Icons.people, primaryColor),
            const SizedBox(height: 8),
            _buildCard(
              'ทีมพัฒนาแอปของเราประกอบด้วยนักพัฒนาที่มีประสบการณ์และทีมออกแบบที่ทุ่มเทในการสร้างประสบการณ์ที่ดีที่สุดสำหรับผู้ใช้',
            ),

            const SizedBox(height: 16),

            // ส่วนหัวข้อ "ติดต่อเรา"
            _buildSectionTitle('ติดต่อเรา', Icons.contact_mail, primaryColor),
            const SizedBox(height: 8),
            _buildCard(
              '• อีเมล: support@dormapp.com\n'
              '• เบอร์โทร: 123-456-7890\n'
              '• ติดตามเราบนโซเชียลมีเดีย: Facebook, Twitter, Instagram',
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้างหัวข้อแต่ละส่วน พร้อมไอคอน
  Widget _buildSectionTitle(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Widget สำหรับสร้างเนื้อหาแต่ละส่วนภายในการ์ด
  Widget _buildCard(String content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
