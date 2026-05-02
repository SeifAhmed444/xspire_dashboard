import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class FoodClassificationResult {
  final String label;
  final double confidence;
  
  FoodClassificationResult({
    required this.label,
    required this.confidence,
  });
}

class FoodDetectionService {
  static final FoodDetectionService _instance = FoodDetectionService._internal();
  
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isInitialized = false;
  bool _isInitializing = false;
  late GenerativeModel _geminiModel;
  
  // Model input/output dimensions
  static const int INPUT_SIZE = 224;
  static const int NUM_RESULTS = 10;
  
  FoodDetectionService._internal();
  
  factory FoodDetectionService() {
    return _instance;
  }
  
  /// Initialize the food detection service
  Future<void> init() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    try {
      // Load TFLite model
      await _loadModel();
      
      // Load labels
      await _loadLabels();
      
      // Initialize Gemini API
      _initializeGemini();
      
      _isInitialized = true;
      debugPrint('✅ FoodDetectionService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing FoodDetectionService: $e');
      _isInitializing = false;
      rethrow;
    }
  }
  
  /// Load the TFLite model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/tflite/food_model.tflite');
      debugPrint('✅ TFLite model loaded');
    } catch (e) {
      debugPrint('❌ Error loading TFLite model: $e');
      rethrow;
    }
  }
  
  /// Load labels from assets
  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/tflite/labels.txt');
      _labels = labelData.split('\n').where((e) => e.isNotEmpty).toList();
      debugPrint('✅ Loaded ${_labels.length} labels');
    } catch (e) {
      debugPrint('❌ Error loading labels: $e');
      rethrow;
    }
  }
  
  /// Initialize Gemini model for fallback
  void _initializeGemini() {
    // Using the API key from firebase_options.dart
    const String apiKey = 'AIzaSyDN769DzqBMfmeWPEe9HU6yfnQA1qzWrJI';
    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    debugPrint('✅ Gemini model initialized');
  }
  
  /// Smart food detection with TFLite + Gemini fallback
  Future<FoodClassificationResult?> smartFoodDetect(File imageFile) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      
      // Try TFLite first (faster, offline)
      final tfliteResult = await _detectWithTFLite(imageFile);
      if (tfliteResult != null && tfliteResult.confidence > 0.5) {
        debugPrint('✅ TFLite detected: ${tfliteResult.label} (${tfliteResult.confidence.toStringAsFixed(2)})');
        return tfliteResult;
      }
      
      debugPrint('⚠️ TFLite confidence low, falling back to Gemini...');
      
      // Fallback to Gemini for better accuracy
      return await _detectWithGemini(imageFile);
    } catch (e) {
      debugPrint('❌ Error in smartFoodDetect: $e');
      return null;
    }
  }
  
  /// Detect with TFLite
  Future<FoodClassificationResult?> _detectWithTFLite(File imageFile) async {
    try {
      // Read and preprocess image
      final imageData = await _preprocessImage(imageFile);
      if (imageData == null) return null;
      
      // Run inference
      final output = List<double>.filled(NUM_RESULTS, 0.0);
      _interpreter.run(imageData, output);
      
      // Find top result
      double maxConfidence = 0.0;
      int maxIndex = 0;
      
      for (int i = 0; i < output.length; i++) {
        if (output[i] > maxConfidence) {
          maxConfidence = output[i];
          maxIndex = i;
        }
      }
      
      if (maxIndex < _labels.length) {
        return FoodClassificationResult(
          label: _labels[maxIndex],
          confidence: maxConfidence,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error in TFLite detection: $e');
      return null;
    }
  }
  
  /// Detect with Gemini (fallback, more accurate but slower)
  Future<FoodClassificationResult?> _detectWithGemini(File imageFile) async {
    try {
      // Read image and convert to base64
      final bytes = await imageFile.readAsBytes();
      
      // Create content with image
      final content = [
        Content.multi([
          TextPart('What food item is shown in this image? '
              'Respond with ONLY the food name, no explanation.'),
          DataPart('image/jpeg', bytes),
        ])
      ];
      
      // Get response from Gemini
      final response = await _geminiModel.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        final foodName = response.text!.trim();
        return FoodClassificationResult(
          label: foodName,
          confidence: 0.95, // High confidence for Gemini
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error in Gemini detection: $e');
      return null;
    }
  }
  
  /// Detect multiple items (object detection/segmentation)
  Future<Map<String, int>> detectItems(File imageFile) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      
      // For now, use Gemini for multi-item detection
      // (TFLite single-image classifier isn't suitable for this)
      final result = <String, int>{};
      
      final bytes = await imageFile.readAsBytes();
      
      final content = [
        Content.multi([
          TextPart(
            'Identify all distinct food items in this image. '
            'Respond in this exact format:\n'
            'item1: count\n'
            'item2: count\n'
            'Only list items, no other text.'
          ),
          DataPart('image/jpeg', bytes),
        ])
      ];
      
      final response = await _geminiModel.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        final lines = response.text!.split('\n');
        
        for (final line in lines) {
          final parts = line.split(':');
          if (parts.length == 2) {
            final itemName = parts[0].trim().toLowerCase();
            final count = int.tryParse(parts[1].trim()) ?? 1;
            result[itemName] = count;
          }
        }
      }
      
      debugPrint('✅ Detected items: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error in detectItems: $e');
      return {};
    }
  }
  
  /// Preprocess image for TFLite
  Future<List<List<List<List<double>>>>>? _preprocessImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Resize to INPUT_SIZE x INPUT_SIZE
      final resized = img.copyResize(
        image,
        width: INPUT_SIZE,
        height: INPUT_SIZE,
      );
      
      // Convert to normalized float values
      final List<List<List<List<double>>>> input = List.generate(
        1,
        (i) => List.generate(
          INPUT_SIZE,
          (y) => List.generate(
            INPUT_SIZE,
            (x) => List.generate(
              3,
              (c) {
                final pixel = resized.getPixelSafe(x, y);
                final value = c == 0
                    ? pixel.r.toDouble()
                    : c == 1
                        ? pixel.g.toDouble()
                        : pixel.b.toDouble();
                return value / 255.0; // Normalize to 0-1
              },
            ),
          ),
        ),
      );
      
      return input;
    } catch (e) {
      debugPrint('❌ Error preprocessing image: $e');
      return null;
    }
  }
  
  /// Dispose resources
  void dispose() {
    try {
      _interpreter.close();
      _isInitialized = false;
      debugPrint('✅ FoodDetectionService disposed');
    } catch (e) {
      debugPrint('❌ Error disposing FoodDetectionService: $e');
    }
  }
}
