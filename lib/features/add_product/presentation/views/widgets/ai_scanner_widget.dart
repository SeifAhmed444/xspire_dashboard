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
  String? _statusMessage;
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
          _statusMessage = "Analyzing image...";
        });

        // Small delay to show the "Analyzing" state for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        dynamic result;
        if (widget.mode == AiScannerMode.classification) {
          setState(() => _statusMessage = "Identifying dish...");
          result = await _foodService.detectFood(_image!);
        } else {
          setState(() => _statusMessage = "Segmenting items...");
          result = await _foodService.detectItems(_image!);
        }

        setState(() {
          _isLoading = false;
          if (widget.mode == AiScannerMode.classification) {
            final res = result as FoodClassificationResult?;
            _statusMessage = res != null ? "Detected: ${res.label}" : "Food item";
          } else {
            final Map<String, FoodClassificationResult> items = 
                result as Map<String, FoodClassificationResult>;
            if (items.isEmpty) {
              _statusMessage = "No items detected";
            } else {
              final first = items.values.first.label;
              _statusMessage = items.length > 1 
                  ? "Found $first + ${items.length - 1} more" 
                  : "Detected: $first";
            }
          }
        });
        
        widget.onScanComplete(_image!, result);
      }
    } catch (e) {
      debugPrint("Scanner Error: $e");
      setState(() {
        _isLoading = false;
        _statusMessage = "Error detecting food";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF1E202C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isLoading ? Colors.cyanAccent : Colors.white.withOpacity(0.1),
                width: _isLoading ? 2 : 1,
              ),
              boxShadow: [
                if (_isLoading)
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_image == null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_enhance_rounded, 
                              size: 48, 
                              color: Colors.cyanAccent
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Scan Your Food',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'AI-Powered Detection',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Image.file(_image!, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    if (_isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                  // Scanning Line Animation placeholder (visual only)
                  if (_isLoading)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _ScanningLine(),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_statusMessage != null) ...[
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isLoading 
                    ? [const Color(0xFF2C3E50), const Color(0xFF34495E)]
                    : [const Color(0xFF1D976C), const Color(0xFF93F9B9)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_isLoading ? Colors.grey : Colors.green).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Row(
              children: [
                Icon(
                  _isLoading ? Icons.sync : Icons.auto_awesome, 
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!_isLoading)
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              ],
            ),
          )
        ]
      ],
    );
  }
}

class _ScanningLine extends StatefulWidget {
  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _controller.value * 260),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
              gradient: const LinearGradient(
                colors: [Colors.transparent, Colors.cyanAccent, Colors.transparent],
              ),
            ),
          ),
        );
      },
    );
  }
}