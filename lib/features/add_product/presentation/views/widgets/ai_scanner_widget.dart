import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AiScannerWidget extends StatefulWidget {
  final Function(File image, String detectedFood) onScanComplete;

  const AiScannerWidget({super.key, required this.onScanComplete});

  @override
  State<AiScannerWidget> createState() => _AiScannerWidgetState();
}

class _AiScannerWidgetState extends State<AiScannerWidget> {
  File? _image;
  bool _isLoading = false;
  String? _detectedFood;



  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _detectedFood = "Image Selected";
        });
        
        // Call the callback with the selected image
        widget.onScanComplete(_image!, _detectedFood ?? "Image Selected");
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _isLoading ? null : _pickImage,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1E202C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isLoading ? Colors.cyanAccent : Colors.white12,
                width: _isLoading ? 2 : 1,
              ),
              boxShadow: _isLoading ? [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_image == null)
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.cyanAccent)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.document_scanner, size: 60, color: Colors.cyanAccent),
                                SizedBox(height: 16),
                                Text(
                                  'Tap to Select Image',
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pick an image from gallery',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                    )
                  else
                    Image.file(_image!, fit: BoxFit.contain),
                ],
              ),
            ),
          ),
        ),
        if (_detectedFood != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Image: $_detectedFood',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
