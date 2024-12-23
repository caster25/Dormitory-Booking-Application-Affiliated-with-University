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
  late List<Alignment> imageAlignments;

  @override
  void initState() {
    super.initState();
    imageUrls = widget.selectedImages; // ใช้ selectedImages ที่ส่งมาจากภายนอก
    imageAlignments = List.generate(imageUrls.length, (index) => Alignment.topLeft);  // ตั้งค่าเริ่มต้นตำแหน่ง
  }

  // ฟังก์ชันลบภาพจาก Firebase
  void _deleteImage(String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      setState(() {
        int index = imageUrls.indexOf(imageUrl);
        if (index != -1) {
          imageUrls.removeAt(index);
          imageAlignments.removeAt(index);  // ลบตำแหน่งที่ตรงกับภาพ
        }
      });
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  // ฟังก์ชันปรับตำแหน่งภาพ
  void _updateImagePosition(int index, Alignment alignment) {
    if (index >= 0 && index < imageAlignments.length) {
      setState(() {
        imageAlignments[index] = alignment;
      });
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
          return Stack(
            children: [
              // ใช้ Draggable เพื่อให้สามารถลากภาพ
              Draggable<int>(
                data: index,  // เก็บดัชนีของภาพที่ลาก
                child: Align(
                  alignment: imageAlignments.isNotEmpty
                      ? imageAlignments[index]
                      : Alignment.topLeft,  // ตรวจสอบว่า imageAlignments ไม่ว่าง
                  child: Image.network(
                    widget.selectedImages[index],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                feedback: Material(  // ขณะลากภาพ
                  color: Colors.transparent,
                  child: Image.network(
                    widget.selectedImages[index],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                childWhenDragging: Container(),  // ขณะที่ภาพถูกลากไป
              ),
              // ใช้ DragTarget เพื่อให้ตำแหน่งของภาพสามารถถูกวางลงได้
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    widget.onDeleteImage(index); // เรียกฟังก์ชันลบภาพที่ส่งมาจากภายนอก
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: DragTarget<int>(
                  onAccept: (receivedIndex) {
                    setState(() {
                      imageAlignments[receivedIndex] = Alignment.bottomRight;  // ตั้งค่าตำแหน่งที่ถูกวาง
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return IconButton(
                      icon: const Icon(Icons.drag_handle, color: Colors.blue),
                      onPressed: () {
                        _updateImagePosition(index, Alignment.bottomRight);
                      },
                    );
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
