import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xspire_dashboard/core/services/food_detection_service.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';

enum AiScannerMode { classification, segmentation }

typedef OnScanComplete = void Function(File image, dynamic result);

class AiScannerWidget extends StatefulWidget {
  final OnScanComplete onScanComplete;
  final AiScannerMode mode;

  const AiScannerWidget({
    super.key, 
    required this.onScanComplete, 
    this.mode = AiScannerMode.classification,
  });

  @override
  State<AiScannerWidget> createState() => _AiScannerWidgetState();
}

class _AiScannerWidgetState extends State<AiScannerWidget> {
  File? _image;
  bool _isLoading = false;
  String? _detectedFood;
  final FoodDetectionService _foodService = getIt<FoodDetectionService>();

  Future<void> _pickImageAndScan() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = true;
          _detectedFood = "Analyzing image...";
        });

        // Use the SMART DETECTION (TFLite + Gemini Fallback)
        dynamic result;
        if (widget.mode == AiScannerMode.classification) {
          final classificationResult = await _foodService.smartFoodDetect(_image!);
          result = classificationResult?.label ?? "Food item";
        } else {
          result = await _foodService.detectItems(_image!);
        }

        setState(() {
          _isLoading = false;
          if (widget.mode == AiScannerMode.classification) {
            _detectedFood = result as String;
          } else {
            final Map<String, int> items = result as Map<String, int>;
            _detectedFood = items.entries.map((e) => "${e.value}x ${e.key}").join(", ");
          }
        });
        
        // Call the callback with the results
        widget.onScanComplete(_image!, result);
      }
    } catch (e) {
      debugPrint("Scanner Error: $e");
      setState(() {
        _isLoading = false;
        _detectedFood = "Error detecting food";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          onTap: _isLoading ? null : _pickImageAndScan,
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
                                  'Tap to Scan Food',
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Hybrid AI (TFLite + Gemini)',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                    )
                  else ...[
                    Image.file(_image!, fit: BoxFit.contain),
                    if (_isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.cyanAccent),
                        ),
                      ),
                  ],
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
              gradient: LinearGradient(
                colors: _isLoading 
                    ? [const Color(0xFF2C3E50), const Color(0xFF2C3E50)]
                    : [const Color(0xFF2C3E50), const Color(0xFF3498DB)],
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
                Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.check_circle, 
                  color: Colors.white
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isLoading 
                        ? (widget.mode == AiScannerMode.classification ? 'AI is Thinking...' : 'Segmenting Items...') 
                        : 'Detected: $_detectedFood',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ]
      ],
    );
  }
}