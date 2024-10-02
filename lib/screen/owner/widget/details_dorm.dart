import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/model/Dormitory.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Details extends StatelessWidget {
  final Dormitory dormitory;
  final String dormitoryId;

  const Details(
      {super.key, required this.dormitory, required this.dormitoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดหอพัก ${dormitory.name}'),
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dormitories')
            .doc(dormitoryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('ไม่มีข้อมูลหอพัก'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carousel แสดงภาพ
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                    ),
                    items:
                        (data['imageUrl'] as List<dynamic>? ?? []).map((item) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Image.network(item, fit: BoxFit.cover),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16.0),

                  // ข้อมูลรายละเอียดหอพัก
                  Text(
                    'ประเภทหอพัก: ${data['residentType'] ?? 'ไม่มีข้อมูล'}\n'
                    'ประเภทห้อง: ${data['roomType'] ?? 'ไม่มีข้อมูล'}\n'
                    'จำนวนคนพัก: ${data['occupancy'] ?? 'ไม่มีข้อมูล'} คนต่อห้อง\n'
                    'อัตราค่าห้องพัก: ${data['roomRate']?.toString() ?? 'ไม่มีข้อมูล'} บาท/ห้อง\n'
                    'ค่าบำรุงหอ: ${data['maintenanceFee']?.toString() ?? 'ไม่มีข้อมูล'} บาท/เดือน\n'
                    'ค่าไฟหน่วยละ: ${data['electricityRate']?.toString() ?? 'ไม่มีข้อมูล'} บาท\n'
                    'ค่าน้ำหน่วยละ: ${data['waterRate']?.toString() ?? 'ไม่มีข้อมูล'} บาท\n'
                    'ค่าเฟอร์นิเจอร์เพิ่มเติม: ${data['furnitureFee']?.toString() ?? 'ไม่มีข้อมูล'} บาท\n'
                    'ค่าประกันความเสียหาย: ${data['damageDeposit']?.toString() ?? 'ไม่มีข้อมูล'} บาท/เดือน\n',
                    style: const TextStyle(fontSize: 16.0),
                  ),

                  const SizedBox(height: 16.0),

                  // อุปกรณ์ที่มีในห้องพัก
                  const Text(
                    'อุปกรณ์ที่มีในห้องพัก:',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    (data['roomFacilities'] != null
                        ? (data['roomFacilities'] as List<dynamic>)
                            .map((item) => '• $item')
                            .join('\n')
                        : 'ไม่มีข้อมูล'),
                    style: const TextStyle(fontSize: 16.0),
                  ),

                  const SizedBox(height: 16.0),

                  // ตารางข้อมูลหอพัก
                  const Text(
                    'หมายเลขห้องพัก:',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8.0),

                  // ตารางแสดงหมายเลขห้องพัก
                  Table(
                    border: TableBorder.all(color: Colors.black),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(6),
                    },
                    children: const [
                      TableRow(children: [
                        Text('ประเภทผู้พัก',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('ประเภทห้อง',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('หมายเลขห้องพัก',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                      TableRow(children: [
                        Text('หอหญิง'),
                        Text('พัดลม'),
                        Text(''),
                      ]),
                      TableRow(children: [
                        Text(''),
                        Text('ห้องปรับอากาศ'),
                        Text(''),
                      ]),
                      TableRow(children: [
                        Text('หอชาย'),
                        Text('พัดลม'),
                        Text(
                            '104,105,106,107,108,109,110,111,112,201,202,203,204,207,208,209,210,211,212'),
                      ]),
                      TableRow(children: [
                        Text(''),
                        Text('ห้องปรับอากาศ'),
                        Text(''),
                      ]),
                      TableRow(children: [
                        Text('รวม'),
                        Text('พัดลม'),
                        Text(''),
                      ]),
                      TableRow(children: [
                        Text(''),
                        Text('ห้องปรับอากาศ'),
                        Text(''),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // ปุ่มการดำเนินการ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Action when the "จองเลย" button is pressed
                        },
                        child: const Text('จองเลย'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Action when the "แก้ไขข้อมูล" button is pressed
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple),
                        child: const Text('แก้ไขข้อมูล'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
