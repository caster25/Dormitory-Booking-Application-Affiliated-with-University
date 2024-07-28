import 'package:dorm_app/screen/detaildorm.dart';
import 'package:flutter/material.dart';

class Bookdorm extends StatelessWidget {
  const Bookdorm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('จองหอพักตอนนี้'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Detaildorm();
                      }));
                    },
                    label: Text(
                      'จองหอพัก',
                      style: TextStyle(fontSize: 20),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
