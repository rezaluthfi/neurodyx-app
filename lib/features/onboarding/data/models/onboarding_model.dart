import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../../../core/constants/assets_path.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingModel extends OnboardingEntity {
  final Color backgroundColor;

  OnboardingModel({
    required super.title,
    required super.description,
    required super.imagePath,
    required this.backgroundColor,
  });

  static List<OnboardingModel> getOnboardingData() {
    return [
      OnboardingModel(
        title: 'Welcome to\nNeurodyx',
        description:
            'A therapy app designed to support and empower individuals with dyslexia',
        imagePath: AssetPath.onboarding1,
        backgroundColor: AppColors.background1,
      ),
      OnboardingModel(
        title: "Let's Understand You Better",
        description: 'Your Therapy Path is Ready!',
        imagePath: AssetPath.onboarding2,
        backgroundColor: AppColors.background2,
      ),
      OnboardingModel(
        title: 'Track Your Progress',
        description:
            'Based on your results, we’ve designed a personalized therapy journey to support you step by step',
        imagePath: AssetPath.onboarding3,
        backgroundColor: AppColors.background3,
      ),
    ];
  }
}
