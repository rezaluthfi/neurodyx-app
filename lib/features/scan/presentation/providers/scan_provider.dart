import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:neurodyx/core/providers/font_providers.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/scan/domain/entities/scan_entity.dart';
import 'package:neurodyx/features/scan/domain/repositories/scan_repository_base.dart';
import 'package:share_plus/share_plus.dart';

class ScanProvider extends ChangeNotifier {
  final ScanRepositoryBase scanRepository;
  final ValueNotifier<bool> hideNavBarNotifier;
  final FontProvider fontProvider;

  ScanProvider({
    required this.scanRepository,
    required this.hideNavBarNotifier,
    required this.fontProvider,
  }) {
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
    );
    _initTts();
  }

  File? _selectedMedia;
  late ScanEntity _scanEntity;
  bool _isProcessing = false;
  late FlutterTts flutterTts;
  bool _isTtsPlaying = false;
  double _speechRate = 0.4;
  String? _currentTtsText;
  bool _isSettingSpeechRate = false;
  Timer? _debounceTimer;
  String _detectedLanguage = 'en-US'; // Default language set to English

  File? get selectedMedia => _selectedMedia;
  ScanEntity get scanEntity => _scanEntity;
  bool get isProcessing => _isProcessing;
  bool get isTtsPlaying => _isTtsPlaying;
  double get speechRate => _speechRate;
  bool get isSettingSpeechRate => _isSettingSpeechRate;
  String get detectedLanguage => _detectedLanguage;

  // Initialize Text-to-Speech (TTS)
  void _initTts() async {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      _isTtsPlaying = true;
      notifyListeners();
    });

    flutterTts.setCompletionHandler(() {
      _isTtsPlaying = false;
      _currentTtsText = null;
      notifyListeners();
    });

    flutterTts.setCancelHandler(() {
      _isTtsPlaying = false;
      notifyListeners();
    });

    flutterTts.setErrorHandler((msg) {
      _isTtsPlaying = false;
      _currentTtsText = null;
      print('TTS Error: $msg');
      notifyListeners();
    });

    try {
      await flutterTts.getLanguages;
      await flutterTts.setVolume(1.0);
      await flutterTts.setSpeechRate(_speechRate);
      await flutterTts.setPitch(1.0);

      // Initialize with default language
      await _setLanguage(_detectedLanguage);

      print('TTS initialized successfully');
    } catch (e) {
      print('TTS Initialization Error: $e');
    }
  }

  // Detect language from text
  String _detectLanguage(String text) {
    // If text is empty, use default language
    if (text.isEmpty) {
      print('Empty text, using default language: en-US');
      return 'en-US';
    }

    // Common words in English
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

    // Common words in Indonesian
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

    // Count word frequencies
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

    print('Language detection: EN=$englishCount, ID=$indonesianCount');

    // Determine language based on word frequency
    if (englishCount > indonesianCount) {
      return 'en-US';
    } else if (indonesianCount > 0) {
      return 'id-ID';
    } else {
      // If no common words detected, use character analysis
      final idChars = ['ñ', 'ă', 'ă', 'ă', 'ț', 'ș', 'j', 'w', 'y'];
      int idCharCount = 0;

      final enChars = ['x', 'q', 'z', 'w'];
      int enCharCount = 0;

      // Count character frequencies
      for (int i = 0; i < text.length; i++) {
        String char = text[i].toLowerCase();
        if (idChars.contains(char)) {
          idCharCount++;
        }
        if (enChars.contains(char)) {
          enCharCount++;
        }
      }

      print('Character analysis: ID=$idCharCount, EN=$enCharCount');

      // Detect using word suffixes
      final idSuffixes = ['nya', 'kan', 'lah', 'kah', 'pun'];
      int idSuffixCount = 0;

      // Check word suffixes
      for (final word in words) {
        for (final suffix in idSuffixes) {
          if (word.length > suffix.length && word.endsWith(suffix)) {
            idSuffixCount++;
            break;
          }
        }
      }

      print('Indonesian suffix count: $idSuffixCount');

      // Make decision based on additional analysis
      if (idCharCount > enCharCount || idSuffixCount > 0) {
        return 'id-ID';
      } else if (enCharCount > 0) {
        return 'en-US';
      } else {
        // Check spacing pattern to differentiate English vs Indonesian phrases
        double avgWordLength = words.isEmpty
            ? 0
            : words.fold<int>(0, (sum, word) => sum + word.length) /
                words.length;

        print('Average word length: $avgWordLength');
        // English tends to have shorter words
        if (avgWordLength < 5.0) {
          return 'en-US';
        } else {
          // Default to English if no other clues
          return 'en-US';
        }
      }
    }
  }

  // Set TTS language
  Future<void> _setLanguage(String languageCode) async {
    try {
      var languages = await flutterTts.getLanguages;
      print('Available languages: $languages');

      // Check if detected language is supported
      if (languages.contains(languageCode)) {
        await flutterTts.setLanguage(languageCode);
        print('Set TTS language to: $languageCode');
      } else if (languages.contains('en-US')) {
        await flutterTts.setLanguage('en-US');
        print('Fallback to en-US language');
      } else if (languages.contains('id-ID')) {
        await flutterTts.setLanguage('id-ID');
        print('Fallback to id-ID language');
      }

      // Set voice based on language
      await _selectVoiceForLanguage(languageCode);
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  // Select voice for the specified language
  Future<void> _selectVoiceForLanguage(String languageCode) async {
    try {
      var voices = await flutterTts.getVoices;
      print('Available voices: $voices');

      // Filter voices based on selected language
      var filteredVoices =
          voices.where((voice) => voice['locale'] == languageCode).toList();

      if (filteredVoices.isNotEmpty) {
        // Prioritize male voice
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

        print('Selected voice for $languageCode: ${maleVoice['name']}');
      } else {
        print(
            'No voices found for language: $languageCode, using system default');
      }
    } catch (e) {
      print('Error selecting voice: $e');
    }
  }

  // Clean text to prevent punctuation being read as "one dollar"
  String _cleanTextForTts(String text) {
    // Normalize spaces
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ');

    // Add space after punctuation for natural pauses
    cleaned = cleaned.replaceAll(RegExp(r'([.!?,;:])(?!\s)'), r'$1 ');

    // Remove dollar signs to prevent misreading
    cleaned = cleaned.replaceAll(RegExp(r'[$]'), '');

    // Handle punctuation based on language
    if (_detectedLanguage == 'id-ID') {
      cleaned = cleaned.replaceAll(RegExp(r'[.]'), ', ');
    } // Keep periods as is for English

    // Remove characters that may be misread
    cleaned = cleaned.replaceAll(RegExp(r'[#@&*\\|"\' '`~<>{}]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\[\]]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\^_]'), '');

    // Replace special characters with words based on language
    if (_detectedLanguage == 'id-ID') {
      cleaned = cleaned.replaceAll('/', ' per ');
      cleaned = cleaned.replaceAll('%', ' percent ');
      cleaned = cleaned.replaceAll('=', ' equals ');
      cleaned = cleaned.replaceAll('+', ' plus ');
      cleaned = cleaned.replaceAll('-', ' minus ');
    } else {
      cleaned = cleaned.replaceAll('/', ' divided by ');
      cleaned = cleaned.replaceAll('%', ' percent ');
      cleaned = cleaned.replaceAll('=', ' equals ');
      cleaned = cleaned.replaceAll('+', ' plus ');
      cleaned = cleaned.replaceAll('-', ' minus ');
    }

    return cleaned.trim();
  }

  // Set speech rate with debouncing
  void setSpeechRate(double rate, {BuildContext? context}) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (_isSettingSpeechRate) {
        print('Speech rate setting in progress, skipping: $rate');
        return;
      }
      _isSettingSpeechRate = true;
      notifyListeners();
      try {
        _speechRate = rate.clamp(0.0, 1.0);
        print('Setting speech rate to: $_speechRate');

        if (_isTtsPlaying) {
          print('Stopping TTS for rate change');
          await flutterTts.stop();
          _isTtsPlaying = false;
          await Future.delayed(const Duration(milliseconds: 200));
        }

        if (_currentTtsText == null) {
          if (_scanEntity.extractedText != null &&
              _scanEntity.extractedText!.isNotEmpty) {
            // Clean text to prevent misreading
            _currentTtsText = _cleanTextForTts(_scanEntity.extractedText!);
            print('Loaded text: $_currentTtsText');
          } else {
            print('No text available to play');
            if (context != null) {
              CustomSnackBar.show(
                context,
                message: 'No text available to play',
                type: SnackBarType.error,
              );
            }
            return;
          }
        }

        await flutterTts.setSpeechRate(_speechRate);
        String textToSpeak = _currentTtsText!;
        print('Restarting TTS: $textToSpeak');

        bool speakSuccess = false;
        for (int attempt = 1; attempt <= 2; attempt++) {
          try {
            await flutterTts.speak(textToSpeak);
            speakSuccess = true;
            break;
          } catch (e) {
            print('Attempt $attempt to speak failed: $e');
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }

        if (speakSuccess) {
          _isTtsPlaying = true;
          print('Restarted TTS with new speech rate: $_speechRate');
        } else {
          print('Failed to restart TTS after 2 attempts');
          if (context != null) {
            CustomSnackBar.show(
              context,
              message: 'Failed to restart audio playback',
              type: SnackBarType.error,
            );
          }
        }
        notifyListeners();
      } catch (e) {
        print('Error in setSpeechRate: $e');
        if (context != null) {
          CustomSnackBar.show(
            context,
            message: 'Error changing speech rate: $e',
            type: SnackBarType.error,
          );
        }
        _isTtsPlaying = false;
      } finally {
        _isSettingSpeechRate = false;
        notifyListeners();
      }
    });
  }

  // Pick image from source
  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      debugPrint('Image picked: ${pickedFile.path}');
      _selectedMedia = File(pickedFile.path);
      _isProcessing = true;
      debugPrint('isProcessing set to true');
      hideNavBarNotifier.value = true;
      notifyListeners();

      try {
        debugPrint('Starting text extraction');
        final entity =
            await scanRepository.extractTextFromImage(_selectedMedia!);
        debugPrint('Text extraction completed: ${entity.extractedText}');
        _scanEntity = _scanEntity.copyWith(extractedText: entity.extractedText);
        _isProcessing = false;
        debugPrint('isProcessing set to false');
        // Keep hideNavBarNotifier true to hide bottom nav during scan results
        notifyListeners();
      } catch (e) {
        debugPrint('Error processing image: $e');
        _isProcessing = false;
        debugPrint('isProcessing set to false due to error');
        hideNavBarNotifier.value = false;
        notifyListeners();
        CustomSnackBar.show(
          context,
          message: 'Error processing image: $e',
          type: SnackBarType.error,
        );
      }
    } else {
      debugPrint('No image picked');
      hideNavBarNotifier.value = false;
      notifyListeners();
    }
  }

  // Clear selected media
  void clearMedia() {
    debugPrint('clearMedia called');
    _selectedMedia = null;
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
      extractedText: _scanEntity.extractedText,
    );
    _isProcessing = false;
    hideNavBarNotifier.value = false;
    if (_isTtsPlaying) {
      flutterTts.stop();
      _isTtsPlaying = false;
      _currentTtsText = null;
    }
    notifyListeners();
  }

  // Update text customization
  void updateTextCustomization({
    double? fontSize,
    double? characterSpacing,
    double? wordSpacing,
    double? lineHeight,
    bool? isBold,
    String? fontFamily,
    Color? textColor,
    Color? backgroundColor,
  }) {
    _scanEntity = _scanEntity.copyWith(
      fontSize: fontSize,
      characterSpacing: characterSpacing,
      wordSpacing: wordSpacing,
      lineHeight: lineHeight,
      isBold: isBold,
      fontFamily: fontFamily,
      textColor: textColor,
      backgroundColor: backgroundColor,
    );
    notifyListeners();
  }

  // Reset text customization
  void resetTextCustomization() {
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
      extractedText: _scanEntity.extractedText,
    );
    notifyListeners();
  }

  // Copy text to clipboard
  void copyText(BuildContext context) {
    if (_scanEntity.extractedText != null &&
        _scanEntity.extractedText!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _scanEntity.extractedText!));
      CustomSnackBar.show(
        context,
        message: 'Text copied to clipboard!',
        type: SnackBarType.success,
      );
    }
  }

  // Share text
  void shareText(BuildContext context) {
    if (_scanEntity.extractedText != null &&
        _scanEntity.extractedText!.isNotEmpty) {
      SharePlus.instance.share(
        ShareParams(text: _scanEntity.extractedText!),
      );
    } else {
      CustomSnackBar.show(
        context,
        message: 'No text to share!',
        type: SnackBarType.error,
      );
    }
  }

  // Read text aloud
  Future<void> readTextAloud(BuildContext context) async {
    if (_scanEntity.extractedText != null &&
        _scanEntity.extractedText!.isNotEmpty) {
      try {
        // Stop TTS if already playing
        if (_isTtsPlaying) {
          print('Stopping TTS');
          await flutterTts.stop();
          _isTtsPlaying = false;
          notifyListeners();
          return;
        }

        // Detect language from scanned text
        _detectedLanguage = _detectLanguage(_scanEntity.extractedText!);
        print('Detected language: $_detectedLanguage');

        // Display detected language to user
        String languageName =
            _detectedLanguage == 'id-ID' ? 'Indonesian' : 'English';
        CustomSnackBar.show(
          context,
          message: 'Using $languageName voice',
          type: SnackBarType.success,
        );

        // Set TTS to use detected language
        await _setLanguage(_detectedLanguage);

        // Clean text to prevent misreading
        String cleanedText = _cleanTextForTts(_scanEntity.extractedText!);
        print('Text to read: $cleanedText');

        _currentTtsText = cleanedText;
        print('Playing TTS: $_currentTtsText in language: $_detectedLanguage');

        await flutterTts.setSpeechRate(_speechRate);

        // Attempt to play TTS with retries
        bool speakSuccess = false;
        for (int attempt = 1; attempt <= 3; attempt++) {
          try {
            await flutterTts.speak(_currentTtsText!);
            speakSuccess = true;
            break;
          } catch (e) {
            print('Attempt $attempt to speak failed: $e');
            // Fallback to English if detected language fails
            if (attempt == 1 && _detectedLanguage == 'id-ID') {
              print('Trying with English language as fallback');
              await _setLanguage('en-US');
              _detectedLanguage = 'en-US';
            } else if (attempt == 2 && _detectedLanguage == 'en-US') {
              print('Trying with Indonesian language as second fallback');
              await _setLanguage('id-ID');
              _detectedLanguage = 'id-ID';
            }
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }

        if (speakSuccess) {
          _isTtsPlaying = true;
          print('Successfully started TTS playback');
        } else {
          print('Failed to start TTS after multiple attempts');
          CustomSnackBar.show(
            context,
            message: 'Failed to start text reading',
            type: SnackBarType.error,
          );
          _currentTtsText = null;
          _isTtsPlaying = false;
        }
        notifyListeners();
      } catch (e) {
        print('Error reading text: $e');
        CustomSnackBar.show(
          context,
          message: 'Error reading text: $e',
          type: SnackBarType.error,
        );
        _currentTtsText = null;
        _isTtsPlaying = false;
        notifyListeners();
      }
    } else {
      CustomSnackBar.show(
        context,
        message: 'No text to read!',
        type: SnackBarType.error,
      );
    }
  }

  // Save text as PDF
  Future<void> saveText(BuildContext context) async {
    if (_scanEntity.extractedText != null &&
        _scanEntity.extractedText!.isNotEmpty) {
      try {
        // Determine storage directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getDownloadsDirectory() ??
              await getApplicationDocumentsDirectory();
        }

        if (!await directory!.exists()) {
          await directory.create(recursive: true);
        }

        // Generate timestamp for unique filename
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final filePath = '${directory.path}/Scan_Result_$timestamp.pdf';

        // Use cleaned text for PDF
        String cleanedText = _scanEntity.extractedText!;

        // Create PDF document
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(
                cleanedText,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ),
        );

        // Save PDF file
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        print('PDF saved to: $filePath');

        // Notify user of success
        CustomSnackBar.show(
          context,
          message: 'PDF saved to $filePath',
          type: SnackBarType.success,
        );
      } catch (e) {
        print('Error saving PDF: $e');
        CustomSnackBar.show(
          context,
          message: 'Error saving PDF: $e',
          type: SnackBarType.error,
        );
      }
    } else {
      CustomSnackBar.show(
        context,
        message: 'No text to save!',
        type: SnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    flutterTts.stop();
    _currentTtsText = null;
    super.dispose();
  }
}
