import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/dyslexia_assessment_page.dart';
import '../../../../../../core/constants/app_colors.dart';

class QuickScreeningResultPage extends StatelessWidget {
  final String riskLevel;

  const QuickScreeningResultPage({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    String message;
    String subtitle;
    Color riskColor;
    String iconPath;
    bool showGoToAssessmentButton;

    switch (riskLevel.toLowerCase()) {
      case 'low':
        message = 'Low Risk';
        subtitle = 'Your responses indicate a low likelihood of dyslexia.';
        riskColor = Colors.green;
        iconPath = AssetPath.iconLowRisk;
        showGoToAssessmentButton = false;
        break;
      case 'moderate':
        message = 'Moderate Risk';
        subtitle =
            'Your responses suggest some signs of dyslexia.\nWe recommend further assessment to understand your learning needs better.';
        riskColor = Colors.orange;
        iconPath = AssetPath.iconModerateRisk;
        showGoToAssessmentButton = true;
        break;
      case 'high':
        message = 'High Risk';
        subtitle =
            'Your responses strongly suggest signs of dyslexia.\nTaking a full assessment can help identify specific challenges and guide you to the right support.';
        riskColor = Colors.red;
        iconPath = AssetPath.iconHighRisk;
        showGoToAssessmentButton = true;
        break;
      default:
        message = 'Unknown';
        subtitle = 'Invalid result received';
        riskColor = Colors.grey;
        iconPath = AssetPath.iconLowRisk;
        showGoToAssessmentButton = false;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Screening Results',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Result icon with animated container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          iconPath,
                          height: 100,
                          width: 100,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Risk level text
                      Text(
                        message,
                        style: TextStyle(
                          color: riskColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle explanation
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // What this means card
                      Card(
                        elevation: 0,
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "What This Means",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildWhatThisMeansContent(
                                  riskLevel.toLowerCase()),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Next steps card
                      Card(
                        elevation: 0,
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Recommended Next Steps",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildNextStepsContent(riskLevel.toLowerCase()),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
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
                                builder: (context) =>
                                    const DyslexiaAssessmentPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Go to Full Assessment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (showGoToAssessmentButton) const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showGoToAssessmentButton
                              ? AppColors.white
                              : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: showGoToAssessmentButton
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Back to Home',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: showGoToAssessmentButton
                                ? AppColors.primary
                                : AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatThisMeansContent(String riskLevel) {
    List<String> contentItems = [];

    switch (riskLevel) {
      case 'low':
        contentItems = [
          "Your screening responses don't show significant indicators of dyslexia",
          "You may still experience occasional reading or writing challenges",
          "A low risk result doesn't completely rule out dyslexia"
        ];
        break;
      case 'moderate':
        contentItems = [
          "Your responses show some patterns associated with dyslexia",
          "These patterns suggest some learning differences may be present",
          "Further assessment can provide more definitive information"
        ];
        break;
      case 'high':
        contentItems = [
          "Your responses strongly align with patterns seen in dyslexia",
          "This suggests significant learning differences may be present",
          "A comprehensive assessment is highly recommended"
        ];
        break;
      default:
        contentItems = ["Unable to provide analysis for this result"];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentItems
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "•  ",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildNextStepsContent(String riskLevel) {
    List<String> contentItems = [];

    switch (riskLevel) {
      case 'low':
        contentItems = [
          "Continue with your regular learning activities",
          "Consider general reading and writing improvement strategies",
          "Revisit the screening if you notice persistent challenges"
        ];
        break;
      case 'moderate':
        contentItems = [
          "Take our full assessment to identify specific areas of challenge",
          "Explore learning support strategies for your identified needs",
          "Consider discussing these results with an education professional"
        ];
        break;
      case 'high':
        contentItems = [
          "Take our full assessment to pinpoint your specific challenges",
          "Begin exploring dyslexia-specific support strategies",
          "Consider consulting with an educational psychologist or specialist"
        ];
        break;
      default:
        contentItems = ["Please contact support for guidance on next steps"];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentItems
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "•  ",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
