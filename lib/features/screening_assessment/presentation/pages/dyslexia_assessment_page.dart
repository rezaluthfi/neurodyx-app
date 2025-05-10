import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/features/screening_assessment/presentation/pages/auditory_assessment_questions_page.dart';
import 'package:neurodyx/features/screening_assessment/presentation/pages/final_result_page.dart';
import 'package:neurodyx/features/screening_assessment/presentation/pages/visual_assessment_questions_page.dart';
import '../../../../../core/constants/app_colors.dart';
import 'assessment_ready_page.dart';
import 'kinesthetic_assessment_questions_page.dart';
import 'tactile_assessment_questions_page.dart';

class DyslexiaAssessmentPage extends StatefulWidget {
  const DyslexiaAssessmentPage({super.key});

  @override
  _DyslexiaAssessmentPageState createState() => _DyslexiaAssessmentPageState();
}

class _DyslexiaAssessmentPageState extends State<DyslexiaAssessmentPage> {
  // Save scores for each assessment
  Map<String, int> scores = {
    'VISUAL': 0,
    'AUDITORY': 0,
    'KINESTHETIC': 0,
    'TACTILE': 0,
  };

  // Save statuses for each assessment
  Map<String, String> statuses = {
    'VISUAL': 'not started',
    'AUDITORY': 'not started',
    'KINESTHETIC': 'not started',
    'TACTILE': 'not started',
  };

  // Define total questions for each assessment
  final Map<String, int> totalQuestions = {
    'VISUAL': 3, // Adjust based on VisualAssessmentQuestionsPage
    'AUDITORY': 3, // Adjust based on AuditoryAssessmentQuestionsPage
    'KINESTHETIC': 3, // Matches KinestheticAssessmentQuestionsPage
    'TACTILE': 2, // Matches TactileAssessmentQuestionsPage
  };

  @override
  Widget build(BuildContext context) {
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
          'Dyslexia Assessment',
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
              // Fixed header section
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

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Visual Assessment Card
                      _buildAssessmentCard(
                        context: context,
                        title: 'VISUAL',
                        icon: '👁️',
                        score:
                            '${scores['VISUAL']}/${totalQuestions['VISUAL']}',
                        status: statuses['VISUAL']!,
                        statusColor: statuses['VISUAL'] == 'not started'
                            ? Colors.red
                            : Colors.green,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentReadyPage(
                                assessmentType: 'Visual Assessment',
                                welcomeText: 'Welcome to',
                                instructionText:
                                    'This test is designed to strengthen your ability to:',
                                abilityText: 'to:',
                                abilityList: const [
                                  '1. Letter Recognition',
                                  '2. Complete Word',
                                  '3. Word Recognition',
                                ],
                                onNextPressed: () async {
                                  final score = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VisualAssessmentQuestionsPage(),
                                    ),
                                  );
                                  if (score != null) {
                                    setState(() {
                                      scores['VISUAL'] = score as int;
                                      statuses['VISUAL'] = 'completed';
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              scores['VISUAL'] = result as int;
                              statuses['VISUAL'] = 'completed';
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Auditory Assessment Card
                      _buildAssessmentCard(
                        context: context,
                        title: 'AUDITORY',
                        icon: '📢',
                        score:
                            '${scores['AUDITORY']}/${totalQuestions['AUDITORY']}',
                        status: statuses['AUDITORY']!,
                        statusColor: statuses['AUDITORY'] == 'not started'
                            ? Colors.red
                            : Colors.green,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentReadyPage(
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
                                onNextPressed: () async {
                                  final score = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AuditoryAssessmentQuestionsPage(),
                                    ),
                                  );
                                  if (score != null) {
                                    setState(() {
                                      scores['AUDITORY'] = score as int;
                                      statuses['AUDITORY'] = 'completed';
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              scores['AUDITORY'] = result as int;
                              statuses['AUDITORY'] = 'completed';
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Kinesthetic Assessment Card
                      _buildAssessmentCard(
                        context: context,
                        title: 'KINESTHETIC',
                        icon: '✋',
                        score:
                            '${scores['KINESTHETIC']}/${totalQuestions['KINESTHETIC']}',
                        status: statuses['KINESTHETIC']!,
                        statusColor: statuses['KINESTHETIC'] == 'not started'
                            ? Colors.red
                            : Colors.green,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentReadyPage(
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
                                onNextPressed: () async {
                                  final score = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const KinestheticAssessmentQuestionsPage(),
                                    ),
                                  );
                                  if (score != null) {
                                    setState(() {
                                      scores['KINESTHETIC'] = score as int;
                                      statuses['KINESTHETIC'] = 'completed';
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              scores['KINESTHETIC'] = result as int;
                              statuses['KINESTHETIC'] = 'completed';
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tactile Assessment Card
                      _buildAssessmentCard(
                        context: context,
                        title: 'TACTILE',
                        icon: '🎶',
                        score:
                            '${scores['TACTILE']}/${totalQuestions['TACTILE']}',
                        status: statuses['TACTILE']!,
                        statusColor: statuses['TACTILE'] == 'not started'
                            ? Colors.red
                            : Colors.green,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentReadyPage(
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
                                onNextPressed: () async {
                                  final score = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TactileAssessmentQuestionsPage(),
                                    ),
                                  );
                                  if (score != null) {
                                    setState(() {
                                      scores['TACTILE'] = score as int;
                                      statuses['TACTILE'] = 'completed';
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              scores['TACTILE'] = result as int;
                              statuses['TACTILE'] = 'completed';
                            });
                          }
                        },
                      ),

                      // Add extra space at the bottom for better scrolling experience
                      const SizedBox(height: 80),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinalResultPage(
                            scores: scores,
                            totalQuestions: totalQuestions,
                            statuses: statuses,
                          ),
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
                    child: const Text(
                      'See Your Final Result',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildAssessmentCard({
    required BuildContext context,
    required String title,
    required String icon,
    required String score,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    // Use LayoutBuilder to ensure responsiveness
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate if we need to reduce font size or adjust layout based on width
        final isNarrowScreen = constraints.maxWidth < 320;

        return GestureDetector(
          onTap: onTap,
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(isNarrowScreen ? 12.0 : 16.0),
              child: Row(
                children: [
                  Text(
                    icon,
                    style: TextStyle(fontSize: isNarrowScreen ? 20 : 24),
                  ),
                  SizedBox(width: isNarrowScreen ? 8 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: isNarrowScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        isNarrowScreen
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Score: $score',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    'Score: $score',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: isNarrowScreen ? 32 : 40,
                    height: isNarrowScreen ? 32 : 40,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: isNarrowScreen ? 18 : 24,
                      ),
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
