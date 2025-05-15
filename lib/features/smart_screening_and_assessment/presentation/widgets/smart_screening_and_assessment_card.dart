import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SmartScreeningAndAssessmentCard extends StatelessWidget {
  final Color? backgroundColor;
  final String? title;
  final String? description;
  final VoidCallback onTap;
  final String? emoji;
  final String? imageAsset;
  final String? label;
  final bool isSquare;

  const SmartScreeningAndAssessmentCard({
    super.key,
    this.backgroundColor,
    this.title,
    this.description,
    required this.onTap,
    this.emoji,
    this.imageAsset,
    this.label,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    // For category page style (with image or emoji)
    if (imageAsset != null || emoji != null) {
      return GestureDetector(
        onTap: onTap,
        child: Card(
          color: AppColors.white,
          elevation: 0,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: AspectRatio(
            aspectRatio: 1, // This ensures the card is always square
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use image if provided, otherwise use emoji
                  imageAsset != null
                      ? Image.asset(
                          imageAsset!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          emoji!,
                          style: const TextStyle(
                            fontSize: 48,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 12),
                  Text(
                    label!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // For smart screening page style
    return Card(
      color: backgroundColor ?? AppColors.primary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description ?? '',
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onTap,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'START',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
