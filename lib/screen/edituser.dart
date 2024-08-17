import 'package:dorm_app/screen/homepage.dart';
import 'package:flutter/material.dart';

class EditUser extends StatelessWidget {
  const EditUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลส่วนตัว'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('อีเมล', style: TextStyle(fontSize: 20)),
              TextFormField(
                initialValue: 'user@example.com', // ค่าที่เริ่มต้นของอีเมล
              ),
              const SizedBox(height: 15),
              const Text('เบอร์โทรศัพท์', style: TextStyle(fontSize: 20)),
              TextFormField(
                initialValue: '123-456-7890', // ค่าที่เริ่มต้นของเบอร์โทรศัพท์
              ),
              const SizedBox(height: 15),
              const Text('ชื่อผู้ใช้', style: TextStyle(fontSize: 20)),
              TextFormField(
                initialValue: 'username123', // ค่าที่เริ่มต้นของชื่อผู้ใช้
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // บันทึกข้อมูลและกลับไปยังหน้า Homepage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) =>  const Homepage()), // กลับไปยังหน้า Homepage
                        (route) => false, // ลบทุกเส้นทางในเครื่องหมายความเห็นเพื่อไม่ให้กลับมายังหน้าแก้ไขผู้ใช้
                      );
                    },
                    child: const Text('บันทึก', style: TextStyle(fontSize: 20)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // ยกเลิกการแก้ไขและกลับไปยังหน้า Homepage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) =>  const Homepage()), // กลับไปยังหน้า Homepage
                        (route) => false, // ลบทุกเส้นทางในเครื่องหมายความเห็นเพื่อไม่ให้กลับมายังหน้าแก้ไขผู้ใช้
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('ยกเลิก', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
