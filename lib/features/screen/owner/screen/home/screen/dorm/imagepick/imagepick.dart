import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerRow extends StatefulWidget {
  final List<File> images;
  final VoidCallback onPickImages;
  final ValueChanged<List<File>> onUpdateImages;

  const ImagePickerRow({
    super.key,
    required this.images,
    required this.onPickImages,
    required this.onUpdateImages,
  });

  @override
  _ImagePickerRowState createState() => _ImagePickerRowState();
}

class _ImagePickerRowState extends State<ImagePickerRow> {
  // ฟังก์ชันในการลบรูป
  void _removeImage(int index) {
    setState(() {
      widget.images.removeAt(index);
    });
    widget.onUpdateImages(widget.images); // Update list ใน parent
  }

  // ฟังก์ชันในการจัดเรียงรูป
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = widget.images.removeAt(oldIndex);
      widget.images.insert(newIndex, item);
    });
    widget.onUpdateImages(widget.images); // Update list ใน parent
  }

  // ฟังก์ชันเพื่อดูรูปขนาดใหญ่
  void _viewFullImage(BuildContext context, File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: widget.onPickImages,
              child: const Text('เลือกรูปภาพ'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.images
                      .asMap()
                      .map((index, image) => MapEntry(
                            index,
                            GestureDetector(
                              onTap: () => _viewFullImage(context, image),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.file(
                                      image,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ))
                      .values
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        ReorderableListView(
          shrinkWrap: true,
          onReorder: _onReorder,
          children: widget.images
              .asMap()
              .map((index, image) => MapEntry(
                    index,
                    ListTile(
                      key: ValueKey(index),
                      title: Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
              .values
              .toList(),
        ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File image;

  const FullScreenImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // สามารถเลื่อนดูภาพได้
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(image),
        ),
      ),
    );
  }
}
