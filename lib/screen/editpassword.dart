import 'package:dorm_app/screen/homepage.dart';
import 'package:flutter/material.dart';

class Editpassword extends StatelessWidget {
  const Editpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขระหัสผ่าน'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Homepage()),
            (route) => false,
          ), 
          icon: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                hintText: 'รหัสปัจจุบัน',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'รหัสใหม่',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'ยืนยันรหัสผ่าน',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                suffixIcon: Icon(Icons.visibility_off),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Homepage();
                }));
              },
              child: Text('เปลี่ยนรหัสผ่าน'),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
