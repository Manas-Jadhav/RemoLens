import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// Handles on-device feature extraction using a TensorFlow Lite model.
// The generated embedding is used for vector similarity search.
class TfliteService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/model.tflite');
    } catch (e) {
    }
  }

  Future<List<double>> generateEmbedding(File imageFile) async {
    if (_interpreter == null) await loadModel();

    final rawImage = img.decodeImage(imageFile.readAsBytesSync());
    if (rawImage == null) throw Exception("Could not decode image");

    // Resize image using letterboxing to preserve aspect ratio.
    // Black padding is added to avoid geometric distortion.
    final resizedImage = img.copyResize(
      rawImage,
      width: 224,
      height: 224,
      maintainAspect: true,
      backgroundColor: img.ColorRgb8(0, 0, 0), // Black background
    );

    // Create input tensor [1, 224, 224, 3] normalized to [0, 1]
    var input = List.generate(1, (i) =>
        List.generate(224, (y) =>
            List.generate(224, (x) =>
                List.generate(3, (c) => 0.0)
            )
        )
    );

    // Populate tensor with normalized RGB values in range [0, 1]
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixelSafe(x, y);

        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }

    // Run inference to generate feature embedding
    var output = List.filled(1 * 1280, 0.0).reshape([1, 1280]);
    _interpreter!.run(input, output);

    return List<double>.from(output[0]);
  }
}