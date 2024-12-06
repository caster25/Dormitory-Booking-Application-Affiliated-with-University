import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ImagePickerRowd extends StatefulWidget {
  final List<String> selectedImages; // ให้เป็น List<String> แทน dynamic
  final Function(int) onDeleteImage;

  const ImagePickerRowd({
    Key? key,
    required this.selectedImages,
    required this.onDeleteImage,
  }) : super(key: key);

  @override
  _ImagePickerRowdState createState() => _ImagePickerRowdState();
}

class _ImagePickerRowdState extends State<ImagePickerRowd> {
  late List<String> imageUrls;

  @override
  void initState() {
    super.initState();
    imageUrls = widget.selectedImages; // ใช้ selectedImages ที่ส่งมาจากภายนอก
  }

  // ฟังก์ชันลบภาพจาก Firebase
  void _deleteImage(String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      setState(() {
        imageUrls.remove(imageUrl);
      });
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedImages.length,
        itemBuilder: (context, index) {
          // แสดงภาพจาก URL
          return Stack(
            children: [
              Image.network(
                widget.selectedImages[index],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    widget.onDeleteImage(
                        index); // เรียกฟังก์ชันลบภาพที่ส่งมาจากภายนอก
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
