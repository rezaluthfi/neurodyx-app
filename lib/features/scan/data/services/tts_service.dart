import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/scan/data/services/tts/language_detector.dart';
import 'package:neurodyx/features/scan/data/services/tts/text_preprocessor.dart';
import 'package:neurodyx/features/scan/data/services/tts/tts_engine_manager.dart';
import 'package:neurodyx/features/scan/data/services/tts/voice_selector.dart';
import 'package:neurodyx/features/scan/data/services/tts/models/tts_state.dart';

class TtsService extends ChangeNotifier {
  late FlutterTts flutterTts;
  late TtsEngineManager _engineManager;
  late LanguageDetector _languageDetector;
  late TextPreprocessor _textPreprocessor;
  late VoiceSelector _voiceSelector;

  TtsState _state = const TtsState();
  Timer? _rateChangeDebouncer;
  List<dynamic>? _cachedLanguages;
  List<dynamic>? _cachedVoices;

  // Public getters
  bool get isTtsPlaying => _state.isTtsPlaying;
  bool get isTtsInitializing => _state.isTtsInitializing;
  bool get isSettingSpeechRate => _state.isSettingSpeechRate;
  double get speechRate => _state.speechRate;
  String get detectedLanguage => _state.detectedLanguage;

  TtsService() {
    _initComponents();
  }

  // Initialize all necessary components
  void _initComponents() {
    flutterTts = FlutterTts();
    _engineManager = TtsEngineManager(flutterTts);
    _languageDetector = LanguageDetector();
    _textPreprocessor = TextPreprocessor();
    _voiceSelector = VoiceSelector();

    _initTts();
  }

  // Initialize the TTS engine
  void _initTts() async {
    _updateState(isTtsInitializing: true);

    try {
      await _engineManager.initialize(
        onStart: () {
          _updateState(
            isTtsPlaying: true,
            isTtsInitializing: false,
          );
        },
        onComplete: () {
          _updateState(
            isTtsPlaying: false,
            isTtsInitializing: false,
            currentTtsText: null,
          );
        },
        onCancel: () {
          _updateState(
            isTtsPlaying: false,
            isTtsInitializing: false,
          );
        },
        onError: (msg) {
          _updateState(
            isTtsPlaying: false,
            isTtsInitializing: false,
            currentTtsText: null,
          );
        },
      );

      _cachedLanguages = await _engineManager.getAvailableLanguages();
      _cachedVoices = await _engineManager.getAvailableVoices();

      await _engineManager.setSpeechRate(_state.speechRate);
      await _setLanguage(_state.detectedLanguage);

      debugPrint('TTS initialized successfully');
    } catch (e) {
      debugPrint('TTS Initialization Error: $e');
    } finally {
      _updateState(isTtsInitializing: false);
    }
  }

