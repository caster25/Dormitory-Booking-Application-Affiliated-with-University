// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';

// class Details extends StatelessWidget {
//   const Details({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('รายละเอียดหอพัก'),
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Carousel แสดงภาพ
//               CarouselSlider(
//                 options: CarouselOptions(
//                   height: 200.0,
//                   enlargeCenterPage: true,
//                   aspectRatio: 16 / 9,
//                   viewportFraction: 0.8,
//                 ),
//                 items: [
//                   'assets/images/บ้านแสนสุข/master (1).jpg',
//                   'assets/images/บ้านแสนสุข/2.jpg',
//                   'assets/images/บ้านแสนสุข/3.jpg',
//                 ].map((item) {
//                   return Builder(
//                     builder: (BuildContext context) {
//                       return Container(
//                         width: MediaQuery.of(context).size.width,
//                         margin: const EdgeInsets.symmetric(horizontal: 5.0),
//                         child: Image.asset(item, fit: BoxFit.cover),
//                       );
//                     },
//                   );
//                 }).toList(),
//               ),

//               const SizedBox(height: 16.0),

//               // ข้อมูลรายละเอียดหอพัก
//               const Text(
//                 'ประเภทหอพัก: หอพักหญิง\n'
//                 'ประเภทห้อง: ปรับอากาศ ห้องพักขนาด 28 ตารางเมตร\n'
//                 'จำนวนคนพัก: 1-2 คนต่อห้อง\n'
//                 'อัตราค่าห้องพัก: 2 ห้องแรก 15,000 บาท/ห้อง/เทอม (ห้องที่มีอยู่ได้ 1 หรือ 2 คน)\n'
//                 'ค่าบำรุงหอ: 150 บาท/คน/เดือน\n'
//                 'ค่าไฟหน่วยละ: 7 บาท\n'
//                 'ค่าน้ำหน่วยละ: 7 บาท ขั้นต่ำ 60 บาท/เดือน\n'
//                 'ค่าเฟอร์นิเจอร์เพิ่มเติม: 3,000 บาท/ห้อง\n'
//                 'ค่าประกันความเสียหาย: 200 บาท/คน/เดือน\n',
//                 style: TextStyle(fontSize: 16.0),
//               ),

//               const SizedBox(height: 16.0),

//               // อุปกรณ์ที่มีในห้องพัก
//               const Text(
//                 'อุปกรณ์ที่มีในห้องพัก:',
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8.0),
//               const Text(
//                 '1. เตียง 3.5 ฟุต 2 เตียง พร้อมฟูก\n'
//                 '2. โต๊ะทำงาน 3 มุมขนาด 1.80 เมตร\n'
//                 '3. ตู้หนังสือ\n'
//                 '4. โทรทัศน์ 32 นิ้ว 1 เครื่อง\n'
//                 '5. เครื่องทำน้ำอุ่น เครื่องปรับอากาศ โต๊ะกินข้าว โซฟาแบบแบ่ง ห้องพร้อมบิลต์อินและห้องน้ำในตัว\n',
//                 style: TextStyle(fontSize: 16.0),
//               ),

//               const SizedBox(height: 16.0),

//               // ตารางข้อมูลหอพัก
//               const Text(
//                 'หมายเลขห้องพัก:',
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 8.0),

//               // ตารางแสดงหมายเลขห้องพัก
//               Table(
//                 border: TableBorder.all(color: Colors.black),
//                 columnWidths: const {
//                   0: FlexColumnWidth(2),
//                   1: FlexColumnWidth(2),
//                   2: FlexColumnWidth(6),
//                 },
//                 children: const [
//                   TableRow(children: [
//                     Text('ประเภทผู้พัก',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     Text('ประเภทห้อง',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     Text('หมายเลขห้องพัก',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ]),
//                   TableRow(children: [
//                     Text('หอหญิง'),
//                     Text('พัดลม'),
//                     Text(''),
//                   ]),
//                   TableRow(children: [
//                     Text(''),
//                     Text('ห้องปรับอากาศ'),
//                     Text(''),
//                   ]),
//                   TableRow(children: [
//                     Text('หอชาย'),
//                     Text('พัดลม'),
//                     Text('104,105,106,107,108,109,110,111,112,201,202,203,204,207,208,209,210,211,212'),
//                   ]),
//                   TableRow(children: [
//                     Text(''),
//                     Text('ห้องปรับอากาศ'),
//                     Text(''),
//                   ]),
//                   TableRow(children: [
//                     Text('รวม'),
//                     Text('พัดลม'),
//                     Text(''),
//                   ]),
//                   TableRow(children: [
//                     Text(''),
//                     Text('ห้องปรับอากาศ'),
//                     Text(''),
//                   ]),
//                 ],
//               ),

//               const SizedBox(height: 16.0),

//               // ปุ่มการดำเนินการ
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       // Action when the "จองเลย" button is pressed
//                     },
//                     child: const Text('จองเลย'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Action when the "แก้ไขข้อมูล" button is pressed
//                     },
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.purple),
//                     child: const Text('แก้ไขข้อมูล'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
