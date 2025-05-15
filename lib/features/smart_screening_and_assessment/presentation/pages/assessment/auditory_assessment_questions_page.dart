import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/dyslexia_assessment_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_snack_bar.dart';
import '../../providers/assessment_provider.dart';

class AuditoryAssessmentQuestionsPage extends StatefulWidget {
  const AuditoryAssessmentQuestionsPage({super.key});

  @override
  _AuditoryAssessmentQuestionsPageState createState() =>
      _AuditoryAssessmentQuestionsPageState();
}

class _AuditoryAssessmentQuestionsPageState
    extends State<AuditoryAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool isSubmitting = false;

  // Track correct answers count
  int correctAnswersCount = 0;
  // Keep track of which questions have been answered correctly
  Set<String> answeredQuestionIds = {};

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSound(String? soundURL, {double speed = 1.0}) async {
    if (soundURL == null) return;
    setState(() {
      isPlaying = true;
    });
    try {
      await _audioPlayer.setPlaybackRate(speed);
      await _audioPlayer.play(UrlSource(soundURL));
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          setState(() {
            isPlaying = false;
          });
        }
      });
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Error playing sound: $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _listenAndValidate(String correctAnswer) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          CustomSnackBar.show(
            context,
            message: 'Speech recognition error: ${error.errorMsg}',
            type: SnackBarType.error,
          );
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              String spokenText = result.recognizedWords.trim().toLowerCase();

              // Get current question ID
              final currentQuestion =
                  Provider.of<AssessmentProvider>(context, listen: false)
                      .questions
                      .where((q) => q.type == 'auditory')
                      .toList()[currentQuestionIndex];

              final questionId = currentQuestion.id;

              // Check if answer is correct
              bool isCorrect =
                  spokenText.toLowerCase() == correctAnswer.toLowerCase();

              setState(() {
                _isListening = false;
                selectedAnswer =
                    spokenText.isNotEmpty ? spokenText : 'no_input';

                // If correct and not already counted, increment the counter
                if (isCorrect && !answeredQuestionIds.contains(questionId)) {
                  correctAnswersCount++;
                  answeredQuestionIds.add(questionId);
                }
              });

              // Add answer to provider (existing code)
              Provider.of<AssessmentProvider>(context, listen: false).addAnswer(
                'auditory',
                questionId,
                spokenText,
              );
            }
          },
        );
      } else {
        CustomSnackBar.show(
          context,
          message: 'Speech recognition not available',
          type: SnackBarType.error,
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  // Handle multiple-choice answers (for letter_sound_guess and word_sound_guess)
  void _handleMultipleChoiceAnswer(
      String option, String correctAnswer, String questionId) {
    setState(() {
      selectedAnswer = option;

      // Check if this answer is correct and not already counted
      bool isCorrect = option.toLowerCase() == correctAnswer.toLowerCase();
      if (isCorrect && !answeredQuestionIds.contains(questionId)) {
        correctAnswersCount++;
        answeredQuestionIds.add(questionId);
      }
    });

    // Record the answer in the provider
    Provider.of<AssessmentProvider>(context, listen: false).addAnswer(
      'auditory',
      questionId,
      option,
    );
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
                'Auditory Assessment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Shimmer.fromColors(
                baseColor: AppColors.grey.withOpacity(0.2),
                highlightColor: AppColors.grey.withOpacity(0.1),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 120,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 24,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 48,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final auditoryQuestions =
            provider.questions.where((q) => q.type == 'auditory').toList();

        if (auditoryQuestions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Auditory Assessment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const Center(child: Text('No auditory questions available')),
          );
        }

        final currentQuestion = auditoryQuestions[currentQuestionIndex];
        final isLastQuestion =
            currentQuestionIndex == auditoryQuestions.length - 1;
        final questionType = currentQuestion.category;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                questionType == 'letter_sound_guess'
                    ? 'Letter Sound Guess'
                    : questionType == 'word_sound_guess'
                        ? 'Word Sound Guess'
                        : 'Word Repetition',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isSubmitting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'QUESTION ${currentQuestionIndex + 1}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Updated to show both question progress and correct answers
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Question ${currentQuestionIndex + 1} of ${auditoryQuestions.length}',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'Score: $correctAnswersCount/${auditoryQuestions.length}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Two progress indicators - one for question progress, one for score
                                Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value: (currentQuestionIndex + 1) /
                                          auditoryQuestions.length,
                                      backgroundColor: Colors.grey[300],
                                      color: AppColors.primary,
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    const SizedBox(height: 4),
                                    // Score progress indicator
                                    LinearProgressIndicator(
                                      value: correctAnswersCount /
                                          auditoryQuestions.length,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.green,
                                      minHeight: 4,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'instruction :',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  questionType == 'letter_sound_guess'
                                      ? 'Listen to the sound of the letters and choose the appropriate letter!'
                                      : questionType == 'word_sound_guess'
                                          ? 'Listen carefully to the sound. Tap the word that matches the sound!'
                                          : 'Listen and repeat the word you hear by tapping the microphone!',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            playSound(currentQuestion.soundURL),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.greenMint,
                                          foregroundColor:
                                              AppColors.textPrimary,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(24),
                                        ),
                                        child: Icon(
                                          isPlaying
                                              ? Icons.volume_up
                                              : Icons.play_arrow,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: () => playSound(
                                            currentQuestion.soundURL,
                                            speed: 0.5),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pink[100],
                                          foregroundColor:
                                              AppColors.textPrimary,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(16),
                                        ),
                                        child: const Icon(
                                            Icons.slow_motion_video,
                                            size: 24),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                if (questionType == 'letter_sound_guess')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: currentQuestion.options!
                                        .map((option) => SizedBox(
                                              width: 80,
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _handleMultipleChoiceAnswer(
                                                        option,
                                                        currentQuestion
                                                                .correctAnswer ??
                                                            '',
                                                        currentQuestion.id),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      selectedAnswer == option
                                                          ? AppColors.greenMint
                                                              .withOpacity(0.8)
                                                          : AppColors.greenMint,
                                                  foregroundColor:
                                                      AppColors.textPrimary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    side: BorderSide(
                                                      color: selectedAnswer ==
                                                              option
                                                          ? AppColors.primary
                                                          : AppColors.greenMint,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  option,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  )
                                else if (questionType == 'word_sound_guess')
                                  Column(
                                    children: currentQuestion.options!
                                        .map((option) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      _handleMultipleChoiceAnswer(
                                                          option,
                                                          currentQuestion
                                                                  .correctAnswer ??
                                                              '',
                                                          currentQuestion.id),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        selectedAnswer == option
                                                            ? AppColors
                                                                .greenMint
                                                                .withOpacity(
                                                                    0.8)
                                                            : AppColors
                                                                .greenMint,
                                                    foregroundColor:
                                                        AppColors.textPrimary,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      side: BorderSide(
                                                        color: selectedAnswer ==
                                                                option
                                                            ? AppColors.primary
                                                            : AppColors
                                                                .greenMint,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    option,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  )
                                else if (questionType == 'word_repetition')
                                  Center(
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Tap the microphone to speak',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          padding: EdgeInsets.all(
                                              _isListening ? 28 : 24),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _isListening
                                                ? AppColors.primary
                                                    .withOpacity(0.8)
                                                : AppColors.greenMint,
                                            boxShadow: [
                                              if (_isListening)
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () => _listenAndValidate(
                                                currentQuestion.correctAnswer ??
                                                    ''),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              foregroundColor:
                                                  AppColors.textPrimary,
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(0),
                                            ),
                                            child: Icon(
                                              _isListening
                                                  ? Icons.mic
                                                  : Icons.mic_none,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),
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
                            color: selectedAnswer == null || isSubmitting
                                ? Colors.grey[300]!.withOpacity(0.6)
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(-2, -4),
                                blurRadius: 4,
                                color: AppColors.grey.withOpacity(0.7),
                                inset: true,
                              ),
                              if (selectedAnswer != null && !isSubmitting)
                                BoxShadow(
                                  offset: const Offset(2, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.1),
                                  inset: false,
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: selectedAnswer == null || isSubmitting
                                ? null
                                : () async {
                                    if (isLastQuestion) {
                                      setState(() {
                                        isSubmitting = true;
                                      });
                                      final navigator = Navigator.of(context);
                                      await provider.submitAnswers('auditory');
                                      if (mounted) {
                                        navigator.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DyslexiaAssessmentPage(),
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        currentQuestionIndex++;
                                        selectedAnswer = null;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastQuestion ? 'Finish' : 'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        selectedAnswer == null || isSubmitting
                                            ? Colors.grey[600]
                                            : AppColors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLastQuestion
                                      ? Icons.check
                                      : Icons.arrow_forward,
                                  size: 20,
                                  color: selectedAnswer == null || isSubmitting
                                      ? Colors.grey[600]
                                      : AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
