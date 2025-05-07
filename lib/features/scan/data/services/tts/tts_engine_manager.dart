import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsEngineManager {
  final FlutterTts _flutterTts;

  TtsEngineManager() : _flutterTts = FlutterTts();

  // Initialize the TTS engine with optional event handlers
  Future<void> initialize({
    Function? onStart,
    Function? onComplete,
    Function? onCancel,
    Function(String)? onError,
  }) async {
    if (onStart != null) {
      _flutterTts.setStartHandler(() {
        debugPrint('TTS started');
        onStart();
      });
    }

    if (onComplete != null) {
      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS completed');
        onComplete();
      });
    }

    if (onCancel != null) {
      _flutterTts.setCancelHandler(() {
        debugPrint('TTS cancelled');
        onCancel();
      });
    }

    if (onError != null) {
      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        onError(msg);
      });
    }

    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      debugPrint('TTS engine initialized successfully');
    } catch (e) {
      debugPrint('TTS Initialization Error: $e');
      rethrow;
    }
  }

  // Set the speech rate for the TTS engine
  Future<void> setSpeechRate(double rate) async {
    try {
      debugPrint('Setting speech rate to: $rate');
      await _flutterTts.setSpeechRate(rate).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Failed to set speech rate');
        },
      );
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
      rethrow;
    }
  }

  // Stop the TTS playback
  Future<void> stop() async {
    try {
      await _flutterTts.stop().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Failed to stop TTS');
        },
      );
      debugPrint('TTS stopped successfully');
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
      rethrow;
    }
  }

  // Start TTS playback with the given text
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Failed to start TTS');
        },
      );
      debugPrint('TTS started speaking');
    } catch (e) {
      debugPrint('Error starting TTS: $e');
      rethrow;
    }
  }

  // Get available languages for TTS
  Future<List<dynamic>> getAvailableLanguages() async {
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      return [];
    }
  }

  // Get available voices for TTS
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      debugPrint('Error getting available voices: $e');
      return [];
    }
  }

  // Dispose the TTS engine
  void dispose() {
    _flutterTts.stop();
  }
}
