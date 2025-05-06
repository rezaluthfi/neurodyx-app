import 'package:flutter/foundation.dart';

class LanguageDetector {
  // Detects the likely language of the input text
  // Returns language code 'en-US' or 'id-ID'
  String detectLanguage(String text) {
    if (text.isEmpty) {
      debugPrint('Empty text, using default language: en-US');
      return 'en-US';
    }

    final englishWords = [
      'the',
      'and',
      'to',
      'of',
      'in',
      'is',
      'that',
      'for',
      'it',
      'with',
      'as',
      'was',
      'on',
      'are',
      'this',
      'be',
      'at',
      'by',
      'have',
      'from',
      'not',
      'or',
      'but',
      'what',
      'all',
      'when',
      'we',
      'you',
      'an',
      'your',
      'can',
      'will',
      'if',
      'my',
      'one',
      'our',
      'they',
      'their',
      'about',
      'out',
      'up',
      'there',
      'so',
      'some',
      'like',
      'time',
      'no',
      'just',
      'his',
      'her',
      'them',
      'would',
      'make',
      'now',
      'has',
      'been'
    ];

    final indonesianWords = [
      'yang',
      'dan',
      'di',
      'dengan',
      'untuk',
      'tidak',
      'ini',
      'itu',
      'dari',
      'dalam',
      'akan',
      'pada',
      'juga',
      'saya',
      'ke',
      'bisa',
      'ada',
      'oleh',
      'kita',
      'adalah',
      'mengenai',
      'karena',
      'sebagai',
      'kamu',
      'mereka',
      'harus',
      'sudah',
      'saat',
      'seperti',
      'dapat',
      'kami',
      'kepada',
      'telah',
      'atau',
      'jalan',
      'sedang',
      'baru',
      'tapi',
      'maka',
      'tentang',
      'bila',
      'jika',
      'sini',
      'sana',
      'mau',
      'nya',
      'anda',
      'pun',
      'bukan',
      'kalau',
      'belum'
    ];

    final words = text
        .toLowerCase()
        .split(RegExp(r"[^\w']+"))
        .where((word) => word.isNotEmpty)
        .toList();

    int indonesianCount = 0;
    int englishCount = 0;

    for (final word in words) {
      if (indonesianWords.contains(word)) {
        indonesianCount++;
      }
      if (englishWords.contains(word)) {
        englishCount++;
      }
    }

    debugPrint('Language detection: EN=$englishCount, ID=$indonesianCount');

    if (englishCount > indonesianCount) {
      return 'en-US';
    } else if (indonesianCount > 0) {
      return 'id-ID';
    } else {
      final idChars = ['ñ', 'ă', 'ț', 'ș', 'j', 'w', 'y'];
      int idCharCount = 0;
      final enChars = ['x', 'q', 'z', 'w'];
      int enCharCount = 0;

      for (int i = 0; i < text.length; i++) {
        String char = text[i].toLowerCase();
        if (idChars.contains(char)) {
          idCharCount++;
        }
        if (enChars.contains(char)) {
          enCharCount++;
        }
      }

      debugPrint('Character analysis: ID=$idCharCount, EN=$enCharCount');

      final idSuffixes = ['nya', 'kan', 'lah', 'kah', 'pun'];
      int idSuffixCount = 0;

      for (final word in words) {
        for (final suffix in idSuffixes) {
          if (word.length > suffix.length && word.endsWith(suffix)) {
            idSuffixCount++;
            break;
          }
        }
      }

      debugPrint('Indonesian suffix count: $idSuffixCount');

      if (idCharCount > enCharCount || idSuffixCount > 0) {
        return 'id-ID';
      } else if (enCharCount > 0) {
        return 'en-US';
      } else {
        double avgWordLength = words.isEmpty
            ? 0
            : words.fold<int>(0, (sum, word) => sum + word.length) /
                words.length;
        debugPrint('Average word length: $avgWordLength');
        return avgWordLength < 5.0 ? 'en-US' : 'id-ID';
      }
    }
  }
}
