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
              const Text('ชื่อ', style: TextStyle(fontSize: 20)),
              TextFormField(
                decoration: const InputDecoration(labelText: "กรอกชื่อใหม่"),
                autofocus: true,
                validator: (String? str) {
                  if (str == '') return "กรอกชื่อใหม่";
                  return null;
                },  
              ),
              const Text('นามสกุล', style: TextStyle(fontSize: 20)),
              TextFormField(
                decoration: const InputDecoration(labelText: "กรอกนามสกุลใหม่"),
                autofocus: true,
                validator: (String? str) {
                  if (str == '') return "กรอกนามสกุลใหม่";
                  return null;
                }, 
              ),
              const Text('อีเมล', style: TextStyle(fontSize: 20)),
              TextFormField(
                decoration: const InputDecoration(labelText: "กรอกอีเมลใหม่"),
                autofocus: true,
                validator: (String? str) {
                  if (str == '') return "กรอกอีเมลใหม่";
                  return null;
                }, 
              ),
              const Text('เบอร์โทร', style: TextStyle(fontSize: 20)),
              TextFormField(
                decoration: const InputDecoration(labelText: "กรอกเบอร์โทรใหม่"),
                autofocus: true,
                validator: (String? str) {
                  if (str == '') return "กรอกเบอร์โทรใหม่";
                  return null;
                }, 
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
