import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neurodyx/core/providers/font_providers.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/scan/data/services/text_action_service.dart';
import 'package:neurodyx/features/scan/data/services/tts_service.dart';
import 'package:neurodyx/features/scan/domain/entities/scan_entity.dart';
import 'package:neurodyx/features/scan/domain/repositories/scan_repository_base.dart';

class ScanProvider extends ChangeNotifier {
  final ScanRepositoryBase scanRepository;
  final ValueNotifier<bool> hideNavBarNotifier;
  final FontProvider fontProvider;
  final TtsService ttsService;
  final TextActionService textActionService;

  ScanProvider({
    required this.scanRepository,
    required this.hideNavBarNotifier,
    required this.fontProvider,
    required this.ttsService,
    required this.textActionService,
  }) {
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
    );
    // Listen for changes in TtsService
    ttsService.addListener(_onTtsServiceChanged);
  }

  File? _selectedMedia;
  late ScanEntity _scanEntity;
  bool _isProcessing = false;

  File? get selectedMedia => _selectedMedia;
  ScanEntity get scanEntity => _scanEntity;
  bool get isProcessing => _isProcessing;
  bool get isTtsPlaying => ttsService.isTtsPlaying;
  bool get isTtsInitializing => ttsService.isTtsInitializing;
  double get speechRate => ttsService.speechRate;
  bool get isSettingSpeechRate => ttsService.isSettingSpeechRate;

  void _onTtsServiceChanged() {
    debugPrint('TtsService changed, isTtsPlaying: ${ttsService.isTtsPlaying}, '
        'isTtsInitializing: ${ttsService.isTtsInitializing}');
    notifyListeners();
  }

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

  void clearMedia() {
    debugPrint('clearMedia called');
    stopTtsIfPlaying();

    _selectedMedia = null;
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
      extractedText: _scanEntity.extractedText,
    );
    _isProcessing = false;
    hideNavBarNotifier.value = false;
    notifyListeners();
  }

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

  void resetTextCustomization() {
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
      extractedText: _scanEntity.extractedText,
    );
    notifyListeners();
  }

  Future<void> stopTtsIfPlaying() async {
    if (ttsService.isTtsPlaying) {
      debugPrint('Stopping TTS from ScanProvider');
      await ttsService.stopTts();
    }
  }

  Future<void> readTextAloud(BuildContext context) async {
    if (_scanEntity.extractedText != null &&
        _scanEntity.extractedText!.isNotEmpty) {
      await ttsService.readTextAloud(context, _scanEntity.extractedText!);
    } else {
      CustomSnackBar.show(
        context,
        message: 'No text to read!',
        type: SnackBarType.error,
      );
    }
  }

  void setSpeechRate(double rate, {BuildContext? context}) {
    ttsService.setSpeechRate(rate, context: context);
    notifyListeners();
  }

  Future<void> saveText(BuildContext context) async {
    await textActionService.saveText(context, _scanEntity.extractedText);
  }

  @override
  void dispose() {
    stopTtsIfPlaying();
    ttsService.removeListener(_onTtsServiceChanged);
    ttsService.dispose();
    super.dispose();
  }
}
