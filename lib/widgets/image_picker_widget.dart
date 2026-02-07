// lib/widgets/image_picker_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final void Function(File selectedImage) onImageSelected;
  final bool shouldAutoOpen;

  const ImagePickerWidget({super.key, required this.onImageSelected, this.shouldAutoOpen = false});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Check if we should open automatically
    if (widget.shouldAutoOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPicker(context);
      });
    }
  }
  //Function to show the Bottom Sheet (Gallery vs Camera)
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Photo Gallery"),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Function to actually pick the image
  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);

      setState(() {
        _selectedImage = imageFile;
      });

      // --- CRITICAL STEP ---
      // Call the parent's function to give them the image
      widget.onImageSelected(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(

      onTap: () {
        // if(_selectedImage == null)
          _showPicker(context);
      },
      child: Container(
        height: 250,
        width: width * 0.9,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: _selectedImage == null
            ?
        // If No Image: Show Icon
        Icon(
          Icons.add_a_photo_outlined,
          size: width * 0.2,
          color: Colors.grey[600],
        )
            :
        // If Image Selected: Show Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}