import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/multisensory_therapy_plan_page.dart';
import 'package:provider/provider.dart';
import '../../providers/therapy_provider.dart';
import 'letter_recognition_page.dart';
import 'complete_word_page.dart';
import 'word_recognition_page.dart';

extension StringExtensions on String {
  String capitalizeEachWord() {
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}

class VisualTherapyPlanPage extends StatefulWidget {
  const VisualTherapyPlanPage({super.key});

  @override
  State<VisualTherapyPlanPage> createState() => _VisualTherapyPlanPageState();
}

class _VisualTherapyPlanPageState extends State<VisualTherapyPlanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TherapyProvider>(context, listen: false)
          .fetchCategories('visual');
    });
  }

  Future<void> _navigateToCategoryPage(String category) async {
    final provider = Provider.of<TherapyProvider>(context, listen: false);
    await provider.fetchQuestions('visual', category);
    if (!mounted) return;
    Widget targetPage;
    switch (category) {
      case 'letter_recognition':
        targetPage = const LetterRecognitionPage();
        break;
      case 'complete_word':
        targetPage = const CompleteWordPage();
        break;
      case 'word_recognition':
        targetPage = const WordRecognitionPage();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.indigo300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MultisensoryTherapyPlanPage(),
              ),
            );
          },
        ),
        title: const Text(
          'Therapy Plan',
          style: TextStyle(color: AppColors.white, fontSize: 18),
        ),
      ),
      body: Container(
        color: AppColors.indigo300,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visual Therapy Plan',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enhance your visual processing with these activities!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Consumer<TherapyProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.error != null) {
                      return Center(child: Text('Error: ${provider.error}'));
                    }
                    if (provider.categories.isEmpty) {
                      return const Center(
                          child: Text('No categories available'));
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: provider.categories.map((category) {
                        return _buildListTile(
                          title: category.category
                              .replaceAll('_', ' ')
                              .capitalizeEachWord(),
                          subtitle: category.description,
                          onTap: () =>
                              _navigateToCategoryPage(category.category),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textPrimary,
        ),
        onTap: onTap,
      ),
    );
  }
}
