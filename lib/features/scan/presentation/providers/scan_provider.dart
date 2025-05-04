import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
    // Initialize ScanEntity with font from FontProvider
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
    );
  }

  File? _selectedMedia;
  late ScanEntity _scanEntity;
  bool _isProcessing = false;

  File? get selectedMedia => _selectedMedia;
  ScanEntity get scanEntity => _scanEntity;
  bool get isProcessing => _isProcessing;

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      _selectedMedia = File(pickedFile.path);
      _isProcessing = true;
      hideNavBarNotifier.value = true;
      notifyListeners();

      final entity = await scanRepository.extractTextFromImage(_selectedMedia!);
      _scanEntity = _scanEntity.copyWith(extractedText: entity.extractedText);
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearScan() {
    _selectedMedia = null;
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
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
    );
    notifyListeners();
  }

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
}
