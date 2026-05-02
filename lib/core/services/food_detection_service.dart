import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class CustomDetectionResult {
  final String label;
  final double score;
  CustomDetectionResult(this.label, this.score);
}

class FoodDetectionService {
  Interpreter? _interpreter;
  List<String>? _labels;

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
    // Remove underscores and capitalize words
    return label.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/tflite/food_model.tflite');
      final String labelsData = await rootBundle.loadString('assets/tflite/labels.txt');
      _labels = labelsData.split('\n').where((s) => s.trim().isNotEmpty).toList();
      debugPrint("✅ TFLite Model loaded successfully with ${_labels?.length} labels.");
    } catch (e) {
      debugPrint("❌ Failed to load TFLite model: $e");
    }
  }

  Future<CustomDetectionResult?> detectFood(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;
      return await detectFoodFromImage(originalImage);
    } catch (e) {
      debugPrint("TFLite File Error: $e");
      return null;
    }
  }

  Future<CustomDetectionResult?> detectFoodFromImage(img.Image originalImage) async {
    try {
      if (_interpreter == null || _labels == null) {
        await init();
      }

      img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

      var inputTensor = _interpreter!.getInputTensor(0);
      String inType = inputTensor.type.toString().toLowerCase();
      bool isQuantized = inType.contains('int8') || inType.contains('uint8');

      var input;
      if (isQuantized) {
        input = List.generate(1, (i) => List.generate(224, (j) => List.generate(224, (k) => List.filled(3, 0))));
        for (int y = 0; y < 224; y++) {
          for (int x = 0; x < 224; x++) {
            var pixel = resizedImage.getPixel(x, y);
            input[0][y][x][0] = pixel.r.toInt();
            input[0][y][x][1] = pixel.g.toInt();
            input[0][y][x][2] = pixel.b.toInt();
          }
        }
      } else {
        input = List.generate(1, (i) => List.generate(224, (j) => List.generate(224, (k) => List.filled(3, 0.0))));
        for (int y = 0; y < 224; y++) {
          for (int x = 0; x < 224; x++) {
            var pixel = resizedImage.getPixel(x, y);
            input[0][y][x][0] = (pixel.r - 127.5) / 127.5;
            input[0][y][x][1] = (pixel.g - 127.5) / 127.5;
            input[0][y][x][2] = (pixel.b - 127.5) / 127.5;
          }
        }
      }
      
      var outputTensor = _interpreter!.getOutputTensor(0);
      String outType = outputTensor.type.toString().toLowerCase();
      bool isOutputQuantized = outType.contains('int8') || outType.contains('uint8');
      var output;

      if (isOutputQuantized) {
        output = List.generate(1, (i) => List.filled(_labels!.length, 0));
      } else {
        output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));
      }

      _interpreter!.run(input, output);

      // Sort all scores to find the best Egyptian match, not just the absolute #1
      // which might be an irrelevant foreign name (like 'Spaghetti' instead of 'Macaroni')
      List<MapEntry<int, double>> indexedScores = [];
      for (int i = 0; i < _labels!.length; i++) {
        double score = isOutputQuantized ? (output[0][i] / 255.0) : output[0][i];
        indexedScores.add(MapEntry(i, score));
      }
      
      // Sort descending by score
      indexedScores.sort((a, b) => b.value.compareTo(a.value));

      String? topRawLabel;
      double topRawScore = 0.0;

      // Look through the top 5 highest confidence predictions
      for (int i = 0; i < 5 && i < indexedScores.length; i++) {
        int labelIndex = indexedScores[i].key;
        double score = indexedScores[i].value;
        String rawLabel = _labels![labelIndex];

        if (rawLabel.toLowerCase().contains("__background__") || rawLabel.startsWith("/g/")) {
           continue;
        }
        
        // Save the first valid raw label as a fallback
        if (topRawLabel == null) {
          topRawLabel = rawLabel;
          topRawScore = score;
        }

        String? translated = _translateToEgyptian(rawLabel);
        if (translated != null) {
          // Found a valid Egyptian dish in the top 5!
          return CustomDetectionResult(translated, score);
        }
      }
      
      // If we reach here, no Egyptian dish was found in the top 5.
      // Return the best raw label so we don't get 'Food item' default.
      if (topRawLabel != null) {
        return CustomDetectionResult(_formatRawLabel(topRawLabel), topRawScore);
      }

      return null;
    } catch (e) {
      debugPrint("TFLite Error: $e");
      return null;
    }
  }

  Uint8List _imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
