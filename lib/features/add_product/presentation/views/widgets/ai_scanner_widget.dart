import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AiScannerWidget extends StatefulWidget {
  final OnScanComplete onScanComplete;

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
    // ... inside state
    String displayResults = _getCombinedResults(_segmentationResults);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _isScanning ? null : _pickImageAndScan,
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
                  // Placeholder
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                const Icon(Icons.check_circle_outline, color: Colors.white),
              ],
            ),
          )
        ]
      ],
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<SegmentationResult> results;
  final Size imageSize;

  BoundingBoxPainter(this.results, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (results.isEmpty) return;

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;
    
    // Maintain aspect ratio fit based on BoxFit.contain behavior
    double scale = scaleX < scaleY ? scaleX : scaleY;
    
    double dx = (size.width - imageSize.width * scale) / 2;
    double dy = (size.height - imageSize.height * scale) / 2;

    final Paint boxPaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
      
    final Paint fillPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var result in results) {
      final rect = result.boundingBox;
      
      final scaledRect = Rect.fromLTRB(
        rect.left * scale + dx,
        rect.top * scale + dy,
        rect.right * scale + dx,
        rect.bottom * scale + dy,
      );

      canvas.drawRect(scaledRect, fillPaint);
      canvas.drawRect(scaledRect, boxPaint);
      
      // Draw label background
      final RRect labelBadge = RRect.fromRectAndRadius(
        Rect.fromLTWH(scaledRect.left, scaledRect.top - 24, 120, 24),
        const Radius.circular(4)
      );
      canvas.drawRRect(labelBadge, Paint()..color = Colors.pinkAccent);
      
      // Draw text
      textPainter.text = TextSpan(
        text: ' ${result.label}',
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(scaledRect.left + 4, scaledRect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Bounding box painter ──────────────────────────────────────────────────────
class BoundingBoxPainter extends CustomPainter {
  final List<SegmentationResult> results;
  final Size imageSize;

  BoundingBoxPainter(this.results, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (results.isEmpty) return;

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double dx = (size.width - imageSize.width * scale) / 2;
    final double dy = (size.height - imageSize.height * scale) / 2;

    final boxPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var result in results) {
      final rect = result.boundingBox;
      final scaledRect = Rect.fromLTRB(
        rect.left * scale + dx,
        rect.top * scale + dy,
        rect.right * scale + dx,
        rect.bottom * scale + dy,
      );

      canvas.drawRect(scaledRect, fillPaint);
      canvas.drawRect(scaledRect, boxPaint);

      // Label badge
      final labelWidth = (result.label.length * 8.0).clamp(80.0, 200.0);
      final badge = RRect.fromRectAndRadius(
        Rect.fromLTWH(scaledRect.left, scaledRect.top - 24, labelWidth, 24),
        const Radius.circular(4),
      );
      canvas.drawRRect(badge, Paint()..color = Colors.cyanAccent);

      textPainter.text = TextSpan(
        text: ' ${result.label}',
        style: const TextStyle(
          color: Color(0xFF1E202C),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(scaledRect.left + 4, scaledRect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}