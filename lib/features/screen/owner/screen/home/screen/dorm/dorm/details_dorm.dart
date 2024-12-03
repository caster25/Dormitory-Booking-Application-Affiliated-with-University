import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/model/Userprofile.dart';
import 'package:flutter/material.dart';
import 'package:dorm_app/model/Dormitory.dart';
import 'package:intl/intl.dart';

class Details extends StatelessWidget {
  final Dormitory dormitory;
    final String dormitoryId;

  const Details({super.key, required this.dormitory, required this.dormitoryId});

  // ดึงข้อมูลผู้เช่าจาก Firestore โดยใช้ tenantIds
  Future<List<UserProfile>> fetchTenants() async {
    if (dormitory.tenants.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('iduser', whereIn: dormitory.tenants)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final formatNumber = NumberFormat('#,##0');
    const primaryColor = Color.fromARGB(255, 153, 85, 240);
    const secondaryColor = Colors.black;

    return Scaffold(
      appBar: buildAppBar(title: 'รายละเอียดหอพัก ${dormitory.name}', context: context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card แสดงข้อมูลหอพัก
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ชื่อหอพัก: ${dormitory.name}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor, // เปลี่ยนสีตัวอักษร
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ประเภทห้อง: ${dormitory.roomType}',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ผู้พักอาศัย: ${dormitory.occupants} คน',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ราคา: ${formatNumber.format(dormitory.price)} บาท/เทอม',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const Divider(
                          height: 20,
                          thickness: 1,
                          color: primaryColor), // เปลี่ยนสี Divider
                      Text(
                        'ค่ามัดจำ: ${formatNumber.format(dormitory.securityDeposit)} บาท',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ค่าบำรุงรักษา: ${formatNumber.format(dormitory.maintenanceFee)} บาท',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ค่ารายเดือน: ${formatNumber.format(dormitory.monthlyRent)} บาท',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const Divider(
                          height: 20,
                          thickness: 1,
                          color: primaryColor), // เปลี่ยนสี Divider
                      Text(
                        'ค่าบริการเฟอร์นิเจอร์: ${formatNumber.format(dormitory.furnitureFee)} บาท',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'อัตราค่าไฟฟ้า: ${dormitory.electricityRate} บาทต่อหน่วย',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'อัตราค่าน้ำ: ${dormitory.waterRate} บาทต่อหน่วย',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const Divider(
                          height: 20,
                          thickness: 1,
                          color: Color.fromARGB(
                              255, 143, 192, 233)), // เปลี่ยนสี Divider
                      Text(
                        'ห้องว่าง: ${dormitory.availableRooms} ห้อง',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ที่อยู่: ${dormitory.address.isNotEmpty ? dormitory.address : 'ไม่มีที่อยู่'}',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'อุปกรณ์ในห้อง: ${dormitory.equipment.isNotEmpty ? dormitory.equipment : 'ไม่มีข้อมูล'}',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
                      ),
                      const Divider(
                          height: 20,
                          thickness: 1,
                          color: Color.fromARGB(
                              255, 60, 137, 199)), // เปลี่ยนสี Divider

                      // FutureBuilder สำหรับดึงข้อมูลผู้เช่า
                      FutureBuilder<List<UserProfile>>(
                        future: fetchTenants(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text(
                                'เกิดข้อผิดพลาดในการดึงข้อมูลผู้เช่า');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('ไม่มีผู้เช่า');
                          } else {
                            final tenantCount = snapshot.data!.length;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ผู้เช่า ($tenantCount คน):',
                                  style: const TextStyle(
                                      fontSize: 18, color: secondaryColor),
                                ),
                                for (var tenant in snapshot.data!)
                                  Text(
                                    '${tenant.fullname} ',
                                    style: const TextStyle(
                                        fontSize: 18, color: secondaryColor),
                                  ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
