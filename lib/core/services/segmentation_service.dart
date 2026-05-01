import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class SegmentationResult {
  final Rect boundingBox;
  final String label;
  
  SegmentationResult({required this.boundingBox, required this.label});
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
      if (object.labels.isNotEmpty) {
        labelName = object.labels.first.text;
      }
      results.add(SegmentationResult(
        boundingBox: object.boundingBox,
        label: labelName,
      ));
    }
    return results;
  }
  
  void dispose() {
    _objectDetector.close();
  }
}
