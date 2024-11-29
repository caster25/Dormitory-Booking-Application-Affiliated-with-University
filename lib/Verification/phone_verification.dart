// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';


class EmailOtpVerificationScreen extends StatefulWidget {
  const EmailOtpVerificationScreen({super.key});

  @override
  _EmailOtpVerificationScreenState createState() =>
      _EmailOtpVerificationScreenState();
}

class _EmailOtpVerificationScreenState
    extends State<EmailOtpVerificationScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool otpSent = false;
  bool isLoading = false;
  String generatedOtp = '';

  // ฟังก์ชันสร้าง OTP
  String generateOtp() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString(); // สร้างรหัส 6 หลัก
  }

  // ฟังก์ชันส่ง OTP ไปยังอีเมล
  Future<void> sendOtpToEmail(String email, String otp) async {
    String username = 'teerapt.phi@ku.th'; // อีเมลของคุณ
    String password = 'test1234'; // รหัสผ่านอีเมลของคุณ

    final smtpServer = gmail(username, password); // สร้างเซิร์ฟเวอร์ SMTP

    final message = Message() // สร้างข้อความ
      ..from = Address(username, 'Your App Name')
      ..recipients.add(email) // ผู้รับ
      ..subject = 'รหัสยืนยัน OTP' // หัวข้ออีเมล
      ..text = 'รหัส OTP ของคุณคือ $otp'; // ข้อความในอีเมล

    try {
      await send(message, smtpServer); // ส่งอีเมล
      print('ส่ง OTP ไปยังอีเมลสำเร็จ');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP ถูกส่งไปยังอีเมลแล้ว')),
      );
    } catch (e) {
      print('ส่ง OTP ล้มเหลว: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่ง OTP ล้มเหลว: $e')),
      );
    }
  }

  // ฟังก์ชันในการส่ง OTP
  void sendOtp() async {
    setState(() {
      isLoading = true;
    });

    generatedOtp = generateOtp(); // สร้าง OTP ใหม่
    String email = _emailController.text.trim();

    try {
      // บันทึกรหัส OTP ใน Firestore หรือฐานข้อมูล
      await FirebaseFirestore.instance.collection('otps').doc(email).set({
        'otp': generatedOtp,
        'timestamp': Timestamp.now(),
      });

      await sendOtpToEmail(email, generatedOtp); // ส่ง OTP ไปยังอีเมล

      setState(() {
        otpSent = true;
        isLoading = false;
      });
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // ฟังก์ชันในการตรวจสอบ OTP
  void verifyOtp() async {
    String enteredOtp = _otpController.text.trim();
    String email = _emailController.text.trim();

    if (enteredOtp == generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยืนยัน OTP สำเร็จ')),
      );
      // ดำเนินการต่อไป เช่น ลงทะเบียนผู้ใช้ใน Firebase
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัส OTP ไม่ถูกต้อง')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ยืนยัน OTP ผ่านอีเมล')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'อีเมล'),
            ),
            const SizedBox(height: 20),
            if (otpSent)
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'รหัส OTP'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: otpSent ? verifyOtp : sendOtp,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(otpSent ? 'ยืนยัน OTP' : 'ส่ง OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
