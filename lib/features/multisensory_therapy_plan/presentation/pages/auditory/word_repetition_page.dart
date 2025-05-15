import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/providers/therapy_provider.dart';
import '../therapy_results_page.dart';

class WordRepetitionPage extends StatefulWidget {
  final String category;
  const WordRepetitionPage({super.key, required this.category});

  @override
  _WordRepetitionPageState createState() => _WordRepetitionPageState();
}

class _WordRepetitionPageState extends State<WordRepetitionPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitializing = false; // Added to prevent multiple initializations
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TherapyProvider>(context, listen: false)
            .fetchQuestions('auditory', widget.category);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      CustomSnackBar.show(
        context,
        message: message,
        type: SnackBarType.error,
      );
    }
  }

  void _navigateToResultsPage() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TherapyResultsPage(
          therapyType: 'Auditory',
          category: widget.category,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _handleSubmit(TherapyProvider provider, dynamic currentQuestion,
      bool isLastQuestion) async {
    if (selectedAnswer == null) return;

    try {
      if (!mounted) return;

      provider.addAnswer(
        'auditory',
        currentQuestion.id,
        selectedAnswer!,
      );

      if (!isLastQuestion) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
        return;
      }

      setState(() {
        isSubmitting = true;
      });

      await provider.submitAnswers('auditory', widget.category);

      if (mounted) {
        _navigateToResultsPage();
      }
    } catch (e, stackTrace) {
      debugPrint('Submission error: $e\n$stackTrace');
      if (mounted) {
        setState(() => isSubmitting = false);
        _showErrorSnackBar('Error submitting answers: $e');
      }
    }
  }

  Future<void> playSound(String? soundURL, {double speed = 1.0}) async {
    if (soundURL == null) {
      _showErrorSnackBar('No sound available for this question');
      return;
    }
    setState(() {
      isPlaying = true;
    });
    try {
      await _audioPlayer.setPlaybackRate(speed);
      await _audioPlayer.play(UrlSource(soundURL));
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed && mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => isPlaying = false);
        _showErrorSnackBar('Error playing sound: $e');
      }
    }
  }

  Future<void> _listenAndValidate(String correctAnswer) async {
    if (_isInitializing) return; // Prevent concurrent initialization

    if (!_isListening) {
      setState(() => _isInitializing = true);
      try {
        // Ensure any ongoing speech session is stopped
        await _speech.stop();
        bool available = await _speech.initialize(
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              setState(() {
                _isListening = false;
                _isInitializing = false;
              });
            }
          },
          onError: (error) {
            setState(() {
              _isListening = false;
              _isInitializing = false;
            });
            _showErrorSnackBar('Speech recognition error: ${error.errorMsg}');
          },
        );
        setState(() => _isInitializing = false);

        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (result) {
              if (result.finalResult) {
                String spokenText = result.recognizedWords.trim().toLowerCase();
                setState(() {
                  _isListening = false;
                  selectedAnswer =
                      spokenText.isNotEmpty ? spokenText : 'no_input';
                });
              }
            },
          );
        } else {
          _showErrorSnackBar('Speech recognition not available');
        }
      } catch (e) {
        setState(() {
          _isListening = false;
          _isInitializing = false;
        });
        _showErrorSnackBar('Error initializing speech recognition: $e');
      }
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _speech.stop(); // Ensure speech engine is stopped
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: _buildAppBar(),
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
            appBar: _buildAppBar(),
            body: const Center(child: Text('No auditory questions available')),
          );
        }

        final currentQuestion = auditoryQuestions[currentQuestionIndex];
        final isLastQuestion =
            currentQuestionIndex == auditoryQuestions.length - 1;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: _buildAppBar(),
            body: SafeArea(
              child: _buildContentUI(
                provider: provider,
                currentQuestion: currentQuestion,
                isLastQuestion: isLastQuestion,
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.offWhite,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Word Repetition',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContentUI({
    required TherapyProvider provider,
    required dynamic currentQuestion,
    required bool isLastQuestion,
  }) {
    if (isSubmitting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Submitting answers...',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      );
    }

    final auditoryQuestions =
        provider.questions.where((q) => q.type == 'auditory').toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        '${currentQuestionIndex + 1}/${auditoryQuestions.length}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        (currentQuestionIndex + 1) / auditoryQuestions.length,
                    backgroundColor: Colors.grey[300],
                    color: AppColors.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
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
                    currentQuestion.description ??
                        'Listen and repeat the word you hear by tapping the microphone!',
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
                          onPressed: () => playSound(currentQuestion.soundURL),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenMint,
                            foregroundColor: AppColors.textPrimary,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(24),
                          ),
                          child: Icon(
                            isPlaying ? Icons.volume_up : Icons.play_arrow,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () =>
                              playSound(currentQuestion.soundURL, speed: 0.5),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[100],
                            foregroundColor: AppColors.textPrimary,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Icon(Icons.slow_motion_video, size: 24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
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
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.all(_isListening ? 28 : 24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? AppColors.primary.withOpacity(0.8)
                                : AppColors.greenMint,
                            boxShadow: [
                              if (_isListening)
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _listenAndValidate(
                                currentQuestion.correctAnswer ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: AppColors.textPrimary,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  : () =>
                      _handleSubmit(provider, currentQuestion, isLastQuestion),
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
                      color: selectedAnswer == null || isSubmitting
                          ? Colors.grey[600]
                          : AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastQuestion ? Icons.check : Icons.arrow_forward,
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
  }
}
