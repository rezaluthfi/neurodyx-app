import 'package:flutter/material.dart';
import 'package:neurodyx/features/get_to_know/presentation/pages/get_to_know_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/multisensory_therapy_plan_page.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/smart_screening_and_assessment_page.dart';
import 'package:neurodyx/features/progress/presentation/pages/progress_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/assets_path.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/custom_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    debugPrint('HomePage initialized');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomePage building');
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Make sure we have a user before rendering content
    if (user == null) {
      debugPrint('HomePage: User is null!');
    } else {
      debugPrint('HomePage: User username is ${user.username}');
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section
                Text(
                  'Hello, ${user?.username ?? 'Guest'}!',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'What Are You Looking For?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Let me help you explore, screen, and find the right therapy for dyslexia!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 24),

                // Card 1: Get to Know Dyslexia
                CustomCard(
                  title: 'Get to Know Dyslexia',
                  subtitle:
                      'Learn about the early signs and how dyslexia affects learning',
                  buttonText: 'EXPLORE',
                  backgroundColor: AppColors.deepPurple100,
                  iconPath: AssetPath.iconSearch3D,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GetToKnowPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Card 2: Smart Screening & Assessment
                CustomCard(
                  title: 'Smart Screening & Assessment',
                  subtitle:
                      'Start with a quick test, then dive deeper to understand your needs',
                  buttonText: 'CHECK',
                  backgroundColor: AppColors.pink50,
                  iconPath: AssetPath.iconPaperboard3D,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SmartScreeningAndAssessmentPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Card 3: Multisensory Therapy Plan
                CustomCard(
                  title: 'Multisensory Therapy Plan',
                  subtitle:
                      'Get the right therapy approach tailored just for you',
                  buttonText: 'START',
                  backgroundColor: AppColors.blue50,
                  iconPath: AssetPath.iconSensory3D,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MultisensoryTherapyPlanPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Card 4: See Your Progress!
                CustomCard(
                  title: 'See Your Progress!',
                  subtitle: 'Track your improvements and celebrate small wins',
                  buttonText: 'TRACK',
                  backgroundColor: AppColors.yellow200,
                  iconPath: AssetPath.iconFire3D,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProgressPage(),
                      ),
                    );
                  },
                ),

                // Spacer to prevent FloatingActionButton from overlapping
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
