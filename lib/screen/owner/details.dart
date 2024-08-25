import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(details());
}

class details extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('รายละเอียดหอพัก'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: [
                    'assets/images/บ้านแสนสุข/master (1).jpg',
                    'assets/images/บ้านแสนสุข/2.jpg',
                    'assets/images/บ้านแสนสุข/3.jpg',
                  ].map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Image.asset(item, fit: BoxFit.cover),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                Text(
                  'ประเภทหอพัก: หอพักหญิง\n'
                  'ประเภทห้อง: ปรับอากาศ ห้องพักขนาด 28 ตารางเมตร\n'
                  'จำนวนคนพัก: 1-2 คนต่อห้อง\n'
                  'อัตราค่าห้องพัก: 2 ห้องแรก 15,000 บาท/ห้อง/เทอม (ห้องที่มีอยู่ได้ 1 หรือ 2 คน)\n'
                  'ค่าบำรุงหอ: 150 บาท/คน/เดือน\n'
                  'ค่าไฟหน่วยละ: 7 บาท\n'
                  'ค่าน้ำหน่วยละ: 7 บาท ขั้นต่ำ 60 บาท/เดือน\n'
                  'ค่าเฟอร์นิเจอร์เพิ่มเติม: 3,000 บาท/ห้อง\n'
                  'ค่าประกันความเสียหาย: 200 บาท/คน/เดือน\n',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'อุปกรณ์ที่มีในห้องพัก:\n'
                  '1. เตียง 3.5 ฟุต 2 เตียง พร้อมฟูก\n'
                  '2. โต๊ะทำงาน 3 มุมขนาด 1.80 เมตร\n'
                  '3. ตู้หนังสือ\n'
                  '4. โทรทัศน์ 32 นิ้ว 1 เครื่อง\n'
                  '5. เครื่องทำน้ำอุ่น เครื่องปรับอากาศ โต๊ะกินข้าว โซฟาแบบแบ่ง\n'
                  'ห้องพร้อมบิลต์อินและห้องน้ำในตัว ห้องว่างมีจำนวนจำกัด\n',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'ข้อมูลตาราง:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Table(
                  border: TableBorder.all(color: Colors.black),
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('ชั้น', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('ห้องพักที่ว่าง', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('1'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('301, 302, 303'),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('2'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('201, 202, 203'),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('3'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('101, 102, 103'),
                      ),
                    ]),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Action when the "จองเลย" button is pressed
                      },
                      child: Text('จองเลย'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Action when the "แก้ไขข้อมูล" button is pressed
                      },
                      child: Text('แก้ไขข้อมูล'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
