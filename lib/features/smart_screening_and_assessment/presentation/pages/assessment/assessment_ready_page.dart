import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../../../../../../core/constants/app_colors.dart';

class AssessmentReadyPage extends StatelessWidget {
  final String assessmentType;
  final String welcomeText;
  final String instructionText;
  final String abilityText;
  final List<String> abilityList;
  final VoidCallback onNextPressed;

  const AssessmentReadyPage({
    super.key,
    required this.assessmentType,
    required this.welcomeText,
    required this.instructionText,
    required this.abilityText,
    required this.abilityList,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Get emoji icon based on assessment type
    String getAssessmentIcon() {
      switch (assessmentType.split(' ').first.toUpperCase()) {
        case 'VISUAL':
          return '👁️';
        case 'AUDITORY':
          return '📢';
        case 'KINESTHETIC':
          return '✋';
        case 'TACTILE':
          return '🎶';
        default:
          return '📝';
      }
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
        title: Text(
          assessmentType,
          style: const TextStyle(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Header with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              getAssessmentIcon(),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  welcomeText,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  assessmentType,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Instructions card
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
                                    "Instructions",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                instructionText,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Abilities card
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
                                    Icons.psychology_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Skills to Improve",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                abilityText,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...abilityList.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            item.startsWith(
                                                    "${abilityList.indexOf(item) + 1}.")
                                                ? item.substring(3).trim()
                                                : item,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Warning box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red[700], size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Important',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'You cannot go back to the previous question. Read instructions carefully before proceeding.',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Fixed bottom button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
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
                    onPressed: onNextPressed,
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
                          'Start Assessment',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
