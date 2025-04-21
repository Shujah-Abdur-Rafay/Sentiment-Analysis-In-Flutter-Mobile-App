import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSelector extends StatelessWidget {
  final Function(ImageSource) onImageSelected;

  const ImageSourceSelector({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200, // Adjust height as needed
      child: Column(
        children: [
          const Text(
            'Select Image Source',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            onTap: () {
              Navigator.of(context).pop(); // Close the bottom sheet
              onImageSelected(ImageSource.camera); // Call the passed function
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.of(context).pop(); // Close the bottom sheet
              onImageSelected(ImageSource.gallery); // Call the passed function
            },
          ),
        ],
      ),
    );
  }
}
