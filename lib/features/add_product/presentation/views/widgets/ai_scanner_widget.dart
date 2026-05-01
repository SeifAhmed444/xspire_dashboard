import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:xspire_dashboard/core/services/segmentation_service.dart';
import 'package:xspire_dashboard/core/services/food_detection_service.dart';

class AiScannerWidget extends StatefulWidget {
  final Function(File image, String detectedFood) onScanComplete;

  const AiScannerWidget({super.key, required this.onScanComplete});

  @override
  State<AiScannerWidget> createState() => _AiScannerWidgetState();
}

class _AiScannerWidgetState extends State<AiScannerWidget> with SingleTickerProviderStateMixin {
  File? _image;
  bool _isScanning = false;
  List<SegmentationResult> _segmentationResults = [];
  String? _detectedFood;
  Size? _imageSize;
  
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  final SegmentationService _segmentationService = SegmentationService();
  final FoodDetectionService _foodDetectionService = FoodDetectionService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _segmentationService.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndScan() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isScanning = true;
        _segmentationResults = [];
        _detectedFood = null;
      });
      _animationController.forward();

      final decodedImage = await decodeImageFromList(await _image!.readAsBytes());
      setState(() {
        _imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      });
      
      await _performScan(_image!);
    }
  }

  Future<void> _performScan(File imageFile) async {
    List<SegmentationResult> updatedResults = [];
    Set<String> allDetectedUnique = {};

    try {
      // 1. Decode image for cropping
      final imageBytes = await imageFile.readAsBytes();
      img.Image? fullImage = img.decodeImage(imageBytes);
      if (fullImage == null) throw Exception("Failed to decode image");

      // 2. Classify whole image as fallback/main
      final mainPrediction = await _foodDetectionService.detectFoodFromImage(fullImage);
      if (mainPrediction != null && mainPrediction.score > 0.05) {
        allDetectedUnique.add(mainPrediction.label);
      }
      
      // 3. ML Kit Object Detection (For precise bounding boxes)
      try {
        final mlKitObjects = await _segmentationService.detectObjects(imageFile);
        
        for (var obj in mlKitObjects) {
          final box = obj.boundingBox;
          int left = box.left.toInt().clamp(0, fullImage.width - 1);
          int top = box.top.toInt().clamp(0, fullImage.height - 1);
          int width = box.width.toInt().clamp(1, fullImage.width - left);
          int height = box.height.toInt().clamp(1, fullImage.height - top);
          
          img.Image crop = img.copyCrop(fullImage, x: left, y: top, width: width, height: height);
          final result = await _foodDetectionService.detectFoodFromImage(crop);
          
          String finalLabel;
          // Low threshold (0.02) because ML Kit confirmed there is a real object here
          if (result != null && result.score > 0.02) {
            allDetectedUnique.add(result.label);
            finalLabel = result.label;
          } else {
            // If the custom model doesn't know it as an Egyptian dish, use ML Kit's safe generic label
            finalLabel = obj.label;
          }

          updatedResults.add(SegmentationResult(
            boundingBox: box, 
            label: finalLabel
          ));
        }

        // 4. Fallback: If ML Kit found absolutely ZERO boxes (happens when one giant plate fills the screen, like Koshary)
        // We manually draw one big box covering the center of the image so the user isn't left without any boxes!
        if (mlKitObjects.isEmpty && mainPrediction != null && mainPrediction.score > 0.05) {
          double w = fullImage.width.toDouble();
          double h = fullImage.height.toDouble();
          
          updatedResults.add(SegmentationResult(
            boundingBox: Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), // 80% of the center screen
            label: mainPrediction.label
          ));
        }
      } catch (e) {
        debugPrint("ML Kit error: $e");
      }
    } catch (e) {
      debugPrint("Full detection error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _segmentationResults = updatedResults;
        
        if (allDetectedUnique.isEmpty) {
          _detectedFood = "Food Item Recognized";
        } else {
          _detectedFood = allDetectedUnique.join(", ");
        }
        _isScanning = false;
      });
      _animationController.stop();

      widget.onScanComplete(_image!, _detectedFood!);
    }
  }

  String _getCombinedResults(List<SegmentationResult> results) {
    if (results.isEmpty) return "No Food Detected";
    final uniqueLabels = results.map((e) => e.label).toSet().toList();
    if (uniqueLabels.length == 1) return uniqueLabels.first;
    return uniqueLabels.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    // ... inside state
    String displayResults = _getCombinedResults(_segmentationResults);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ... (rest of the UI uses displayResults)
        GestureDetector(
          onTap: _isScanning ? null : _pickImageAndScan,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1E202C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isScanning ? Colors.cyanAccent : Colors.white12,
                width: _isScanning ? 2 : 1,
              ),
              boxShadow: _isScanning ? [
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
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner, size: 60, color: Colors.cyanAccent),
                          SizedBox(height: 16),
                          Text(
                            'Tap to Scan Image',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Powered by Advanced AI Segmentation',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Image.file(_image!, fit: BoxFit.contain),
                    
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanAnimation.value * 280,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent,
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                    if (!_isScanning && _segmentationResults.isNotEmpty && _imageSize != null)
                      CustomPaint(
                        painter: BoundingBoxPainter(_segmentationResults, _imageSize!),
                      ),
                  ]
                ],
              ),
            ),
          ),
        ),
        if (!_isScanning && _detectedFood != null) ...[
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
                const Icon(Icons.auto_awesome, color: Colors.yellowAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detected: $_detectedFood',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
