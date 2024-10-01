import 'package:dorm_app/screen/user/screen/homepage.dart';
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
              const Text('ชื่อโปรไฟล์', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "ชื่อโปรไฟล์",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (String? str) {
                  if (str == '') return "กรอกชื่อโปรไฟล์ใหม่";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('ชื่อ-นามสกุล', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "กรอกชื่อ-นามสกุล",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (String? str) {
                  if (str == '') return "กรอกชื่อ-นามสกุลใหม่";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('อีเมล', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "กรอกอีเมลใหม่",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (String? str) {
                  if (str == '') return "กรอกอีเมลใหม่";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('เบอร์โทร', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "กรอกเบอร์โทรใหม่",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
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
                      // Save data and return to Homepage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Homepage()),
                        (route) => false,
                      );
                    },
                    child: const Text('บันทึก', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Cancel and return to Homepage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Homepage()),
                        (route) =>
                            false, // ลบทุกเส้นทางในเครื่องหมายความเห็นเพื่อไม่ให้กลับมายังหน้าแก้ไขผู้ใช้
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('ยกเลิก', style: TextStyle(fontSize: 18)),
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
