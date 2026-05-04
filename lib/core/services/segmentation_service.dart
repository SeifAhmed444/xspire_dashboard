import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class SegmentationResult {
  final Rect boundingBox;
  final String label;
  final double confidence;

  SegmentationResult({required this.boundingBox, required this.label, this.confidence = 0.0});
}

class SegmentationService {
  late ObjectDetector _objectDetector;

  SegmentationService() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<List<SegmentationResult>> detectObjects(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final objects = await _objectDetector.processImage(inputImage);

    List<SegmentationResult> results = [];
    for (var object in objects) {
      String labelName = "Food item";
      double confidence = 0.0;
      if (object.labels.isNotEmpty) {
        labelName = object.labels.first.text;
        confidence = object.labels.first.confidence;
      }
      results.add(SegmentationResult(
        boundingBox: object.boundingBox,
        label: labelName,
        confidence: confidence,
      ));
    }
    return results;
  }

  void dispose() {
    _objectDetector.close();
  }
}