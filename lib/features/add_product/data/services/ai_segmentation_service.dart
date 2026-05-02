import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiSegmentationService {
  // TODO: Replace with your actual Gemini API Key
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; 

  Future<Map<String, int>> analyzeImage(File image) async {
    try {
      if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        debugPrint("WARNING: Using mock data because API key is not set.");
        // Simulate delay
        await Future.delayed(const Duration(seconds: 2));
        return {
          "Tomatoes": 2,
          "Potatoes": 1,
          "Onions": 3,
        };
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final prompt = TextPart(
          'Analyze this image and identify all food items and their exact counts. '
          'Return ONLY a valid JSON object where keys are item names (in English) '
          'and values are integers representing the counts. '
          'Do not include markdown blocks or any other text. '
          'Example: {"Tomatoes": 2, "Apples": 1}');
          
      final imageParts = [
        DataPart('image/jpeg', await image.readAsBytes()),
      ];

      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);

      final text = response.text;
      if (text != null && text.isNotEmpty) {
        // Clean up potential markdown formatting that the AI might still add
        final cleanedText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> decoded = jsonDecode(cleanedText);
        
        final Map<String, int> result = {};
        decoded.forEach((key, value) {
          result[key] = (value as num).toInt();
        });
        
        return result;
      }
      return {};
    } catch (e) {
      debugPrint('Error in AiSegmentationService: $e');
      throw Exception('Failed to analyze image: $e');
    }
  }
}
