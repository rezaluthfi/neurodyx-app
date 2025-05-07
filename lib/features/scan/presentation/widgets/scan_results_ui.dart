import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/scan/presentation/widgets/font_utils.dart';
import 'package:neurodyx/features/scan/presentation/widgets/scan_action_button.dart';
import 'package:neurodyx/features/scan/presentation/widgets/scan_image_preview.dart';
import 'package:neurodyx/features/scan/presentation/widgets/scan_processing_indicator.dart';
import 'package:provider/provider.dart';

class ScanResultsUI extends StatefulWidget {
  final VoidCallback onCustomizePressed;

  const ScanResultsUI({super.key, required this.onCustomizePressed});

  @override
  State<ScanResultsUI> createState() => _ScanResultsUIState();
}

class _ScanResultsUIState extends State<ScanResultsUI> {
  late final ScanProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ScanProvider>(context, listen: false);
  }

  @override
  void dispose() {
    provider.stopTtsIfPlaying();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        provider.stopTtsIfPlaying();
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (provider.isProcessing) {
              return const ScanProcessingIndicator();
            }
            return _buildResultContent(context, constraints);
          },
        ),
      ),
    );
  }

  // Builds the main content when scan is not processing.
  Widget _buildResultContent(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Preview
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ScanImagePreview(constraints: constraints),
        ),
        const SizedBox(height: 16),

        // Text Results Title
        const Text(
          'Text Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Extracted Text or No Text Message
        _buildTextResultContainer(constraints),
        const SizedBox(height: 16),

        // Action Buttons
        _buildActionButtons(context),
        const SizedBox(height: 16),

        // TTS Speed Slider
        _buildTtsSpeedControls(context),
        const SizedBox(height: 24),
      ],
    );
  }

  // Builds the container for displaying extracted text or no-text message.
  Widget _buildTextResultContainer(BoxConstraints constraints) {
    final extractedText = provider.scanEntity.extractedText;
    final hasText = extractedText != null && extractedText.isNotEmpty;

    if (provider.selectedMedia != null && !hasText) {
      return Container(
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
      );
    }

    if (hasText) {
      return Container(
        width: constraints.maxWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: provider.scanEntity.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.5),
          child: SingleChildScrollView(
            child: Text(
              extractedText,
              style: getTextStyle(provider.scanEntity),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Builds the row of action buttons (Audio, Save, Customize).
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Consumer<ScanProvider>(
          builder: (context, scanProvider, _) {
            final isTtsPlaying = scanProvider.isTtsPlaying;
            final isTtsInitializing = scanProvider.isTtsInitializing;

            // Tambahkan logging untuk debugging
            debugPrint(
                'Rebuilding Audio Button: Playing=$isTtsPlaying, Initializing=$isTtsInitializing');

            return ScanActionButton(
              iconWidget: isTtsInitializing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Image.asset(
                      isTtsPlaying ? AssetPath.iconPause : AssetPath.iconPlay,
                      width: 24,
                      height: 24,
                    ),
              label: 'Audio',
              onPressed: isTtsInitializing
                  ? null
                  : () => provider.readTextAloud(context),
            );
          },
        ),

        // Customize Button
        ScanActionButton(
          iconWidget: Image.asset(
            AssetPath.iconCustomize,
            width: 24,
            height: 24,
          ),
          label: 'Customize',
          onPressed: () {
            provider.stopTtsIfPlaying();
            widget.onCustomizePressed();
          },
        ),

        // Save Button
        ScanActionButton(
          iconWidget: Image.asset(
            AssetPath.iconDownload,
            width: 24,
            height: 24,
          ),
          label: 'Save',
          onPressed: () => provider.saveText(context),
        ),
      ],
    );
  }

  // Builds the TTS speed control slider and label.
  Widget _buildTtsSpeedControls(BuildContext context) {
    return Padding(
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
                  onChanged: (provider.isSettingSpeechRate ||
                          provider.scanEntity.extractedText == null)
                      ? null
                      : (value) {
                          provider.ttsService.updateSpeechRatePreview(value);
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
    );
  }
}
