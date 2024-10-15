import 'package:flutter/material.dart';
import 'package:dorm_app/model/Dormitory.dart';
import 'package:intl/intl.dart';

class Details extends StatelessWidget {
  final Dormitory dormitory;
  final String dormitoryId;

  const Details({
    super.key,
    required this.dormitory,
    required this.dormitoryId,
  });

  @override
  Widget build(BuildContext context) {
    final formatNumber = NumberFormat('#,##0');
    const primaryColor = Color.fromARGB(255, 153, 85, 240);
    const secondaryColor = Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดหอพัก ${dormitory.name}'),
        backgroundColor: primaryColor,
      ),
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
                          color: Color.fromARGB(255, 143, 192, 233)), // เปลี่ยนสี Divider
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
                          color: Color.fromARGB(255, 60, 137, 199)), // เปลี่ยนสี Divider
                      Text(
                        'ผู้เช่า: ${dormitory.tenants.isNotEmpty ? dormitory.tenants.join(', ') : 'ไม่มีผู้เช่า'}',
                        style: const TextStyle(
                            fontSize: 18, color: secondaryColor),
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
