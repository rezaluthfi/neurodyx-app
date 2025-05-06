import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsEngineManager {
  final FlutterTts flutterTts;

  TtsEngineManager(this.flutterTts);

  // Initialize the TTS engine with event handlers
  Future<void> initialize({
    required Function onStart,
    required Function onComplete,
    required Function onCancel,
    required Function onError,
  }) async {
    flutterTts.setStartHandler(() {
      debugPrint('TTS started');
      onStart();
    });

    flutterTts.setCompletionHandler(() {
      debugPrint('TTS completed');
      onComplete();
    });

    flutterTts.setCancelHandler(() {
      debugPrint('TTS cancelled');
      onCancel();
    });

    flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      onError(msg);
    });

    try {
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      debugPrint('TTS engine initialized successfully');
    } catch (e) {
      debugPrint('TTS Initialization Error: $e');
      throw e;
    }
  }

  //Set the speech rate for the TTS engine
  Future<void> setSpeechRate(double rate) async {
    try {
      debugPrint('Setting speech rate to: $rate');
      await flutterTts.setSpeechRate(rate).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Failed to set speech rate');
        },
      );
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
      throw e;
    }
  }

  // Stop the TTS playback
  Future<void> stop() async {
    try {
      await flutterTts.stop().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Failed to stop TTS');
        },
      );
      debugPrint('TTS stopped successfully');
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
      throw e;
    }
  }

  // Start TTS playback with the given text
  Future<void> speak(String text) async {
    try {
      await flutterTts.speak(text).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Failed to start TTS');
        },
      );
      debugPrint('TTS started speaking');
    } catch (e) {
      debugPrint('Error starting TTS: $e');
      throw e;
    }
  }

  // Get available languages for TTS
  Future<List<dynamic>> getAvailableLanguages() async {
    try {
      return await flutterTts.getLanguages;
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      return [];
    }
  }

  // Get available voices for TTS
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      return await flutterTts.getVoices;
    } catch (e) {
      debugPrint('Error getting available voices: $e');
      return [];
    }
  }
}
