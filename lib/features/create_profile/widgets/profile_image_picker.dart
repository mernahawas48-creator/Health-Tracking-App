import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditrack/themes/appcolors.dart';

class ProfileImagePicker extends StatefulWidget {
  final File? image;
  final Function(File) onImageSelected;

  const ProfileImagePicker({
    super.key,
    this.image,
    required this.onImageSelected,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      widget.onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Appcolors.Primary.withValues(alpha: 0.1),
            backgroundImage: widget.image != null
                ? FileImage(widget.image!)
                : null,
            child: widget.image == null
                ? Icon(Icons.person, size: 50, color: Appcolors.Primary)
                : null,
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Appcolors.Primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
