import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/scan/presentation/widgets/dyslexia_info_dialog.dart';
import 'package:neurodyx/features/scan/presentation/widgets/text_customization_settings.dart';
import 'package:provider/provider.dart';

class ScanPage extends StatelessWidget {
  final ValueNotifier<bool> hideNavBarNotifier;

  const ScanPage({super.key, required this.hideNavBarNotifier});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.offWhite,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  if (provider.selectedMedia == null) _buildInitialUI(context),
                  if (provider.selectedMedia != null) _buildResultsUI(context),
                ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 72, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Scan Text',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Tap to scan text from images or documents',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => _pickImage(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text(
              'Start Scanning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsUI(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scan Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.grey),
                onPressed: provider.clearScan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImagePreview(context),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Extracted Text',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildQuickCustomizeButtons(context),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextResultView(context),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.copy,
                label: 'Copy',
                onPressed: () => provider.copyText(context),
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () => provider.shareText(context),
              ),
              _buildActionButton(
                icon: Icons.text_fields,
                label: 'Customize',
                onPressed: () => showTextCustomizationSettings(context),
              ),
            ],
          ),
          const SizedBox(height: 40),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);
    if (provider.selectedMedia != null) {
      return SizedBox(
        width: double.infinity,
        height: 250,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                provider.selectedMedia!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
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
      width: double.infinity,
      height: 200,
      color: AppColors.grey.withOpacity(0.2),
      child: const Center(child: Text('No image selected.')),
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

  Widget _buildTextResultView(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);
    if (provider.isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (provider.scanEntity.extractedText != null &&
        provider.scanEntity.extractedText!.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: provider.scanEntity.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        ),
        child: Text(
          provider.scanEntity.extractedText!,
          style: TextStyle(
            fontSize: provider.scanEntity.fontSize,
            color: provider.scanEntity.textColor,
            fontFamily: provider.scanEntity.fontFamily,
            fontWeight: provider.scanEntity.isBold
                ? FontWeight.bold
                : FontWeight.normal,
            letterSpacing: provider.scanEntity.characterSpacing,
            wordSpacing: provider.scanEntity.wordSpacing,
            height: provider.scanEntity.lineHeight,
          ),
        ),
      );
    }
    if (provider.selectedMedia != null) {
      return Container(
        width: double.infinity,
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
    return const SizedBox.shrink();
  }

  Widget _buildQuickCustomizeButtons(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.text_decrease, size: 20),
          onPressed: () {
            if (provider.scanEntity.fontSize > 12) {
              provider.updateTextCustomization(
                  fontSize: provider.scanEntity.fontSize - 2);
            }
          },
          tooltip: 'Decrease Font Size',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.text_increase, size: 20),
          onPressed: () => provider.updateTextCustomization(
              fontSize: provider.scanEntity.fontSize + 2),
          tooltip: 'Increase Font Size',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.format_bold, size: 20),
          onPressed: () => provider.updateTextCustomization(
              isBold: !provider.scanEntity.isBold),
          color:
              provider.scanEntity.isBold ? AppColors.primary : AppColors.grey,
          tooltip: 'Toggle Bold',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.pickImage(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
