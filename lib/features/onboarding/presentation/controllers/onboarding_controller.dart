import 'package:flutter/material.dart';
import '../../data/models/onboarding_model.dart';

class OnboardingController {
  final PageController pageController = PageController();
  final List<OnboardingModel> pages = OnboardingModel.getOnboardingData();
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

  void nextPage() {
    if (currentPageNotifier.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void updatePage(int page) {
    currentPageNotifier.value = page;
  }

  void dispose() {
    pageController.dispose();
    currentPageNotifier.dispose();
  }
}
