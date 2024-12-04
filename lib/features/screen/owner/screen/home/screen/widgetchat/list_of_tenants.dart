// import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
// import 'package:dorm_app/components/text_widget/text_wiget.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ListOfTenants extends StatelessWidget {
//   final String dormitoryId;

//   // ignore: use_super_parameters
//   const ListOfTenants({Key? key, required this.dormitoryId}) : super(key: key);

//   Future<List<Map<String, dynamic>>> _fetchTenants() async {
//     // ดึงข้อมูลหอพัก
//     final dormitorySnapshot = await FirebaseFirestore.instance
//         .collection('dormitories')
//         .doc(dormitoryId)
//         .get();

//     final dormitoryData = dormitorySnapshot.data();

//     // ตรวจสอบว่ามีข้อมูลหอพักและฟิลด์ tenants หรือไม่
//     if (dormitoryData == null || dormitoryData['tenants'] == null) {
//       return [];
//     }

//     List<dynamic> tenants = dormitoryData['tenants'];

//     List<Map<String, dynamic>> tenantsList = [];
//     for (String tenantId in tenants) {
//       // ดึงข้อมูลของผู้เช่าจาก Firestore
//       final userSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(tenantId)
//           .get();

//       if (userSnapshot.exists) {
//         Map<String, dynamic> userData =
//             userSnapshot.data() as Map<String, dynamic>;

//         // ตรวจสอบค่า chatRoomId และ chatGroupId
//         String? chatRoomId = userData['chatRoomId'] != null
//             ? (userData['chatRoomId'] as List<dynamic>).isNotEmpty
//                 ? userData['chatRoomId'][0]
//                 : null
//             : null; // แชทติดต่อเจ้าของหอ
//         String? chatGroupId = userData['chatGroupId'] != null
//             ? (userData['chatGroupId'] as List<dynamic>).isNotEmpty
//                 ? userData['chatGroupId'][0]
//                 : null
//             : null; // แชทกลุ่ม

//         // เพิ่มข้อมูลผู้เช่าและ chatRoomId, chatGroupId ลงในรายการ
//         tenantsList.add({
//           'id': tenantId,
//           'username': userData['username'], // ชื่อผู้ใช้
//           'email': userData['email'], // อีเมลผู้ใช้
//           'chatRoomId': chatRoomId,
//           'chatGroupId': chatGroupId,
//         });
//       }
//     }
//     return tenantsList;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAppBar(title: 'รายการผู้เช่า', context: context),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchTenants(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('ไม่มีผู้เช่าในหอพักนี้'));
//           } else {
//             final tenants = snapshot.data!;
//             return ListView.builder(
//               itemCount: tenants.length,
//               itemBuilder: (context, index) {
//                 final tenant = tenants[index];
//                 return ListTile(
//                   title: TextWidget.buildSubSectionBold16(tenant['username'] ?? 'ไม่มีชื่อ'),
//                   subtitle: TextWidget.buildSubSectionBold16('อีเมล: ${tenant['email'] ?? 'ไม่มีข้อมูล'}\n'
//                       'ChatRoom ID: ${tenant['chatRoomId'] ?? 'ไม่มีข้อมูล'}\n'
//                       'ChatGroup ID: ${tenant['chatGroupId'] ?? 'ไม่มีข้อมูล'}'),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
