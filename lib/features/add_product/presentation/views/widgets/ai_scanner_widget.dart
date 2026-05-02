import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:xspire_dashboard/core/services/segmentation_service.dart';
import 'package:xspire_dashboard/core/services/food_detection_service.dart';

/// A single detected food item with its name and count (number of bounding boxes).
class DetectedFoodItem {
  final String name;
  int count;

  DetectedFoodItem({required this.name, this.count = 1});

  @override
  String toString() => '$name x$count';
}

/// Callback fired when scanning is done.
/// [image]         – the picked image file.
/// [detectedItems] – list of [DetectedFoodItem] (name + count).
typedef OnScanComplete = void Function(
  File image,
  List<DetectedFoodItem> detectedItems,
);

class AiScannerWidget extends StatefulWidget {
  final OnScanComplete onScanComplete;

  const AiScannerWidget({super.key, required this.onScanComplete});

  @override
  State<AiScannerWidget> createState() => _AiScannerWidgetState();
}

class _AiScannerWidgetState extends State<AiScannerWidget>
    with SingleTickerProviderStateMixin {
  File? _image;
  bool _isScanning = false;
  List<SegmentationResult> _segmentationResults = [];
  List<DetectedFoodItem> _detectedItems = [];
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
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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

  // ── Pick & scan ────────────────────────────────────────────────────────────
  Future<void> _pickImageAndScan() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isScanning = true;
      _segmentationResults = [];
      _detectedItems = [];
    });
    _animationController.forward();

    final decodedImage =
        await decodeImageFromList(await _image!.readAsBytes());
    setState(() {
      _imageSize =
          Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    });

    await _performScan(_image!);
  }

  // ── Core scan logic ────────────────────────────────────────────────────────
  Future<void> _performScan(File imageFile) async {
    // label → count map
    final Map<String, int> labelCountMap = {};
    final List<SegmentationResult> updatedResults = [];

    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? fullImage = img.decodeImage(imageBytes);
      if (fullImage == null) throw Exception('Failed to decode image');

      // 1. Classify whole image as fallback / primary signal
      final mainPrediction =
          await _foodDetectionService.detectFoodFromImage(fullImage);
      if (mainPrediction != null) {
        labelCountMap[mainPrediction.label] =
            (labelCountMap[mainPrediction.label] ?? 0) + 1;
      }

      // 2. ML Kit bounding-box detection → crop each box → classify
      try {
        final mlKitObjects =
            await _segmentationService.detectObjects(imageFile);

        for (var obj in mlKitObjects) {
          final box = obj.boundingBox;
          final left = box.left.toInt().clamp(0, fullImage.width - 1);
          final top = box.top.toInt().clamp(0, fullImage.height - 1);
          final width =
              box.width.toInt().clamp(1, fullImage.width - left);
          final height =
              box.height.toInt().clamp(1, fullImage.height - top);

          final crop = img.copyCrop(fullImage,
              x: left, y: top, width: width, height: height);
          final result =
              await _foodDetectionService.detectFoodFromImage(crop);

          String finalLabel;
          if (result != null && !result.label.toLowerCase().contains('food item')) {
            finalLabel = result.label;
          } else if (obj.label != "Food item") {
            finalLabel = obj.label;
          } else if (mainPrediction != null) {
            // If crop classification failed, use the main image classification as a hint
            finalLabel = mainPrediction.label;
          } else {
            finalLabel = obj.label;
          }

          labelCountMap[finalLabel] =
              (labelCountMap[finalLabel] ?? 0) + 1;

          updatedResults.add(SegmentationResult(
            boundingBox: box,
            label: finalLabel,
          ));
        }

        // 3. Fallback: no ML Kit boxes → draw one big box
        if (mlKitObjects.isEmpty &&
            mainPrediction != null) {
          final w = fullImage.width.toDouble();
          final h = fullImage.height.toDouble();
          updatedResults.add(SegmentationResult(
            boundingBox:
                Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8),
            label: mainPrediction.label,
          ));
        }
      } catch (e) {
        debugPrint('ML Kit error: $e');
      }
    } catch (e) {
      debugPrint('Full detection error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Build DetectedFoodItem list from the count map
    final detectedItems = labelCountMap.entries
        .map((e) => DetectedFoodItem(name: e.key, count: e.value))
        .toList();

    // If nothing found, add a placeholder
    if (detectedItems.isEmpty) {
      detectedItems.add(DetectedFoodItem(name: 'Food Item', count: 1));
    }

    setState(() {
      _segmentationResults = updatedResults;
      _detectedItems = detectedItems;
      _isScanning = false;
    });
    _animationController.stop();

    widget.onScanComplete(_image!, detectedItems);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Scanner viewport ────────────────────────────────────────────────
        GestureDetector(
          onTap: _isScanning ? null : _pickImageAndScan,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1E202C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    _isScanning ? Colors.cyanAccent : Colors.white12,
                width: _isScanning ? 2 : 1,
              ),
              boxShadow: _isScanning
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : [
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
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner,
                              size: 60, color: Colors.cyanAccent),
                          SizedBox(height: 16),
                          Text(
                            'Tap to Scan Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Powered by Advanced AI Segmentation',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Image
                    Image.file(_image!, fit: BoxFit.contain),

                    // Scanning beam
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
                              decoration: const BoxDecoration(
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

                    // Bounding boxes
                    if (!_isScanning &&
                        _segmentationResults.isNotEmpty &&
                        _imageSize != null)
                      CustomPaint(
                        painter: BoundingBoxPainter(
                            _segmentationResults, _imageSize!),
                      ),

                    // Re-scan button (bottom right)
                    if (!_isScanning && _image != null)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _pickImageAndScan,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh,
                                    color: Colors.cyanAccent, size: 14),
                                SizedBox(width: 4),
                                Text('Re-scan',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── Scanning indicator ──────────────────────────────────────────────
        if (_isScanning) ...[
          const SizedBox(height: 16),
          const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.cyanAccent,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'AI is analyzing the image...',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
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