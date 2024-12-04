import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final Icon leadingIcon;
  final Widget nextScreen;
  final EdgeInsetsGeometry margin;
  final double elevation;

  const CardWidget({
    Key? key,
    required this.title,
    required this.leadingIcon,
    required this.nextScreen,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      margin: margin,
      child: ListTile(
        leading: leadingIcon,
        title: Text(title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        },
      ),
    );
  }

    Widget buildTextField({
    required TextEditingController controller,
    required Widget label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        label: label,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
