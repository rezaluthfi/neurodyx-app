import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';

class FinalResultPage extends StatelessWidget {
  final Map<String, int> scores;
  final Map<String, int> totalQuestions;
  final Map<String, String> statuses;

  const FinalResultPage({
    super.key,
    required this.scores,
    required this.totalQuestions,
    required this.statuses,
  });

  // Calculate percentages for each category
  Map<String, double> _calculatePercentages() {
    return {
      'TACTILE': totalQuestions['TACTILE']! > 0
          ? (scores['TACTILE']! / totalQuestions['TACTILE']!) * 100
          : 0.0,
      'KINESTHETIC': totalQuestions['KINESTHETIC']! > 0
          ? (scores['KINESTHETIC']! / totalQuestions['KINESTHETIC']!) * 100
          : 0.0,
      'AUDITORY': totalQuestions['AUDITORY']! > 0
          ? (scores['AUDITORY']! / totalQuestions['AUDITORY']!) * 100
          : 0.0,
      'VISUAL': totalQuestions['VISUAL']! > 0
          ? (scores['VISUAL']! / totalQuestions['VISUAL']!) * 100
          : 0.0,
    };
  }

  // Find the weakest category based on percentages
  String _getWeakestCategory(Map<String, double> percentages) {
    String weakestCategory = 'TACTILE';
    double lowestPercentage = percentages['TACTILE']!;

    percentages.forEach((category, percentage) {
      if (percentage < lowestPercentage) {
        lowestPercentage = percentage;
        weakestCategory = category;
      }
    });

    return weakestCategory;
  }

  // Check if all assessments are completed
  bool _allAssessmentsCompleted() {
    return statuses.values.every((status) => status == 'completed');
  }

  @override
  Widget build(BuildContext context) {
    final percentages = _calculatePercentages();
    final weakestCategory = _getWeakestCategory(percentages);
    final allCompleted = _allAssessmentsCompleted();

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
          'Result',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FINAL RESULT',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Tactile Result
              _buildResultRow(
                icon: '🎶',
                title: 'TACTILE',
                percentage: percentages['TACTILE']!,
              ),
              const SizedBox(height: 16),

              // Kinesthetic Result
              _buildResultRow(
                icon: '✋',
                title: 'KINESTHETIC',
                percentage: percentages['KINESTHETIC']!,
              ),
              const SizedBox(height: 16),

              // Auditory Result
              _buildResultRow(
                icon: '📢',
                title: 'AUDITORY',
                percentage: percentages['AUDITORY']!,
              ),
              const SizedBox(height: 16),

              // Visual Result
              _buildResultRow(
                icon: '👁️',
                title: 'VISUAL',
                percentage: percentages['VISUAL']!,
              ),
              const SizedBox(height: 32),

              // Recommendation Box (only if all assessments are completed)
              if (allCompleted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Begin with $weakestCategory Therapy to improve weaker areas before integrating the other',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              const Spacer(),

              // Start Therapy Button (only if all assessments are completed)
              if (allCompleted)
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
                      // Logic untuk memulai terapi (bisa navigasi ke halaman terapi)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Start $weakestCategory Therapy',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildResultRow({
    required String icon,
    required String title,
    required double percentage,
  }) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green,
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
