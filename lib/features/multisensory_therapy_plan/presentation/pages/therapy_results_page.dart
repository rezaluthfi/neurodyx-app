import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/models/therapy_result_model.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/auditory/auditory_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/kinesthetic/kinesthetic_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/tactile/tactile_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/visual/visual_therapy_plan_page.dart';
import 'package:provider/provider.dart';
import '../providers/therapy_provider.dart';

class TherapyResultsPage extends StatefulWidget {
  final String therapyType;
  final String category;

  const TherapyResultsPage({
    super.key,
    required this.therapyType,
    required this.category,
  });

  @override
  State<TherapyResultsPage> createState() => _TherapyResultsPageState();
}

class _TherapyResultsPageState extends State<TherapyResultsPage> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToTherapyPage() {
    switch (widget.therapyType.toLowerCase()) {
      case 'visual':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const VisualTherapyPlanPage()),
        );
        break;
      case 'auditory':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const AuditoryTherapyPlanPage()),
        );
        break;
      case 'tactile':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const TactileTherapyPlanPage()),
        );
        break;
      case 'kinesthetic':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const KinestheticTherapyPlanPage()),
        );
        break;
      default:
        Navigator.pushReplacementNamed(context, '/multisensory_therapy_plan');
        break;
    }
  }

  void _retry(TherapyResultModel? result) {
    Provider.of<TherapyProvider>(context, listen: false).reset();
    _navigateToTherapyPage();
  }

  void _back() {
    // Langsung navigasi ke halaman multisensory therapy plan
    Navigator.pushReplacementNamed(context, '/multisensory_therapy_plan');
  }

  String _getHeaderText(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return "No results available";
    final percentage = (correctAnswers / totalQuestions) * 100;
    if (percentage < 40) {
      return "Oops! Let's try again!";
    } else if (percentage < 70) {
      return "Almost there!";
    } else {
      return "Great job!";
    }
  }

  String _getMotivationText(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return "Please try again.";
    final percentage = (correctAnswers / totalQuestions) * 100;
    if (percentage < 40) {
      return "Don't give up!";
    } else if (percentage < 70) {
      return "Keep pushing!";
    } else {
      return "Excellent work!";
    }
  }

  String _getImageAsset(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return AssetPath.imgTherapyResult1;
    final percentage = (correctAnswers / totalQuestions) * 100;
    if (percentage < 40) {
      return AssetPath.imgTherapyResult1;
    } else if (percentage < 70) {
      return AssetPath.imgTherapyResult2;
    } else {
      return AssetPath.imgTherapyResult3;
    }
  }

  Color _getScoreColor(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return Colors.grey;
    final percentage = (correctAnswers / totalQuestions) * 100;
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
        child: Consumer<TherapyProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${provider.error}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Ensure we're using the locally calculated result
            if (provider.result == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No results available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final result = provider.result!;
            final correctAnswers = result.correctAnswers;
            final totalQuestions = result.totalQuestions;

            debugPrint('Displaying results: $correctAnswers/$totalQuestions');

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  Text(
                    _getHeaderText(correctAnswers, totalQuestions),
                    style: const TextStyle(
                      color: Color(0xFF686868),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Image.asset(
                    _getImageAsset(correctAnswers, totalQuestions),
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 180,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _getMotivationText(correctAnswers, totalQuestions),
                    style: const TextStyle(
                      color: Color(0xFF686868),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Status: ${result.status}",
                    style: const TextStyle(
                      color: Color(0xFF686868),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
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
                  Text(
                    "$correctAnswers/$totalQuestions",
                    style: TextStyle(
                      color: _getScoreColor(correctAnswers, totalQuestions),
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _retry(result),
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            label: const Text(
                              "Retry",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _back,
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              "Back",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
