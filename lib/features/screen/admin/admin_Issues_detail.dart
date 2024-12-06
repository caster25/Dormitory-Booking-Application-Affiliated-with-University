import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorm_app/components/app_bar/app_bar_widget.dart';
import 'package:dorm_app/components/text_widget/text_wiget.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AdminIssueDetailScreen extends StatelessWidget {
  final DocumentSnapshot issueData;

  const AdminIssueDetailScreen({required this.issueData, super.key});

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = List<String>.from(issueData['images'] ?? []);

    return Scaffold(
      appBar: buildAppBar(title: 'Issue Details', context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.buildText(text: 
                'Issue: ${issueData['issue']}',
              ),
              const SizedBox(height: 10),
              TextWidget.buildText(text: 
                'Description: ${issueData['description']}',
              ),
              const SizedBox(height: 10),
              TextWidget.buildText(text: 
                'Submitted by: ${issueData['fullname']} (${issueData['username']})',
              ),
              const SizedBox(height: 10),
              TextWidget.buildText(text: 
                'Submitted by: ${issueData['role']} ',
              ),
              const SizedBox(height: 10),
              TextWidget.buildText(text: 
                'User ID: ${issueData['userId']}',
              ),
              const SizedBox(height: 10),
              TextWidget.buildText(text: 
                'Submitted on: ${issueData['timestamp'].toDate()}',
              ),
              const SizedBox(height: 20),
              TextWidget.buildText(text: 'Attached Images:'),
              const SizedBox(height: 10),
              // Display images
              if (imageUrls.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  children: List.generate(imageUrls.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to full image view
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewer(images: imageUrls, initialIndex: index),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('Error loading image'));
                          },
                        ),
                      ),
                    );
                  }),
                )
              else
                const Text('No images attached.', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewer({required this.images, required this.initialIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'Image Viewer', context: context),
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
