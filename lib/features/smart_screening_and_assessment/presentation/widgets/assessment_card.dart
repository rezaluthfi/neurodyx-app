import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AssessmentCard extends StatelessWidget {
  final String title;
  final String icon;
  final String score;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;
  final bool showProgress;
  final bool showArrow;

  const AssessmentCard({
    super.key,
    required this.title,
    required this.icon,
    required this.score,
    required this.status,
    required this.statusColor,
    required this.onTap,
    this.showProgress = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowScreen = constraints.maxWidth < 360;
        final iconSize = isNarrowScreen ? 40.0 : 48.0;
        final arrowSize = isNarrowScreen ? 36.0 : 40.0;
        final fontSize = isNarrowScreen ? 12.0 : 14.0;
        final padding = isNarrowScreen ? 12.0 : 16.0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: TextStyle(fontSize: iconSize * 0.5),
                          ),
                        ),
                      ),
                      SizedBox(width: isNarrowScreen ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: isNarrowScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (!showProgress) ...[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Score: ',
                                        style: TextStyle(
                                          color: AppColors.textPrimary
                                              .withOpacity(0.7),
                                          fontSize: fontSize,
                                        ),
                                      ),
                                      Text(
                                        score,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: TextStyle(
                                        color: AppColors.textPrimary
                                            .withOpacity(0.7),
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: fontSize,
                                            // Removed bold
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (showArrow) ...[
                        SizedBox(width: isNarrowScreen ? 8 : 12),
                        Container(
                          width: arrowSize,
                          height: arrowSize,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primary,
                              size: isNarrowScreen ? 18 : 22,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showProgress) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Result', // Changed from 'Progress'
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    score,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _calculateProgress(score),
                                  backgroundColor:
                                      AppColors.grey.withOpacity(0.2),
                                  color: _getProgressColor(
                                      _calculateProgress(score)),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateProgress(String scoreText) {
    try {
      final parts = scoreText.split('/');
      if (parts.length == 2) {
        final current = double.tryParse(parts[0]) ?? 0;
        final total = double.tryParse(parts[1]) ?? 1;
        return current / total;
      }
    } catch (e) {
      // Handle parsing errors
    }
    return 0.0;
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.4) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
