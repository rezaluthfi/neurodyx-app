import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/widgets/custom_button.dart';
import 'package:neurodyx/features/main/presentation/pages/main_navigator.dart';
import 'package:provider/provider.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/widgets/assessment_card.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/widgets/assessment_shimmer_card.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/visual_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/auditory_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/kinesthetic_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/tactile_therapy_plan_page.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_snack_bar.dart';
import '../../providers/assessment_provider.dart';

class AssessmentResultPage extends StatefulWidget {
  final Map<String, int> scores;
  final Map<String, int> totalQuestions;
  final Map<String, String> statuses;

  const AssessmentResultPage({
    super.key,
    required this.scores,
    required this.totalQuestions,
    required this.statuses,
  });

  @override
  _AssessmentResultPageState createState() => _AssessmentResultPageState();
}

class _AssessmentResultPageState extends State<AssessmentResultPage> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentProvider>(context, listen: false)
          .fetchResults(context);
    });
  }

  // Check if all scores are perfect (100%)
  bool _areAllScoresPerfect(
      Map<String, int> scores, Map<String, int> totalQuestions) {
    if (scores.isEmpty || totalQuestions.isEmpty) return false;
    return scores.entries.every((entry) {
      final type = entry.key;
      final score = entry.value;
      final total = totalQuestions[type] ?? 1;
      return total > 0 && score == total;
    });
  }

  // Determine the recommended therapy type
  String _getLowestScoreType(
      Map<String, int> scores, Map<String, int> totalQuestions) {
    if (_areAllScoresPerfect(scores, totalQuestions)) {
      return 'balanced'; // Special case for perfect scores
    }

    Map<String, double> percentages = {};
    scores.forEach((type, score) {
      final total = totalQuestions[type] ?? 1;
      percentages[type] = total > 0 ? (score / total * 100) : 0.0;
    });

    if (percentages.isEmpty) {
      return 'visual'; // Fallback to visual if no scores
    }

    return percentages.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  // Get therapy recommendation message
  String _getTherapyRecommendation(String therapyType) {
    if (therapyType == 'balanced') {
      return 'Congratulations! You achieved perfect scores in all assessments. We recommend a Balanced Therapy Plan to maintain and enhance your skills across all areas.';
    }
    String capitalizedType =
        therapyType.substring(0, 1).toUpperCase() + therapyType.substring(1);
    return 'Based on your assessment results, we recommend starting with $capitalizedType Therapy Plan to improve your weaker areas before integrating other approaches.';
  }

  // Navigate to the appropriate therapy plan
  void _navigateToTherapyPlan(BuildContext context, String therapyType) async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      Widget targetPage;

      // Show congratulatory message for perfect scores
      if (therapyType == 'balanced') {
        CustomSnackBar.show(
          context,
          message:
              'Amazing job! You got all answers correct. Starting Balanced Therapy Plan.',
          type: SnackBarType.success,
        );
        // For balanced plan, default to VisualTherapyPlan or a custom page
        targetPage = const VisualTherapyPlanPage();
      } else {
        switch (therapyType) {
          case 'visual':
            targetPage = const VisualTherapyPlanPage();
            break;
          case 'auditory':
            targetPage = const AuditoryTherapyPlanPage();
            break;
          case 'kinesthetic':
            targetPage = const KinestheticTherapyPlanPage();
            break;
          case 'tactile':
            targetPage = const TactileTherapyPlanPage();
            break;
          default:
            CustomSnackBar.show(
              context,
              message: 'Invalid therapy type. Defaulting to Visual Therapy.',
              type: SnackBarType.error,
            );
            targetPage = const VisualTherapyPlanPage();
        }
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Error navigating to therapy plan: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Final Result',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    ShimmerCard(showProgress: true),
                    SizedBox(height: 16),
                    ShimmerCard(showProgress: true),
                    SizedBox(height: 16),
                    ShimmerCard(showProgress: true),
                    SizedBox(height: 16),
                    ShimmerCard(showProgress: true),
                  ],
                ),
              ),
            ),
          );
        }

        // Determine therapy recommendation
        final recommendedTherapyType =
            _getLowestScoreType(provider.scores, provider.totalQuestions);

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: AppBar(
            backgroundColor: AppColors.offWhite,
            elevation: 0,
            title: const Text(
              'Final Result',
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
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              'Dyslexia Assessment Result',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Here are your results for Visual, Auditory, Kinesthetic, and Tactile assessments.',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          AssessmentCard(
                            title: 'VISUAL',
                            icon: '👁️',
                            score:
                                '${provider.scores['visual'] ?? 0}/${provider.totalQuestions['visual'] ?? 1}',
                            status:
                                provider.statuses['visual'] ?? 'not started',
                            statusColor: Colors.green,
                            onTap: () {},
                            showProgress: true,
                          ),
                          const SizedBox(height: 16),
                          AssessmentCard(
                            title: 'AUDITORY',
                            icon: '📢',
                            score:
                                '${provider.scores['auditory'] ?? 0}/${provider.totalQuestions['auditory'] ?? 1}',
                            status:
                                provider.statuses['auditory'] ?? 'not started',
                            statusColor: Colors.green,
                            onTap: () {},
                            showProgress: true,
                          ),
                          const SizedBox(height: 16),
                          AssessmentCard(
                            title: 'KINESTHETIC',
                            icon: '✋',
                            score:
                                '${provider.scores['kinesthetic'] ?? 0}/${provider.totalQuestions['kinesthetic'] ?? 1}',
                            status: provider.statuses['kinesthetic'] ??
                                'not started',
                            statusColor: Colors.green,
                            onTap: () {},
                            showProgress: true,
                          ),
                          const SizedBox(height: 16),
                          AssessmentCard(
                            title: 'TACTILE',
                            icon: '🎶',
                            score:
                                '${provider.scores['tactile'] ?? 0}/${provider.totalQuestions['tactile'] ?? 1}',
                            status:
                                provider.statuses['tactile'] ?? 'not started',
                            statusColor: Colors.green,
                            onTap: () {},
                            showProgress: true,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Therapy Recommendation',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            color: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _getTherapyRecommendation(
                                    recommendedTherapyType),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  // Buttons pinned to bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: _isNavigating
                                ? Colors.grey[300]
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(-2, -4),
                                blurRadius: 4,
                                color: AppColors.grey.withOpacity(0.7),
                                inset: true,
                              ),
                              BoxShadow(
                                offset: const Offset(2, 4),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.1),
                                inset: false,
                              ),
                            ],
                          ),
                          child: CustomButton(
                            onPressed: _isNavigating
                                ? () {}
                                : () => _navigateToTherapyPlan(
                                    context, recommendedTherapyType),
                            child: Text(
                              recommendedTherapyType == 'balanced'
                                  ? 'Start Balanced Therapy Plan'
                                  : 'Start ${recommendedTherapyType.substring(0, 1).toUpperCase() + recommendedTherapyType.substring(1)} Therapy Plan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isNavigating
                                    ? Colors.grey[600]
                                    : AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isNavigating
                                ? null
                                : () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MainNavigator(
                                                  initialIndex: 0)),
                                      (route) =>
                                          false, // Remove all previous routes
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Back to Home',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isNavigating
                                    ? Colors.grey[600]
                                    : AppColors.primary,
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
      },
    );
  }
}
