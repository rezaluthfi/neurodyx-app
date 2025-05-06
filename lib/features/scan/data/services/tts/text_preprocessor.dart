import 'package:flutter/foundation.dart';

class TextPreprocessor {
  // Cleans and formats text to make it suitable for TTS
  String cleanTextForTts(String text, String languageCode) {
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'([.!?,;:])(?!\s)'), r'$1 ');

    // Remove non-alphanumeric characters at the end of the text
    cleaned = cleaned.replaceAll(RegExp(r'[^a-zA-Z\s]+$'), '');

    if (languageCode == 'id-ID') {
      // Split sentences based on periods
      final sentences =
          cleaned.split('.').where((s) => s.trim().isNotEmpty).toList();
      if (sentences.isNotEmpty) {
        // Replace middle periods with commas, remove period at the end
        cleaned = sentences.asMap().entries.map((entry) {
          int idx = entry.key;
          String sentence = entry.value.trim();
          return idx < sentences.length - 1 ? '$sentence, ' : sentence;
        }).join();
      }
      // Ensure no periods or numbers at the end of the text
      cleaned = cleaned.replaceAll(RegExp(r'[.0-9]+$'), '');
    } else {
      // For English, remove periods and numbers at the end
      cleaned = cleaned.replaceAll(RegExp(r'[.0-9]+$'), '');
    }

    cleaned = cleaned.replaceAll(RegExp(r'[$]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[#@&*\\|"\' '`~<>{}]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\[\]]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\^_]'), '');

    if (languageCode == 'id-ID') {
      cleaned = cleaned.replaceAll('/', ' per ');
      cleaned = cleaned.replaceAll('%', ' persen ');
      cleaned = cleaned.replaceAll('=', ' sama dengan ');
      cleaned = cleaned.replaceAll('+', ' plus ');
      cleaned = cleaned.replaceAll('-', ' minus ');
    } else {
      cleaned = cleaned.replaceAll('/', ' divided by ');
      cleaned = cleaned.replaceAll('%', ' percent ');
      cleaned = cleaned.replaceAll('=', ' equals ');
      cleaned = cleaned.replaceAll('+', ' plus ');
      cleaned = cleaned.replaceAll('-', ' minus ');
    }

    debugPrint('Cleaned text for TTS: $cleaned');
    return cleaned.trim();
  }
}
