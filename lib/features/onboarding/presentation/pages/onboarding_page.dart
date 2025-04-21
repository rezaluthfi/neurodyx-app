import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_item.dart';
import '../widgets/final_onboarding_screen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final OnboardingController _controller = OnboardingController();
  bool _showFinalScreen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller.currentPageNotifier,
      builder: (context, currentPage, _) {
        final isLastPage = currentPage == _controller.pages.length - 1;

        // If we're showing the final screen
        if (_showFinalScreen) {
          return FinalOnboardingScreen(
            onCreateAccount: () {
              // Navigate to create account page
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CreateAccountPage()));
            },
            onLogin: () {
              // Navigate to login page
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          );
        }

        // Get the background color for the current page
        final backgroundColor = _controller.pages[currentPage].backgroundColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Page indicator
                SmoothPageIndicator(
                  controller: _controller.pageController,
                  count: _controller.pages.length,
                  effect: CustomizableEffect(
                    activeDotDecoration: DotDecoration(
                      width: 56,
                      height: 4,
                      color: AppColors.indicator,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    dotDecoration: DotDecoration(
                      width: 56,
                      height: 4,
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    spacing: 4,
                  ),
                ),
                const SizedBox(height: 32),
                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _controller.pageController,
                    itemCount: _controller.pages.length,
                    onPageChanged: _controller.updatePage,
                    itemBuilder: (context, index) {
                      return OnboardingItem(
                        model: _controller.pages[index],
                        isLastPage: index == _controller.pages.length - 1,
                        onNext: isLastPage
                            ? () {
                                // Show final screen when Next is pressed on last page
                                setState(() {
                                  _showFinalScreen = true;
                                });
                              }
                            : _controller.nextPage,
                        onSkip: () {
                          // Show final screen when Skip is pressed
                          setState(() {
                            _showFinalScreen = true;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
