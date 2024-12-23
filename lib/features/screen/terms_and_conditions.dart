import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/login.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          _hasReachedEnd = true;
        });
      }
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('สำเร็จ'),
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(width: 10),
              Text('คุณได้ลงทะเบียนบัญชีสำเร็จ'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'เงื่อนไขและข้อตกลง', context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.buildText(
                        text: 'เงื่อนไขและข้อตกลงการใช้บริการ',
                        fontSize: 24,
                        isBold: true),
                    SizedBox(height: 20),
                    Divider(thickness: 2),
                    TextWidget.buildText(
                        text: '1. ข้อมูลหอพักที่ถูกต้อง',
                        fontSize: 20,
                        isBold: true),
                    SizedBox(height: 10),
                    TextWidget.buildText(
                        text:
                            '  1.1 ผู้ใช้จะต้องให้ข้อมูลเกี่ยวกับหอพักที่ถูกต้องและเป็นปัจจุบัน เช่น ชื่อหอพัก ที่อยู่หอพัก หมายเลขติดต่อ และเอกสารหลักฐานที่ยืนยันว่าผู้ใช้เป็นผู้ดูแลหอพักหรือได้รับอนุญาตในการจัดการหอพักนั้นๆ \n'
                            '  1.2 ผู้ใช้ต้องรับรองว่าข้อมูลทั้งหมดที่ให้เป็นความจริงและไม่ได้มีเจตนาหลอกลวงหรือปกปิดข้อมูลที่สำคัญ',
                        fontSize: 20,
                        wrapText: true),
                    SizedBox(height: 20),
                    TextWidget.buildText(
                        text: '2. การตรวจสอบข้อมูล',
                        fontSize: 20,
                        isBold: true),
                    SizedBox(height: 10),
                    TextWidget.buildText(
                        text:
                            '   2.1 บริษัทมีสิทธิ์ในการตรวจสอบความถูกต้องของข้อมูลที่ผู้ใช้ให้มา โดยอาจมีการตรวจสอบเอกสารหรือการติดต่อสอบถามเพิ่มเติมกับหน่วยงานที่เกี่ยวข้อง\n'
                            '   2.2 หากพบว่ามีการให้ข้อมูลที่ไม่ถูกต้องหรือเป็นเท็จ บริษัทมีสิทธิ์ในการระงับบัญชีหอพักของผู้ใช้และดำเนินการตามกฏหมายที่เกี่ยวข้อง',
                        fontSize: 20,
                        wrapText: true),
                    SizedBox(height: 20),
                    TextWidget.buildText(
                        text: '3. ข้อกำหนดทางกฎหมาย',
                        fontSize: 20,
                        isBold: true),
                    SizedBox(height: 10),
                    TextWidget.buildText(
                        text:
                            '   3.1 ผู้ใช้จะต้องปฏิบัติตามกฎหมายและข้อบังคับที่เกี่ยวข้องกับการจัดการหอพัก รวมถึงกฎหมายท้องถิ่นที่เกี่ยวกับการประกอบกิจการหอพัก \n'
                            '   3.2 หากพบว่าผู้ใช้ให้ข้อมูลเท็จหรือหลอกลวง บริษัทมีสิทธิ์ที่จะดำเนินการทางกฎหมายเพื่อฟ้องร้องผู้ใช้ในฐานความผิดการให้ข้อมูลอันเป็นเท็จต่อเจ้าพนักงานตามมาตรา 137 ประมวลกฎหมายอาญา ซึ่งมีโทษจำคุกไม่เกินหกเดือน หรือปรับไม่เกินหนึ่งหมื่นบาท หรือทั้งจำทั้งปรับ \n'
                            '   3.3 นอกจากนี้ บริษัทอาจดำเนินคดีเพื่อเรียกร้องค่าเสียหายที่เกิดขึ้นจากการกระทำดังกล่าว',
                        fontSize: 20,
                        wrapText: true),
                    SizedBox(height: 20),
                    TextWidget.buildText(
                        text: '4. การยกเลิกหรือระงับบัญชี',
                        fontSize: 20,
                        isBold: true),
                    SizedBox(height: 10),
                    TextWidget.buildText(
                        text:
                            '   4.1 บริษัทสงวนสิทธิ์ในการยกเลิกหรือระงับบัญชีหอพักของผู้ใช้ทันทีหากพบว่าผู้ใช้ละเมิดเงื่อนไขและข้อกำหนดเหล่านี้\n'
                            '   4.2 การยกเลิกหรือระงับบัญชีจะส่งผลให้ผู้ใช้ไม่สามารถเข้าถึงบริการที่เกี่ยวข้องทั้งหมด และข้อมูลที่เกี่ยวข้องกับบัญชีจะถูกระงับหรือถูกลบตามนโยบายของบริษัท',
                        fontSize: 20,
                        wrapText: true),
                    SizedBox(height: 20),
                    TextWidget.buildText(
                        text: '5. การยอมรับเงื่อนไข',
                        fontSize: 20,
                        isBold: true),
                    SizedBox(height: 10),
                    TextWidget.buildText(
                        text:
                            '   5.1 การสมัครเปิดบัญชีหอพักถือว่าผู้ใช้ได้อ่านและยอมรับเงื่อนไขและข้อกำหนดทั้งหมดที่ระบุไว้ในเอกสารนี้',
                        fontSize: 20,
                        wrapText: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false); // ส่งค่ายกเลิกกลับ
                  },
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasReachedEnd ? Colors.greenAccent : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  onPressed: _hasReachedEnd
                      ? () {
                          Navigator.pop(context, true);
                        }
                      : null,
                  child: const Text(
                    'ยอมรับ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
