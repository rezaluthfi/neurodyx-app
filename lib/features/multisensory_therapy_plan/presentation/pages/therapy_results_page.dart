import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';

class TherapyResultsPage extends StatelessWidget {
  final String therapyType;
  final int score;
  final int totalQuestions;
  final Function()? onRetry;
  final Function()? onBack;

  const TherapyResultsPage({
    super.key,
    required this.therapyType,
    required this.score,
    required this.totalQuestions,
    this.onRetry,
    this.onBack,
  });

  // Determine header message based on score percentage
  String _getHeaderText() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage < 40) {
      return "Oops! Let's try again!";
    } else if (percentage < 70) {
      return "Almost there!";
    } else {
      return "Great job!";
    }
  }

  // Determine motivation text based on score percentage
  String _getMotivationText() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage < 40) {
      return "Don't give up!";
    } else if (percentage < 70) {
      return "Keep pushing!";
    } else {
      return "Excellent work!";
    }
  }

  // Determine which image asset to use based on score percentage
  String _getImageAsset() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage < 40) {
      return AssetPath.imgTherapyResult1;
    } else if (percentage < 70) {
      return AssetPath.imgTherapyResult2;
    } else {
      return AssetPath.imgTherapyResult3;
    }
  }

  // Determine score color based on percentage
  Color _getScoreColor() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage < 40) {
      return Colors.red;
    } else if (percentage < 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              // Header Text
              Text(
                _getHeaderText(),
                style: const TextStyle(
                  color: Color(0xFF686868),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Image
              Image.asset(
                _getImageAsset(),
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // Motivation Text
              Text(
                _getMotivationText(),
                style: const TextStyle(
                  color: Color(0xFF686868),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Score Text Label
              const Text(
                "Your Score",
                style: TextStyle(
                  color: Color(0xFF686868),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Score Value
              Text(
                "$score/$totalQuestions",
                style: TextStyle(
                  color: _getScoreColor(),
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Retry Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRetry ??
                            () {
                              // Default behavior if onRetry is not provided
                              Navigator.pop(context);
                            },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          "Retry",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Back Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onBack ??
                            () {
                              // Default behavior if onBack is not provided
                              Navigator.pop(context);
                            },
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                        label: const Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
