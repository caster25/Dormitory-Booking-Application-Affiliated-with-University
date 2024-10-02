import 'package:flutter/material.dart';

class Adminscreen extends StatelessWidget {
  const Adminscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            
          ),
          ),
      ),
    );
  }
}
