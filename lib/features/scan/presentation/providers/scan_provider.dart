import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
    debugPrint(
        'TtsService changed: playing=${ttsService.isTtsPlaying}, initializing=${ttsService.isTtsInitializing}');
    if (!ttsService.isTtsPlaying && !ttsService.isTtsInitializing) {
      debugPrint('TTS completed, notifying listeners to update UI');
    }
    // Safely notify listeners
    _safeNotifyListeners();
  }

  // Helper to safely notify listeners, avoiding UI freezes
  void _safeNotifyListeners() {
    try {
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error in notifyListeners: $e\n$stackTrace');
    }
  }

  // Method to request permissions for camera or gallery
  Future<bool> requestPermissions(
      BuildContext context, ImageSource source) async {
    // Store a local variable for context to avoid issues if widget is disposed
    final currentContext = context;

    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    // Check current permission status
    PermissionStatus status = await permission.status;
    debugPrint('Permission ${permission.toString()} status: $status');
    if (status.isGranted) {
      return true;
    }

    // Request permission with error handling
    try {
      status = await permission.request();
      debugPrint('Permission ${permission.toString()} request result: $status');
    } catch (e, stackTrace) {
      debugPrint(
          'Error requesting permission ${permission.toString()}: $e\n$stackTrace');
      // Check if context is still valid before using ScaffoldMessenger
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(
                'Error requesting ${source == ImageSource.camera ? "camera" : "gallery"} permission: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    // Handle denied or permanently denied cases
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint(
          'Permission ${permission.toString()} ${status.isPermanentlyDenied ? "permanently denied" : "denied"}');
      if (status.isPermanentlyDenied && currentContext.mounted) {
        try {
          await showDialog(
            context: currentContext,
            barrierDismissible: false, // Prevent dismissal by tapping outside
            builder: (dialogContext) => AlertDialog(
              title: const Text('Permission Required'),
              content: Text(
                'The ${source == ImageSource.camera ? "camera" : "gallery"} permission is required. Please enable it in settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        } catch (e) {
          debugPrint('Error showing permission dialog: $e');
        }
      }
      return false;
    }

    return status.isGranted;
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    // Prevent concurrent operations
    if (_isProcessing) {
      debugPrint('Already processing, ignoring pickImage request');
      return;
    }

    // Ensure a valid ScaffoldMessenger context
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Check and request permissions
    bool hasPermission = await requestPermissions(context, source);
    if (!hasPermission) {
      debugPrint('Permission denied for $source');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Permission denied for ${source == ImageSource.camera ? "camera" : "gallery"}. Please enable it in settings.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () async {
              await openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    try {
      debugPrint('Attempting to pick image from $source');
      _isProcessing = true;
      _safeNotifyListeners();

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        debugPrint('Image picked: ${pickedFile.path}');
        // Validate file existence
        final file = File(pickedFile.path);
        if (await file.exists()) {
          debugPrint('File exists: ${pickedFile.path}');
          _selectedMedia = file;
          debugPrint('isProcessing set to true');
          hideNavBarNotifier.value = true;
          _safeNotifyListeners();

          debugPrint('Starting text extraction');
          final entity =
              await scanRepository.extractTextFromImage(_selectedMedia!);
          debugPrint('Text extraction completed: ${entity.extractedText}');
          _scanEntity =
              _scanEntity.copyWith(extractedText: entity.extractedText);
          _isProcessing = false;
          debugPrint('isProcessing set to false');
          _safeNotifyListeners();
        } else {
          debugPrint('File does not exist: ${pickedFile.path}');
          CustomSnackBar.show(
            context,
            message: 'File does not exist. Please try again.',
            type: SnackBarType.error,
          );
          _isProcessing = false;
          hideNavBarNotifier.value = false;
          _safeNotifyListeners();
        }
      } else {
        debugPrint('No image picked from $source');
        _isProcessing = false;
        hideNavBarNotifier.value = false;
        _safeNotifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing image from $source: $e\n$stackTrace');
      _isProcessing = false;
      hideNavBarNotifier.value = false;
      _safeNotifyListeners();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error processing image: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
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
    _safeNotifyListeners();
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
    _safeNotifyListeners();
  }

  void resetTextCustomization() {
    _scanEntity = ScanEntity(
      fontFamily: fontProvider.selectedFont == 'Lexend Exa'
          ? 'Lexend Exa'
          : 'OpenDyslexicMono',
      extractedText: _scanEntity.extractedText,
    );
    _safeNotifyListeners();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to read!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void setSpeechRate(double rate, {BuildContext? context}) {
    ttsService.setSpeechRate(rate, context: context);
    _safeNotifyListeners();
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