  // Set the TTS language and select an appropriate voice
  Future<void> _setLanguage(String languageCode) async {
    try {
      var languages =
          _cachedLanguages ?? await _engineManager.getAvailableLanguages();
      _cachedLanguages ??= languages;

      await _voiceSelector.setLanguage(flutterTts, languageCode, languages);

      var voices = _cachedVoices ?? await _engineManager.getAvailableVoices();
      _cachedVoices ??= voices;

      await _voiceSelector.selectVoiceForLanguage(
          flutterTts, languageCode, voices);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  // Update the speech rate preview
  void updateSpeechRatePreview(double rate) {
    _updateState(speechRate: rate.clamp(0.0, 1.0));
  }

  // Set the speech rate with debouncing
  void setSpeechRate(double rate, {BuildContext? context}) {
    _rateChangeDebouncer?.cancel();
    _updateState(speechRate: rate.clamp(0.0, 1.0));

    _rateChangeDebouncer = Timer(const Duration(milliseconds: 300), () {
      _applySpeechRate(context);
    });
  }

  // Apply the speech rate to the TTS engine
  Future<void> _applySpeechRate(BuildContext? context) async {
    if (_state.isSettingSpeechRate) {
      debugPrint('Speech rate setting in progress, skipping...');
      return;
    }

    _updateState(isSettingSpeechRate: true);

    try {
      await _engineManager.setSpeechRate(_state.speechRate);

      if (_state.isTtsPlaying && _state.currentTtsText != null) {
        String textToSpeak = _state.currentTtsText!;

        await _engineManager.stop();
        await Future.delayed(const Duration(milliseconds: 100));
        await _engineManager.speak(textToSpeak);

        _updateState(isTtsPlaying: true);
        debugPrint(
            'Successfully restarted TTS with new speech rate: ${_state.speechRate}');
      }
    } catch (e) {
      debugPrint('Error in setSpeechRate: $e');
      if (context != null) {
        CustomSnackBar.show(
          context,
          message: 'Error changing speech rate: $e',
          type: SnackBarType.error,
        );
      }
      _updateState(
        isTtsPlaying: false,
        currentTtsText: null,
      );
    } finally {
      _updateState(isSettingSpeechRate: false);
    }
  }

  // Read the text aloud using TTS
  Future<void> readTextAloud(BuildContext context, String? text) async {
    if (text == null || text.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'No text to read!',
        type: SnackBarType.error,
      );
      _updateState(isTtsInitializing: false);
      return;
    }

    _updateState(isTtsInitializing: true);

    try {
      if (_state.isTtsPlaying) {
        debugPrint(
            'Stopping TTS, current isTtsPlaying: ${_state.isTtsPlaying}');
        await _engineManager.stop();
        _updateState(
          isTtsPlaying: false,
          isTtsInitializing: false,
        );
        return;
      }

      // Detect language and clean text
      String detectedLanguage = _languageDetector.detectLanguage(text);
      debugPrint('Detected language: $detectedLanguage');

      String languageName =
          detectedLanguage == 'id-ID' ? 'Indonesian' : 'English';
      CustomSnackBar.show(
        context,
        message: 'Using $languageName voice',
        type: SnackBarType.success,
      );

      await _setLanguage(detectedLanguage);
      String cleanedText =
          _textPreprocessor.cleanTextForTts(text, detectedLanguage);

      _updateState(
        currentTtsText: cleanedText,
        detectedLanguage: detectedLanguage,
      );

      debugPrint(
          'Playing TTS: ${_state.currentTtsText} in language: $detectedLanguage');

      await _engineManager.setSpeechRate(_state.speechRate);

      bool speakSuccess = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          await _engineManager.speak(_state.currentTtsText!);
          speakSuccess = true;
          break;
        } catch (e) {
          debugPrint('Attempt $attempt to speak failed: $e');
          if (attempt == 1 && detectedLanguage == 'id-ID') {
            debugPrint('Trying with English language as fallback');
            await _setLanguage('en-US');
            _updateState(detectedLanguage: 'en-US');
          } else if (attempt == 2 && detectedLanguage == 'en-US') {
            debugPrint('Trying with Indonesian language as second fallback');
            await _setLanguage('id-ID');
            _updateState(detectedLanguage: 'id-ID');
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      if (speakSuccess) {
        _updateState(isTtsPlaying: true);
        debugPrint(
            'Successfully started TTS playback, isTtsPlaying: ${_state.isTtsPlaying}');
      } else {
        debugPrint('Failed to start TTS after multiple attempts');
        CustomSnackBar.show(
          context,
          message: 'Failed to start text reading',
          type: SnackBarType.error,
        );
        _updateState(
          currentTtsText: null,
          isTtsPlaying: false,
        );
      }
    } catch (e) {
      debugPrint('Error reading text: $e');
      CustomSnackBar.show(
        context,
        message: 'Error reading text: $e',
        type: SnackBarType.error,
      );
      _updateState(
        currentTtsText: null,
        isTtsPlaying: false,
      );
    } finally {
      _updateState(isTtsInitializing: false);
    }
  }

  // Stop the TTS playback
  Future<void> stopTts() async {
    debugPrint(
        'Attempting to stop TTS, current isTtsPlaying: ${_state.isTtsPlaying}');
    try {
      await _engineManager.stop();
      await Future.delayed(const Duration(milliseconds: 50)); // Small delay
      _updateState(
        isTtsPlaying: false,
        currentTtsText: null,
        isTtsInitializing: false,
      );
      debugPrint(
          'TTS stopped successfully, isTtsPlaying: ${_state.isTtsPlaying}');
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
      _updateState(
        isTtsPlaying: false,
        currentTtsText: null,
        isTtsInitializing: false,
      );
    }
  }

  // Update the state and notify listeners
  void _updateState({
    bool? isTtsPlaying,
    bool? isTtsInitializing,
    bool? isSettingSpeechRate,
    double? speechRate,
    String? currentTtsText,
    String? detectedLanguage,
  }) {
    bool stateChanged = false;

    if (isTtsPlaying != null && _state.isTtsPlaying != isTtsPlaying) {
      debugPrint(
          'TTS isTtsPlaying changed: ${_state.isTtsPlaying} -> $isTtsPlaying');
      stateChanged = true;
    }

    _state = _state.copyWith(
      isTtsPlaying: isTtsPlaying,
      isTtsInitializing: isTtsInitializing,
      isSettingSpeechRate: isSettingSpeechRate,
      speechRate: speechRate,
      currentTtsText: currentTtsText,
      detectedLanguage: detectedLanguage,
    );

    if (stateChanged ||
        isTtsInitializing != null ||
        isSettingSpeechRate != null) {
      notifyListeners();
      debugPrint('TtsService notified listeners of state change');
    }
  }

  // Dispose of the TTS service
  @override
  void dispose() {
    flutterTts.stop();
    _rateChangeDebouncer?.cancel();
    debugPrint('TtsService disposed');
    super.dispose();
  }
}
