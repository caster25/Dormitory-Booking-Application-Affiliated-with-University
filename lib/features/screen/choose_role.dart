
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:dorm_app/features/screen/owner/screen/auth/register_owner.dart';
import 'package:dorm_app/features/screen/user/screen/register_user.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'เลือกประเภทการใช้งาน', context: context),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const RegisterScreen();
                        },
                      ));
                    },
                    icon: const Icon(Icons.person),
                    label: TextWidget.buildText( text: 
                      'ผู้ใช้งานทั่วไป', fontSize: 18
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 250,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const RegisterownerScreen();
                        },
                      ));
                    },
                    icon: const Icon(Icons.business),
                    label: TextWidget.buildText( text: 
                      'ผู้ให้บริการหอพัก', fontSize: 18
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
