import 'dart:io';
import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/scan/presentation/widgets/scan_fullscreen_image.dart';
import 'package:provider/provider.dart';

class ScanImagePreview extends StatelessWidget {
  final BoxConstraints constraints;

  const ScanImagePreview({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    debugPrint(
        'Building ScanImagePreview, selectedMedia: ${provider.selectedMedia}');
    return ValueListenableBuilder<File?>(
      valueListenable: ValueNotifier<File?>(provider.selectedMedia),
      builder: (context, selectedMedia, _) {
        if (selectedMedia != null) {
          final imageWidget = Image.file(
            selectedMedia,
            key: ValueKey(selectedMedia.path),
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Image Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: constraints.maxWidth,
                height: 250,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft:
                            Radius.circular(16), // Membulatkan sudut kiri atas
                        topRight:
                            Radius.circular(16), // Membulatkan sudut kanan atas
                      ),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: imageWidget,
                      ),
                    ),
                    if (provider.isProcessing)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Container(
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
                      ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 32,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black54,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        onPressed: () =>
                            ScanFullscreenImage.show(context, selectedMedia),
                        tooltip: 'View Fullscreen',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Container(
            width: constraints.maxWidth,
            height: 200,
            color: AppColors.grey.withOpacity(0.2),
            child: const Center(child: Text('No image selected.')),
          );
        }
      },
    );
  }
}
