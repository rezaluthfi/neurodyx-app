import 'package:flutter/material.dart';
import 'dart:io';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/scan/presentation/widgets/dyslexia_info_dialog.dart';
import 'package:neurodyx/features/scan/presentation/widgets/text_customization_settings.dart';
import 'package:neurodyx/features/scan/presentation/widgets/font_utils.dart';
import 'package:provider/provider.dart';

class ScanPage extends StatefulWidget {
  final ValueNotifier<bool> hideNavBarNotifier;
  final VoidCallback? onClearMedia;

  const ScanPage({
    super.key,
    required this.hideNavBarNotifier,
    this.onClearMedia,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('ScanPage initState');
    _scrollController.addListener(() {
      debugPrint('Scroll position: ${_scrollController.position.pixels}');
    });
  }

  @override
  void dispose() {
    debugPrint('ScanPage dispose');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ScanPage build');
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        debugPrint('Consumer rebuild, isProcessing: ${provider.isProcessing}');
        return Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: provider.selectedMedia != null
              ? AppBar(
                  backgroundColor: AppColors.offWhite,
                  elevation: 0,
                  title: const Text(
                    'Scan Result',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.primary),
                      onPressed: () {
                        provider.clearMedia();
                        widget.onClearMedia?.call();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : AppBar(
                  backgroundColor: AppColors.offWhite,
                  elevation: 0,
                  title: const Text(
                    'Scan Text',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          body: SafeArea(
            child: GlowingOverscrollIndicator(
              showLeading: false,
              showTrailing: false,
              axisDirection: AxisDirection.down,
              color: Colors.transparent,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    if (provider.selectedMedia == null)
                      _buildInitialUI(context),
                    if (provider.selectedMedia != null)
                      _buildResultsUI(context),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar:
              provider.selectedMedia != null ? _buildInfoBar(context) : null,
        );
      },
    );
  }

  Widget _buildInfoBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Customize text display to make reading easier',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => showDyslexiaInfoDialog(context),
            child: const Text(
              'Learn More',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialUI(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 72, color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Scan Text',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Use the scan button below to capture text from images or documents.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ),
          SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildResultsUI(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);
    debugPrint(
        'Building _buildResultsUI, isProcessing: ${provider.isProcessing}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          debugPrint(
              'LayoutBuilder constraints: ${constraints.maxWidth}x${constraints.maxHeight}');
          if (provider.isProcessing) {
            return _buildProcessingIndicator();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImagePreview(context, constraints),
              ),
              const SizedBox(height: 16),
              const Text(
                'Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (provider.scanEntity.extractedText != null &&
                  provider.scanEntity.extractedText!.isNotEmpty)
                Container(
                  width: constraints.maxWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: provider.scanEntity.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey.withOpacity(0.2)),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.5,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        provider.scanEntity.extractedText!,
                        style: getTextStyle(provider.scanEntity),
                      ),
                    ),
                  ),
                ),
              if (provider.selectedMedia != null &&
                  (provider.scanEntity.extractedText == null ||
                      provider.scanEntity.extractedText!.isEmpty))
                Container(
                  width: constraints.maxWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'No text detected in the image. Try another image.',
                    style: TextStyle(fontSize: 16, color: AppColors.grey),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: provider.isTtsPlaying ? Icons.stop : Icons.play_arrow,
                    label: 'Audio',
                    onPressed: () => provider.readTextAloud(context),
                  ),
                  _buildActionButton(
                    icon: Icons.download,
                    label: 'Save',
                    onPressed: () => provider.saveText(context),
                  ),
                  _buildActionButton(
                    icon: Icons.text_fields,
                    label: 'Customize',
                    onPressed: () => showTextCustomizationSettings(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TTS Speed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: provider.speechRate,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: provider.speechRate.toStringAsFixed(1),
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.grey.withOpacity(0.3),
                            onChanged: (value) {
                              provider.setSpeechRate(value, context: context);
                            },
                          ),
                        ),
                        if (provider.isSettingSpeechRate)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      'Speed: ${provider.speechRate.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Processing text recognition...',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we analyze your image',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, BoxConstraints constraints) {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    debugPrint(
        'Building image preview, selectedMedia: ${provider.selectedMedia}');
    return ValueListenableBuilder<File?>(
      valueListenable: ValueNotifier<File?>(provider.selectedMedia),
      builder: (context, selectedMedia, _) {
        if (selectedMedia != null) {
          final imageWidget = Image.file(
            selectedMedia,
            key: ValueKey(selectedMedia.path), // Ensure widget persistence
            fit: BoxFit.cover,
            width: constraints.maxWidth,
            height: 250,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Image error: $error');
              return Container(
                width: constraints.maxWidth,
                height: 250,
                color: AppColors.grey.withOpacity(0.2),
                child: const Center(
                  child: Text(
                    'Error loading image',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              );
            },
          );

          return SizedBox(
            width: constraints.maxWidth,
            height: 250,
            child: Stack(
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: imageWidget,
                ),
                if (provider.isProcessing)
                  Container(
                    width: constraints.maxWidth,
                    height: 250,
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 30,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black54,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    onPressed: () => _showFullScreenImage(context),
                    tooltip: 'View Fullscreen',
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          width: constraints.maxWidth,
          height: 200,
          color: AppColors.grey.withOpacity(0.2),
          child: const Center(child: Text('No image selected.')),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    if (provider.selectedMedia == null) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    provider.selectedMedia!,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
