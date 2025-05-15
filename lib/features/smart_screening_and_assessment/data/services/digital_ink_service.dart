import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:scribble/scribble.dart';
import 'dart:async';

class DigitalInkService {
  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();
  late DigitalInkRecognizer _recognizer;
  final Ink _ink = Ink();
  static const int _maxDownloadAttempts = 3;
  final _progressController = StreamController<double>.broadcast();

  Stream<double> get downloadProgress => _progressController.stream;

  DigitalInkService() {
    _recognizer = DigitalInkRecognizer(languageCode: 'en');
  }

  Future<bool> checkAndDownloadModel() async {
    int attempts = 0;
    bool success = false;

    while (attempts < _maxDownloadAttempts && !success) {
      try {
        if (await _modelManager.isModelDownloaded('en')) {
          _progressController.add(1.0);
          return true;
        }

        _progressController.add(0.0); // Start progress
        attempts++;

        // Simulate progress during download (since ML Kit doesn't provide progress)
        Timer.periodic(const Duration(milliseconds: 500), (timer) async {
          if (timer.tick * 0.05 >= 1.0 || success) {
            timer.cancel();
            if (success) _progressController.add(1.0);
          } else {
            _progressController.add(timer.tick * 0.05);
          }
        });

        success = await _modelManager.downloadModel('en').timeout(
              const Duration(minutes: 2), // Increased timeout
              onTimeout: () => false,
            );

        if (success) {
          _progressController.add(1.0);
          return true;
        } else {
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        attempts++;
        if (attempts >= _maxDownloadAttempts) {
          _progressController.addError(e);
          return false;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return false;
  }

  Future<String?> recognizeLetter(List<SketchLine> lines) async {
    if (lines.isEmpty) return null;
    _ink.strokes.clear();
    final stroke = Stroke();
    for (var line in lines) {
      for (var point in line.points) {
        stroke.points.add(StrokePoint(
          x: point.x,
          y: point.y,
          t: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    }
    if (stroke.points.isNotEmpty) {
      _ink.strokes.add(stroke);
    }
    try {
      final candidates = await _recognizer.recognize(_ink);
      return candidates.isNotEmpty ? candidates[0].text.toLowerCase()[0] : null;
    } catch (e) {
      print('Recognition error: $e');
      return null;
    }
  }

  void dispose() {
    _recognizer.close();
    _progressController.close();
  }
}
