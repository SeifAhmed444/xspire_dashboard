import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class FoodClassificationResult {
  final String label;
  final double confidence;
  final double price;
  final double oldPrice;
  final int count;
  final bool isAvailable;
  
  FoodClassificationResult({
    required this.label,
    required this.confidence,
    this.price = 0.0,
    this.oldPrice = 0.0,
    this.count = 1,
    this.isAvailable = true,
  });
}

class FoodDetectionService {
  static final FoodDetectionService _instance = FoodDetectionService._internal();
  
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  // Model input dimensions
  static const int INPUT_SIZE = 224;
  
  // Dictionary to map generic AI labels to Egyptian/Famous names
  final Map<String, String> _egyptianMapping = {
    'dolma': 'Mahshi / Waraq Enab',
    'meatball': 'Kofta',
    'kofta': 'Kofta',
    'falafel': 'Ta\'ameya / Falafel',
    'kebab': 'Kebab & Kofta',
    'shish kabob': 'Shish Tawook',
    'mulukhiyah': 'Molokhia',
    'lentil': 'Shorbat Ads (Lentil)',
    'rice': 'Roz (Rice)',
    'pasta': 'Macarona / Pasta',
    'pizza': 'Pizza',
    'hummus': 'Hummus',
    'shawarma': 'Shawarma',
    'kibbeh': 'Kobeiba',
    'tajine': 'Tagine / Torly',
    'moussaka': 'Mossaqa\'a / Betengan',
    'eggplant': 'Betengan',
    'okra': 'Bamia (Okra)',
    'flatbread': 'Aish (Bread)',
    'tabbouleh': 'Salad / Tabbouleh',
    'baklava': 'Baklawa',
    'kunafa': 'Kunafa',
    'koshary': 'Koshary',
    'kushari': 'Koshary',
    'fetta': 'Fattah',
    'stew': 'Tagine / Torly',
    'casserole': 'Tagine / Torly',
    'tahini': 'Tahina',
    'dip': 'Tahina / Dip',
    'sausage': 'Sogoq',
    'churrasco': 'Mashweyat (Grilled Meat)',
    'meze': 'Muqaballat (Meze)',
    'macaroni': 'Macarona',
  };

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
      _interpreter = await Interpreter.fromAsset('assets/tflite/food_model.tflite');
      debugPrint('✅ TFLite model loaded');
      
      // Load labels
      final labelData = await rootBundle.loadString('assets/tflite/labels.txt');
      _labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();
      debugPrint('✅ Loaded ${_labels?.length} labels');
      
      _isInitialized = true;
      _isInitializing = false;
      debugPrint('✅ FoodDetectionService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing FoodDetectionService: $e');
      _isInitializing = false;
    }
  }
  
  String? _translateToEgyptian(String label) {
    String lowerLabel = label.toLowerCase();
    for (var entry in _egyptianMapping.entries) {
      if (lowerLabel.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String _formatRawLabel(String label) {
    return label.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Detection with TFLite
  Future<FoodClassificationResult?> detectFood(File imageFile) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      
      final tfliteResult = await _detectWithTFLite(imageFile);
      return tfliteResult;
    } catch (e) {
      debugPrint('❌ Error in detectFood: $e');
      return null;
    }
  }
  
  /// Detect with TFLite
  Future<FoodClassificationResult?> _detectWithTFLite(File imageFile) async {
    try {
      if (_interpreter == null || _labels == null) return null;

      // Read and preprocess image
      final input = await _preprocessImage(imageFile);
      if (input == null) return null;
      
      // Determine output shape from interpreter
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputSize = outputShape.last;
      
      // Run inference
      var output = List<double>.filled(outputSize, 0.0).reshape([1, outputSize]);
      _interpreter!.run(input, output);
      
      List<double> scores = List<double>.from(output[0]);
      
      // Create indexed scores for sorting
      List<MapEntry<int, double>> indexedScores = [];
      for (int i = 0; i < scores.length; i++) {
        indexedScores.add(MapEntry(i, scores[i]));
      }
      
      // Sort descending
      indexedScores.sort((a, b) => b.value.compareTo(a.value));

      // Look through top 5 results for an Egyptian match
      for (int i = 0; i < 5 && i < indexedScores.length; i++) {
        int idx = indexedScores[i].key;
        double score = indexedScores[i].value;
        if (idx >= _labels!.length) continue;
        
        String rawLabel = _labels![idx];
        if (rawLabel.toLowerCase().contains("background")) continue;

        String? egyptian = _translateToEgyptian(rawLabel);
        if (egyptian != null) {
          return FoodClassificationResult(
            label: egyptian, 
            confidence: score,
            price: 50.0, // Default price
            oldPrice: 70.0, // Default old price
            count: 1,
            isAvailable: true,
          );
        }
      }
      
      // Fallback to top #1 raw result
      int topIdx = indexedScores[0].key;
      if (topIdx < _labels!.length) {
        return FoodClassificationResult(
          label: _formatRawLabel(_labels![topIdx]),
          confidence: indexedScores[0].value,
          price: 45.0,
          oldPrice: 60.0,
          count: 1,
          isAvailable: true,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error in TFLite detection: $e');
      return null;
    }
  }
  
  /// Detect multiple items (TFLite-based fallback)
  Future<Map<String, FoodClassificationResult>> detectItems(File imageFile) async {
    try {
      if (!_isInitialized) await init();
      
      // For now, if we use classification model for "items", 
      // we just return the top result as one item.
      // In a real scenario, this would use object detection.
      final result = await _detectWithTFLite(imageFile);
      if (result != null) {
        return {result.label: result};
      }
      return {};
    } catch (e) {
      debugPrint('❌ Error in detectItems: $e');
      return {};
    }
  }
  
  /// Preprocess image for TFLite
  Future<List<List<List<List<double>>>>?> _preprocessImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      
      final resized = img.copyResize(image, width: INPUT_SIZE, height: INPUT_SIZE);
      
      // Standard normalization for MobileNet/Inception: (pixel - 127.5) / 127.5
      final input = List.generate(1, (i) => 
        List.generate(INPUT_SIZE, (y) => 
          List.generate(INPUT_SIZE, (x) => 
            List.generate(3, (c) {
              final pixel = resized.getPixelSafe(x, y);
              final val = c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b);
              return (val - 127.5) / 127.5;
            })
          )
        )
      );
      
      return input;
    } catch (e) {
      debugPrint('❌ Error preprocessing image: $e');
      return null;
    }
  }
  
  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
