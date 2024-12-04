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
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
      ),
    );
  }
}