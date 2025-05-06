import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceSelector {
  // Set the TTS language based on the detected language code
  Future<void> setLanguage(FlutterTts flutterTts, String languageCode,
      List<dynamic> languages) async {
    try {
      debugPrint('Available languages: $languages');

      if (languages.contains(languageCode)) {
        await flutterTts.setLanguage(languageCode);
        debugPrint('Set TTS language to: $languageCode');
      } else if (languages.contains('en-US')) {
        await flutterTts.setLanguage('en-US');
        debugPrint('Fallback to en-US language');
      } else if (languages.contains('id-ID')) {
        await flutterTts.setLanguage('id-ID');
        debugPrint('Fallback to id-ID language');
      }
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  // Select an appropriate voice for the specified language
  Future<void> selectVoiceForLanguage(
      FlutterTts flutterTts, String languageCode, List<dynamic> voices) async {
    try {
      debugPrint('Available voices: $voices');

      var filteredVoices =
          voices.where((voice) => voice['locale'] == languageCode).toList();

      if (filteredVoices.isNotEmpty) {
        var maleVoice = filteredVoices.firstWhere(
          (voice) =>
              voice['name'].toLowerCase().contains('male') ||
              voice['name'].contains('Wavenet-B') ||
              voice['name'].contains('Standard-B') ||
              voice['name'].contains('Wavenet-D'),
          orElse: () => filteredVoices.first,
        );

        await flutterTts.setVoice({
          'name': maleVoice['name'],
          'locale': maleVoice['locale'],
        });

        debugPrint('Selected voice for $languageCode: ${maleVoice['name']}');
      } else {
        debugPrint(
            'No voices found for language: $languageCode, using system default');
      }
    } catch (e) {
      debugPrint('Error selecting voice: $e');
    }
  }
}
