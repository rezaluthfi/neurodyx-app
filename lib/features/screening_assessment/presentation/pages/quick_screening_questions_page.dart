import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'smart_screening_page.dart';
import 'quick_screening_result_page.dart'; // Impor halaman hasil

class QuickScreeningQuestionsPage extends StatefulWidget {
  final String category; // "kid" or "adult"

  const QuickScreeningQuestionsPage({super.key, required this.category});

  @override
  _QuickScreeningQuestionsPageState createState() =>
      _QuickScreeningQuestionsPageState();
}

class _QuickScreeningQuestionsPageState
    extends State<QuickScreeningQuestionsPage> {
  int currentQuestionIndex = 0;
  final int totalQuestions = 10; // Total questions for the screening

  // Placeholder for answers (yes/no for each question)
  final List<bool?> answers = List.filled(10, null);

  void answerQuestion(bool answer) {
    setState(() {
      answers[currentQuestionIndex] = answer;
      if (currentQuestionIndex < totalQuestions - 1) {
        currentQuestionIndex++;
      } else {
        // Hitung skor berdasarkan jawaban "Yes"
        int score = answers.where((answer) => answer == true).length;
        debugPrint('Final score: $score');
        // Navigasi ke halaman hasil dengan skor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(score: score),
          ),
        );
      }
    });
  }

  // Fungsi untuk menampilkan dialog konfirmasi
  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa menutup dialog dengan tap di luar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit the test?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                print('Cancel button pressed');
                Navigator.of(dialogContext)
                    .pop(); // Tutup dialog tanpa navigasi
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('Exit button pressed');
                Navigator.of(dialogContext).pop(); // Tutup dialog
                // Navigasi ke SmartScreeningPage
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SmartScreeningPage(),
                  ),
                );
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sample questions (you can customize these based on the category)
    final List<String> questions = widget.category == 'kid'
        ? [
            'Do you or your child struggle to read new words and often guess instead?',
            'When reading aloud, do you or your child pause, repeat words, or make frequent mistakes?',
            "Have you or your child ever mispronounced certain words in a unique way (e.g., 'amunul' for 'animal' or 'poothtaste' for 'toothpaste')?",
            "Do you or your child find it hard to understand what you've just read?",
            'Do you or your child avoid reading for fun?',
            'Do you or your child often make spelling mistakes?',
            'Is your or your child’s handwriting often messy or difficult to read?',
            'Do you or your child struggle with using punctuation and capitalization correctly?',
            'Do you or your child resist writing tasks, even simple ones?',
            'Do you or your child get frustrated or upset when doing schoolwork?',
          ]
        : [
            'Do you read slowly?',
            'Did you have trouble learning how to read when you were in school?',
            'Do you often have to read something two or three times before it makes sense?',
            'Are you uncomfortable reading out loud?',
            'Do you omit, transpose, or add letters when you are reading or writing?',
            'Do you find you still have spelling mistakes in your writing even after Spell Check?',
            'Do you find it difficult to pronounce uncommon multi-syllable words when you are reading?',
            'Do you choose to read magazines or short articles rather than longer books and novels?',
            'When you were in school, did you find it extremely difficult to learn a foreign language?',
            'Do you avoid work projects or courses that require extensive reading?',
          ];

    return WillPopScope(
      onWillPop: () async {
        print('Back button (device) pressed');
        await _showExitConfirmationDialog(context);
        return false; // Mencegah pop otomatis, navigasi ditangani di dialog
      },
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.offWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () async {
              print('Back button (AppBar) pressed');
              await _showExitConfirmationDialog(context);
            },
          ),
          title: const Text(
            'Quick Screening',
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
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QUESTION ${currentQuestionIndex + 1}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${currentQuestionIndex + 1}/$totalQuestions',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.primary,
                  minHeight: 8,
                ),
                const SizedBox(height: 24),

                // Question Text
                Text(
                  questions[currentQuestionIndex],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Yes/No Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => answerQuestion(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'YES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => answerQuestion(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        child: const Text(
                          'NO',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
