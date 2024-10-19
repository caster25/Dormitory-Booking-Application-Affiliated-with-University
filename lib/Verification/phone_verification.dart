import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool otpSent = false;
  String? verificationId;
  bool isLoading = false;

  String formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+66${phoneNumber.substring(1)}'; // สำหรับหมายเลขประเทศไทย
    }
    return phoneNumber;
  }

  void verifyPhoneNumber() async {
    setState(() {
      isLoading = true;
    });

    String phoneNumber = formatPhoneNumber(_phoneController.text.trim());

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          print('ยืนยันตัวตนสำเร็จ!');
        } catch (e) {
          print('เกิดข้อผิดพลาด: ${e.toString()}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
          );
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        String message = e.code == 'invalid-phone-number'
            ? 'หมายเลขโทรศัพท์ไม่ถูกต้อง'
            : 'การยืนยันล้มเหลว: ${e.message}';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        print('การยืนยันล้มเหลว: ${e.message}');
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          otpSent = true;
          this.verificationId = verificationId;
        });
        print('OTP ถูกส่งไปยังหมายเลข: $phoneNumber');
        setState(() {
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('หมดเวลาการดึง OTP อัตโนมัติ');
        setState(() {
          otpSent = false;
          isLoading = false;
        });
      },
    );
  }

  void verifyOtp() async {
    if (verificationId != null && _otpController.text.isNotEmpty) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: _otpController.text.trim(),
      );

      try {
        await FirebaseAuth.instance.signInWithCredential(credential);
        print('ยืนยัน OTP สำเร็จ!');
      } on FirebaseAuthException catch (_, e) {
        print('เกิดข้อผิดพลาดในการยืนยัน OTP: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP ไม่ถูกต้อง กรุณาลองใหม่')),
        );
      }
    } else {
      print('กรุณากรอก OTP ที่ถูกต้อง');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ยืนยันตัวตนด้วย OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              const CircularProgressIndicator(), // แสดง Loading
            if (!otpSent && !isLoading) // แสดงฟิลด์กรอกเบอร์โทร หากยังไม่ได้ส่ง OTP
              Column(
                children: [
                  TextField(
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: 'หมายเลขโทรศัพท์'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      verifyPhoneNumber();
                    },
                    child: const Text('ส่ง OTP'),
                  ),
                ],
              ),
            if (otpSent && !isLoading) // หาก OTP ถูกส่งแล้ว แสดงฟิลด์กรอก OTP
              Column(
                children: [
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: 'กรอก OTP'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      verifyOtp(); // ยืนยัน OTP
                    },
                    child: const Text('ยืนยัน OTP'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
