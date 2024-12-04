import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: TextWidget.buildSection18(text),
      style: ElevatedButton.styleFrom(
      ),
    );
  }
}