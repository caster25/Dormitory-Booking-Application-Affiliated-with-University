import 'package:flutter/material.dart';
import 'package:dorm_app/model/Dormitory.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดหอพัก ${dormitory.name}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // แสดงข้อมูลหอพักที่ส่งมา
              Text(
                'ชื่อหอพัก: ${dormitory.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('ราคา: ฿${dormitory.price}'),
              const SizedBox(height: 8),
            Text('ประเภทห้อง: ${dormitory.roomType}'),
            Text('ผู้พักอาศัย: ${dormitory.occupants} คน'),
            Text('ราคา: ${dormitory.price} บาท/เดือน'),
            Text('ค่ามัดจำ: ${dormitory.securityDeposit} บาท'),
            Text('ค่าบำรุงรักษา: ${dormitory.maintenanceFee} บาท'),
            Text('ค่ารายเดือน: ${dormitory.monthlyRent} บาท'),
            Text('ค่าบริการเฟอร์นิเจอร์: ${dormitory.furnitureFee} บาท'),
            Text('อัตราค่าไฟฟ้า: ${dormitory.electricityRate} บาทต่อหน่วย'),
            Text('อัตราค่าน้ำ: ${dormitory.waterRate} บาทต่อหน่วย'),
            Text('ห้องว่าง: ${dormitory.availableRooms} ห้อง'),
            Text('ที่อยู่: ${dormitory.address.isNotEmpty ? dormitory.address : 'ไม่มีที่อยู่'}'),
            Text('อุปกรณ์ในห้อง: ${dormitory.equipment.isNotEmpty ? dormitory.equipment : 'ไม่มีข้อมูล'}'),
            const SizedBox(height: 16),
            Text('ผู้เช่า: ${dormitory.tenants.isNotEmpty ? dormitory.tenants.join(', ') : 'ไม่มีผู้เช่า'}'),

            ],
          ),
        ),
      ),
    );
  }
}
