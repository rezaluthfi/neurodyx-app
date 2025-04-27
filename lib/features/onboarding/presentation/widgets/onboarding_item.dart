import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/onboarding_model.dart';

class OnboardingItem extends StatelessWidget {
  final OnboardingModel model;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingItem({
    super.key,
    required this.model,
    required this.isLastPage,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Image overlapping the white container
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // White container with text and buttons
              Container(
                height: 420,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 180),
                padding: const EdgeInsets.fromLTRB(32, 88, 32, 32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          model.title,
                          style: AppTextStyles.heading,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          model.description,
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button
                        CustomButton(
                          text: 'Skip',
                          onPressed: onSkip,
                          isPrimary: false,
                        ),
                        CustomButton(
                          onPressed: onNext,
                          isPrimary: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Next',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                AssetPath.iconArrowRight,
                                height: 16,
                                width: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Image on top of the white container
              Positioned(
                top: 0,
                child: SizedBox(
                  height: 220,
                  width: 320,
                  child: Image.asset(
                    model.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
