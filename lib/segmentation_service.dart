import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Uses a Hugging Face object detection model to locate and crop
// the remote control from an image before feature extraction.
// This reduces background noise and improves embedding accuracy.
class SegmentationService {

  final String _apiKey = dotenv.env['HF_API_TOKEN']!;
  final String _apiUrl = dotenv.env['HF_API_URL']!;

  Future<File?> autoCropImage(File originalFile) async {
    try {
      final imageBytes = await originalFile.readAsBytes();

      // Send image to Hugging Face inference API for object detection
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'image/jpeg',
        },
        body: imageBytes,
      );

      if (response.statusCode != 200) {
        return originalFile; // Graceful fallback if segmentation fails
      }

      // 3. Parse Results
      // The API returns a list of objects: [{"score": 0.99, "label": "remote", "box": {"xmin":...}}]
      final List<dynamic> result = jsonDecode(response.body);

      if (result.isEmpty) {
        // No objects detected; return original image as fallback
        return originalFile;
      }

      // 4. Find the best object (Highest confidence score)
      // Note: This model detects MANY things. Ideally, we look for 'remote'
      // but generic 'highest score' usually works for close-ups.
      var bestObject = result[0];
      for (var obj in result) {
        if (obj['score'] > bestObject['score']) {
          bestObject = obj;
        }
      }

      final box = bestObject['box'];

      // Crop image locally using bounding box returned by the model
      final rawImage = await img.decodeImageFile(originalFile.path);
      if (rawImage == null) return null;

      // Hugging Face returns exact pixel coordinates (xmin, ymin, xmax, ymax)
      int x = box['xmin'];
      int y = box['ymin'];
      int w = box['xmax'] - box['xmin'];
      int h = box['ymax'] - box['ymin'];

      // Add padding and clamp values to avoid out-of-bounds cropping
      int padding = 20;
      x = max(0, x - padding);
      y = max(0, y - padding);
      w = min(rawImage.width - x, w + (padding * 2));
      h = min(rawImage.height - y, h + (padding * 2));

      final croppedImage = img.copyCrop(rawImage, x: x, y: y, width: w, height: h);

      // Save cropped image and return new file
      final String newPath = originalFile.path.replaceFirst('.jpg', '_cropped.jpg');
      final File finalFile = File(newPath)..writeAsBytesSync(img.encodeJpg(croppedImage));

      return finalFile;

    } catch (e) {
      // On error, return original image to avoid blocking the user flow
      return originalFile;
    }
  }
}