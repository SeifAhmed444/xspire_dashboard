import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ImageField extends StatefulWidget {
  const ImageField({super.key, required this.onFileChange});
  final ValueChanged<File?> onFileChange;

  @override
  State<ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<ImageField> {
  // Moved inside state — no longer global/shared between instances
  bool _isLoading = false;
  File? _fileImage;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: _isLoading,
      child: GestureDetector(
        onTap: () async {
          setState(() => _isLoading = true);
          try {
            await _pickImage();
          } on Exception catch (_) {
            // handle silently
          } finally {
            setState(() => _isLoading = false);
          }
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: _fileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_fileImage!),
                    )
                  : const Icon(Icons.image_outlined, size: 200),
            ),
            Visibility(
              visible: _fileImage != null,
              child: IconButton(
                onPressed: () {
                  setState(() => _fileImage = null);
                  widget.onFileChange(null);
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      widget.onFileChange(null);
      return;
    }

    setState(() => _fileImage = File(image.path));
    widget.onFileChange(_fileImage);
  }
}
