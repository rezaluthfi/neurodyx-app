import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';

class ShimmerCard extends StatelessWidget {
  final bool isSquare;
  final bool showProgress;

  const ShimmerCard({
    super.key,
    this.isSquare = false,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey.withOpacity(0.2),
      highlightColor: AppColors.grey.withOpacity(0.1),
      child: Card(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: isSquare
            ? AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 100,
                        height: 16,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 16,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 14,
                            color: AppColors.grey,
                          ),
                          if (showProgress) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 8,
                              color: AppColors.grey,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
