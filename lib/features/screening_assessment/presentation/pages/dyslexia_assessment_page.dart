import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../../../../../core/constants/app_colors.dart';
import 'assessment_ready_page.dart';

class DyslexiaAssessmentPage extends StatefulWidget {
  const DyslexiaAssessmentPage({super.key});

  @override
  _DyslexiaAssessmentPageState createState() => _DyslexiaAssessmentPageState();
}

class _DyslexiaAssessmentPageState extends State<DyslexiaAssessmentPage> {
  // Simpan skor untuk setiap assessment
  Map<String, int> scores = {
    'VISUAL': 0,
    'AUDITORY': 0,
    'KINESTHETIC': 0,
    'TACTILE': 0,
  };

  // Simpan status untuk setiap assessment
  Map<String, String> statuses = {
    'VISUAL': 'not started',
    'AUDITORY': 'not started',
    'KINESTHETIC': 'not started',
    'TACTILE': 'not started',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dyslexia Assessment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This assessment identifies your strengths and needs in Visual, Auditory, Kinesthetic, and Tactile areas to support dyslexia therapy.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Visual Assessment Card
              _buildAssessmentCard(
                context: context,
                title: 'VISUAL',
                icon: '👁️',
                score: '${scores['VISUAL']}/9',
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
                        onNextPressed: () {
                          // Navigate to the visual assessment questions
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
                score: '${scores['AUDITORY']}/9',
                status: statuses['AUDITORY']!,
                statusColor: statuses['AUDITORY'] == 'not started'
                    ? Colors.red
                    : Colors.green,
                onTap: () {
                  Navigator.push(
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
                        onNextPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                    title: const Text('Auditory Questions')),
                                body: const Center(
                                    child:
                                        Text('Auditory Assessment Questions')),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Kinesthetic Assessment Card
              _buildAssessmentCard(
                context: context,
                title: 'KINESTHETIC',
                icon: '✋',
                score: '${scores['KINESTHETIC']}/9',
                status: statuses['KINESTHETIC']!,
                statusColor: statuses['KINESTHETIC'] == 'not started'
                    ? Colors.red
                    : Colors.green,
                onTap: () {
                  Navigator.push(
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
                        onNextPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                    title: const Text('Kinesthetic Questions')),
                                body: const Center(
                                    child: Text(
                                        'Kinesthetic Assessment Questions')),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Tactile Assessment Card
              _buildAssessmentCard(
                context: context,
                title: 'TACTILE',
                icon: '🎶',
                score: '${scores['TACTILE']}/9',
                status: statuses['TACTILE']!,
                statusColor: statuses['TACTILE'] == 'not started'
                    ? Colors.red
                    : Colors.green,
                onTap: () {
                  Navigator.push(
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
                        onNextPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                    title: const Text('Tactile Questions')),
                                body: const Center(
                                    child:
                                        Text('Tactile Assessment Questions')),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // See Your Final Result Button
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
                    // Navigate to the final result page
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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
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
                    const SizedBox(height: 4),
                    Row(
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
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
