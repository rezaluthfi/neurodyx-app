import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/widgets/custom_button.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/auditory_assessment_questions_page.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/kinesthetic_assessment_questions_page.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/tactile_assessment_questions_page.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/visual_assessment_questions_page.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/smart_screening_and_assessment_page.dart';
import 'package:provider/provider.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/widgets/assessment_card.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/widgets/assessment_shimmer_card.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../providers/assessment_provider.dart';
import 'assessment_ready_page.dart';
import 'assessment_result_page.dart';

class DyslexiaAssessmentPage extends StatefulWidget {
  const DyslexiaAssessmentPage({super.key});

  @override
  _DyslexiaAssessmentPageState createState() => _DyslexiaAssessmentPageState();
}

class _DyslexiaAssessmentPageState extends State<DyslexiaAssessmentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentProvider>(context, listen: false)
          .fetchQuestions(context);
    });
  }

  // Function to navigate back to the previous page
  void _navigateBack() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SmartScreeningAndAssessmentPage(),
      ),
      (route) => route.isFirst,
    );
  }

  // Fungsi untuk menangani onTap pada kartu assessment
  void _handleCardTap({
    required BuildContext context,
    required String status,
    required String assessmentType,
    required String welcomeText,
    required String instructionText,
    required String abilityText,
    required List<String> abilityList,
    required Widget questionsPage,
  }) {
    // Navigate to the AssessmentReadyPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentReadyPage(
          assessmentType: assessmentType,
          welcomeText: welcomeText,
          instructionText: instructionText,
          abilityText: abilityText,
          abilityList: abilityList,
          onNextPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => questionsPage,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Mencegah pop default
      onPopInvoked: (didPop) {
        if (didPop) return;
        _navigateBack(); // Navigasi kembali ke SmartScreeningAndAssessmentPage
      },
      child: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              backgroundColor: AppColors.offWhite,
              appBar: AppBar(
                backgroundColor: AppColors.offWhite,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary),
                  onPressed: _navigateBack, // Navigasi kembali
                ),
                title: const Text(
                  'Dyslexia Assessment',
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
                      ShimmerCard(),
                      SizedBox(height: 16),
                      ShimmerCard(),
                      SizedBox(height: 16),
                      ShimmerCard(),
                      SizedBox(height: 16),
                      ShimmerCard(),
                    ],
                  ),
                ),
              ),
            );
          }

          // Cek apakah semua assessment telah diselesaikan
          bool allCompleted =
              provider.statuses.values.every((status) => status == 'completed');

          // Jika semua assessment selesai, arahkan langsung ke AssessmentResultPage
          if (allCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentResultPage(
                    scores: provider.scores,
                    totalQuestions: provider.totalQuestions,
                    statuses: provider.statuses,
                  ),
                ),
              );
            });
          }

          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: _navigateBack, // Navigasi kembali
              ),
              title: const Text(
                'Dyslexia Assessment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 8),
                              child: Text(
                                'Dyslexia Assessment',
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
                                'This assessment identifies your strengths and needs in Visual, Auditory, Kinesthetic, and Tactile areas to support dyslexia therapy.',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AssessmentCard(
                              title: 'VISUAL',
                              icon: '👁️',
                              score:
                                  '${provider.scores['visual'] ?? 0}/${provider.totalQuestions['visual'] ?? 0}',
                              status:
                                  provider.statuses['visual'] ?? 'not started',
                              statusColor: (provider.statuses['visual'] ??
                                          'not started') ==
                                      'not started'
                                  ? Colors.red
                                  : Colors.green,
                              showArrow: true,
                              showProgress: false,
                              onTap: () => _handleCardTap(
                                context: context,
                                status: provider.statuses['visual'] ??
                                    'not started',
                                assessmentType: 'Visual Assessment',
                                welcomeText: 'Welcome to',
                                instructionText:
                                    'Look carefully and choose the correct answer! This test will help us understand your visual skills',
                                abilityText:
                                    'This test is designed to strengthen your ability to:',
                                abilityList: const [
                                  '1. Letter Recognition',
                                  '2. Complete Word',
                                  '3. Word Recognition',
                                ],
                                questionsPage:
                                    const VisualAssessmentQuestionsPage(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AssessmentCard(
                              title: 'AUDITORY',
                              icon: '📢',
                              score:
                                  '${provider.scores['auditory'] ?? 0}/${provider.totalQuestions['auditory'] ?? 0}',
                              status: provider.statuses['auditory'] ??
                                  'not started',
                              statusColor: (provider.statuses['auditory'] ??
                                          'not started') ==
                                      'not started'
                                  ? Colors.red
                                  : Colors.green,
                              showArrow: true,
                              showProgress: false,
                              onTap: () => _handleCardTap(
                                context: context,
                                status: provider.statuses['auditory'] ??
                                    'not started',
                                assessmentType: 'Auditory Assessment',
                                welcomeText: 'Welcome to',
                                instructionText:
                                    'Listen carefully and choose the correct answer! This test will help us understand your listening skills',
                                abilityText:
                                    'This test is designed to strengthen your ability to:',
                                abilityList: const [
                                  '1. Letter Sound Guess',
                                  '2. Word Sound Guess',
                                  '3. Word Repetition',
                                ],
                                questionsPage:
                                    const AuditoryAssessmentQuestionsPage(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AssessmentCard(
                              title: 'KINESTHETIC',
                              icon: '✋',
                              score:
                                  '${provider.scores['kinesthetic'] ?? 0}/${provider.totalQuestions['kinesthetic'] ?? 0}',
                              status: provider.statuses['kinesthetic'] ??
                                  'not started',
                              statusColor: (provider.statuses['kinesthetic'] ??
                                          'not started') ==
                                      'not started'
                                  ? Colors.red
                                  : Colors.green,
                              showArrow: true,
                              showProgress: false,
                              onTap: () => _handleCardTap(
                                context: context,
                                status: provider.statuses['kinesthetic'] ??
                                    'not started',
                                assessmentType: 'Kinesthetic Assessment',
                                welcomeText: 'Welcome to',
                                instructionText:
                                    'Use your hands to explore letters and words! Follow the movements and complete the tasks!',
                                abilityText:
                                    'This test is designed to strengthen your ability to:',
                                abilityList: const [
                                  '1. Letter Matching',
                                  '2. Letter Differentiation',
                                  '3. Number & Letter Similarity',
                                ],
                                questionsPage:
                                    const KinestheticAssessmentQuestionsPage(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AssessmentCard(
                              title: 'TACTILE',
                              icon: '🎶',
                              score:
                                  '${provider.scores['tactile'] ?? 0}/${provider.totalQuestions['tactile'] ?? 0}',
                              status:
                                  provider.statuses['tactile'] ?? 'not started',
                              statusColor: (provider.statuses['tactile'] ??
                                          'not started') ==
                                      'not started'
                                  ? Colors.red
                                  : Colors.green,
                              showArrow: true,
                              showProgress: false,
                              onTap: () => _handleCardTap(
                                context: context,
                                status: provider.statuses['tactile'] ??
                                    'not started',
                                assessmentType: 'Tactile Assessment',
                                welcomeText: 'Welcome to',
                                instructionText:
                                    'Use your hands to complete letters and words. Learn and interact through touch!',
                                abilityText:
                                    'This test is designed to strengthen your ability to:',
                                abilityList: const [
                                  '1. Word Recognition by Touch',
                                  '2. Complete the word by Touch',
                                ],
                                questionsPage:
                                    const TactileAssessmentQuestionsPage(),
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color:
                            allCompleted ? AppColors.primary : AppColors.grey,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(-2, -4),
                            blurRadius: 4,
                            color: AppColors.grey.withOpacity(0.7),
                            inset: true,
                          ),
                        ],
                      ),
                      child: CustomButton(
                        onPressed: () {
                          if (allCompleted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssessmentResultPage(
                                  scores: provider.scores,
                                  totalQuestions: provider.totalQuestions,
                                  statuses: provider.statuses,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'See Your Final Result',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: allCompleted
                                ? AppColors.white
                                : AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
