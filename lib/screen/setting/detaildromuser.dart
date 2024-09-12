import 'package:flutter/material.dart';

class DormitoryDetailsScreen extends StatelessWidget {
  const DormitoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final TextEditingController _currentDormController =
        TextEditingController();
    // ignore: no_leading_underscores_for_local_identifiers
    final TextEditingController _previousDormController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดหอพักของคุณ'),
        backgroundColor: const Color.fromARGB(255, 153, 85, 240),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'หอพักปัจจุบัน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currentDormController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ชื่อหอพักปัจจุบัน',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'หอพักที่เคยพัก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _previousDormController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ชื่อหอพักที่เคยพัก',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String currentDorm = _currentDormController.text;
                String previousDorm = _previousDormController.text;

                print('Current Dorm: $currentDorm');
                print('Previous Dorm: $previousDorm');
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}