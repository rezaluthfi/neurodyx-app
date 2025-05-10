import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import '../../../../../core/constants/app_colors.dart';
import 'smart_screening_page.dart';

class ResultPage extends StatelessWidget {
  final int score;

  const ResultPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // Tentukan kategori risiko berdasarkan skor
    String riskLevel;
    String message;
    Color riskColor;
    String iconPath;
    bool showGoToAssessmentButton;

    if (score <= 3) {
      riskLevel = 'Low Risk';
      message = 'Your responses indicate a low likelihood of dyslexia';
      riskColor = Colors.green;
      iconPath = AssetPath.iconLowRisk;
      showGoToAssessmentButton = false;
    } else if (score <= 6) {
      riskLevel = 'Moderate Risk';
      message =
          'Your responses suggest some signs of dyslexia.\nWe recommend further assessment to understand your learning needs better';
      riskColor = Colors.orange;
      iconPath = AssetPath.iconModerateRisk;
      showGoToAssessmentButton = true;
    } else {
      riskLevel = 'High Risk';
      message =
          'Your responses strongly suggest signs of dyslexia.\nTaking a full assessment can help identify specific challenges and guide you to the right support.';
      riskColor = Colors.red;
      iconPath = AssetPath.iconHighRisk;
      showGoToAssessmentButton = true;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Result',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              // Ikon berdasarkan kategori risiko
              Image.asset(
                iconPath,
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 40),
              // Teks kategori risiko
              Text(
                riskLevel.toUpperCase(),
                style: TextStyle(
                  color: riskColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Pesan berdasarkan kategori risiko
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              // Tombol "Go to assessment" (hanya untuk Moderate dan High Risk)
              if (showGoToAssessmentButton)
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(-2, -4),
                        blurRadius: 4,
                        color: AppColors.grey.withOpacity(0.7),
                        inset: true,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SmartScreeningPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to assessment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Tombol "Back to home" (gunakan gaya tombol untuk Low Risk)
              if (score <= 3)
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(-2, -4),
                        blurRadius: 4,
                        color: AppColors.grey.withOpacity(0.7),
                        inset: true,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Kembali ke halaman utama (root)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Back to home',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    // Kembali ke halaman utama (root)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to home',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
