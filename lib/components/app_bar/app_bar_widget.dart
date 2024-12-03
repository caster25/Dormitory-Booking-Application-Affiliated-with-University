import 'package:dorm_app/features/screen/owner/screen/home/screen/home_owner.dart';
import 'package:dorm_app/features/screen/owner/screen/home/screen/widget_nitification/notification_owner.dart';
import 'package:dorm_app/features/screen/user/screen/homepage.dart';
import 'package:dorm_app/features/screen/user/widgets/notification_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

late User _currentUser;

// กำหนดสีและธีมเริ่มต้น
const Color defaultBackgroundColor = Color.fromARGB(255, 153, 85, 240);
const IconThemeData defaultIconTheme = IconThemeData(color: Colors.black);

AppBar buildAppBar({
  required String title,
  required BuildContext context,
  List<Widget>? actions,
  Color backgroundColor = defaultBackgroundColor,
  VoidCallback? onBackPressed,
}) {
  return AppBar(
    backgroundColor: backgroundColor,
    title: Text(title),
    iconTheme: defaultIconTheme,
    leading: onBackPressed != null
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed,
          )
        : null,
    actions: actions,
  );
}

AppBar getAppBarOwnerProfile({
  required BuildContext context,
  required String title,
}) {
  return buildAppBar(
    title: title,
    context: context,
    onBackPressed: () => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Ownerhome()),
      (route) => false,
    ),
  );
}
AppBar getAppBarUserProfile({
  required BuildContext context,
  required String title,
}) {
  return buildAppBar(
    title: title,
    context: context,
    onBackPressed: () => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Homepage()),
      (route) => false,
    ),
  );
}

AppBar getAppBar({
  required int index,
  required BuildContext context,
  required dynamic currentUser,
  required bool isOwner,
}) {
  return buildAppBar(
    title: getTitle(index, isOwner: isOwner),
    context: context,
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => isOwner
                  ? NotificationOwnerScreen(user: currentUser)
                  : NotificationUserScreen(user: currentUser),
            ),
          );
        },
      ),
    ],
  );
}

String getTitle(int index, {required bool isOwner}) {
  const userTitles = ['หน้าแรก', 'หอพัก', '', 'ข้อมูลส่วนตัว'];
  const ownerTitles = ['หน้าแรก', 'รายการหอพัก', 'ข้อมูลส่วนตัว', ''];

  final titles = isOwner ? ownerTitles : userTitles;
  return 
    titles[index >= 0 && index < titles.length ? index : titles.length - 1];
}

AppBar buildCustomAppBar({
  required String title,
  required BuildContext context, 
  required VoidCallback onSave,
  Color backgroundColor = defaultBackgroundColor,
}) {
  return buildAppBar(
    title: title,
    context: context,
    backgroundColor: backgroundColor,
    actions: [
      IconButton(
        icon: const Icon(Icons.save),
        onPressed: onSave,
      ),
    ],
  );
}

AppBar buildAddDormitoryAppBar({
  required BuildContext context,
  required VoidCallback onSubmit,
  String title = 'เพิ่มหอพัก',
  Color backgroundColor = defaultBackgroundColor,
}) {
  return buildAppBar(
    title: title,
    context: context,
    backgroundColor: backgroundColor,
    actions: [
      IconButton(
        icon: const Icon(Icons.save),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('ยืนยันการเพิ่มข้อมูล'),
                content: const Text('คุณแน่ใจหรือไม่ว่าจะเพิ่มข้อมูลนี้?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ยกเลิก'),
                  ),
                  TextButton(
                    onPressed: () {
                      onSubmit();
                      Navigator.of(context).pop();
                    },
                    child: const Text('ยืนยัน'),
                  ),
                ],
              );
            },
          );
        },
      ),
    ],
  );
}
