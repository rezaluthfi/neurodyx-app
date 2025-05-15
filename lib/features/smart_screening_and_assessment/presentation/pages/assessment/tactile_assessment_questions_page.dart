import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow, Ink;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/audio_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/digital_ink_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/domain/usecases/recognize_letter_usecase.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/dyslexia_assessment_page.dart';
import 'package:provider/provider.dart';
import 'package:scribble/scribble.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_snack_bar.dart';
import '../../providers/assessment_provider.dart';

class TactileAssessmentQuestionsPage extends StatefulWidget {
  const TactileAssessmentQuestionsPage({super.key});

  @override
  _TactileAssessmentQuestionsPageState createState() =>
      _TactileAssessmentQuestionsPageState();
}

class _TactileAssessmentQuestionsPageState
    extends State<TactileAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  late ScribbleNotifier scribbleNotifier;
  bool isSubmitting = false;
  bool _hasDrawn = false;

  late AudioService _audioService;
  late DigitalInkService _digitalInkService;

  @override
  void initState() {
    super.initState();
    scribbleNotifier = ScribbleNotifier();
    scribbleNotifier.addListener(_onScribbleChanged);

    _audioService = context.read<AudioService>();
    _digitalInkService = context.read<DigitalInkService>();

    _audioService.reset(); // Reset AudioPlayer for second submission
    context.read<AssessmentProvider>().initializeModel(context);
  }

  void _onScribbleChanged() {
    final hasLines = scribbleNotifier.value.lines.isNotEmpty;
    if (hasLines != _hasDrawn) {
      setState(() {
        _hasDrawn = hasLines;
      });
    }
  }

  @override
  void dispose() {
    scribbleNotifier.removeListener(_onScribbleChanged);
    scribbleNotifier.dispose();
    _audioService.dispose();
    _digitalInkService.dispose();
    super.dispose();
  }

  Future<void> _recognizeLetter() async {
    if (!context.read<AssessmentProvider>().isModelDownloaded) {
      CustomSnackBar.show(context,
          message: 'Recognition model is not ready. Please wait.',
          type: SnackBarType.error);
      return;
    }
    if (scribbleNotifier.value.lines.isEmpty) {
      CustomSnackBar.show(context,
          message: 'Please draw a letter first!', type: SnackBarType.error);
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final recognizedLetter = await context
          .read<RecognizeLetterUseCase>()
          .execute(scribbleNotifier.value.lines);
      if (!mounted) return;
      setState(() {
        selectedAnswer = recognizedLetter ?? '?';
        _hasDrawn = true;
      });
      if (recognizedLetter == null) {
        CustomSnackBar.show(
          context,
          message: 'Could not recognize any letter. Try again or proceed.',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        selectedAnswer = '?';
        _hasDrawn = true;
      });
      CustomSnackBar.show(context,
          message: 'Recognition error: $e', type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DyslexiaAssessmentPage()),
    );
  }

  Future<void> _processAnswer(
      AssessmentProvider provider, bool isLastQuestion) async {
    if (!mounted) return;
    provider.addAnswer(
      'tactile',
      provider.questions
          .where((q) => q.type == 'tactile')
          .toList()[currentQuestionIndex]
          .id,
      selectedAnswer ?? '?',
    );

    if (isLastQuestion) {
      setState(() => isSubmitting = true);
      try {
        await _audioService.stop(); // Stop playback before submission
        await provider.submitAnswers('tactile');
        if (mounted) _navigateToNext();
      } catch (e) {
        if (mounted) {
          setState(() => isSubmitting = false);
          CustomSnackBar.show(context,
              message: 'Error submitting answers: $e',
              type: SnackBarType.error);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          _hasDrawn = false;
          scribbleNotifier.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        Widget loadingScreen(String message, {bool showAttempts = false}) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Tactile Assessment',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.downloadStatus == 'downloading') ...[
                      LinearProgressIndicator(
                        value: provider.downloadProgress,
                        backgroundColor: Colors.grey[300],
                        color: AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Download Progress: ${(provider.downloadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 16),
                      ),
                    ] else ...[
                      const CircularProgressIndicator(color: AppColors.primary),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 16),
                    ),
                    if (showAttempts)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Attempt ${provider.downloadAttempts + 1} of ${provider.maxDownloadAttempts}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        Widget errorScreen() {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Tactile Assessment',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load recognition model',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please check your internet connection and try again.',
                      style:
                          TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => provider.initializeModel(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Retry',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _navigateToNext,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (provider.isLoading) {
          return loadingScreen('Loading assessment data...');
        }

        if (provider.downloadStatus == 'checking' ||
            provider.downloadStatus == 'downloading') {
          return loadingScreen(
            provider.downloadStatus == 'checking'
                ? 'Checking model availability...'
                : 'Downloading model, please wait...',
            showAttempts: provider.downloadStatus == 'downloading',
          );
        }

        if (provider.downloadStatus == 'error') {
          return errorScreen();
        }

        final tactileQuestions =
            provider.questions.where((q) => q.type == 'tactile').toList();
        if (tactileQuestions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Tactile Assessment',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: const SafeArea(
              child: Center(
                child: Text(
                  'No tactile questions available',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
              ),
            ),
          );
        }

        final currentQuestion = tactileQuestions[currentQuestionIndex];
        final isLastQuestion =
            currentQuestionIndex == tactileQuestions.length - 1;
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
                questionType == 'word_recognition_by_touch'
                    ? 'Word Recognition by Touch'
                    : 'Complete Word by Touch',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: SafeArea(
              child: isSubmitting
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : Column(
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
                                      Text(
                                        '${currentQuestionIndex + 1}/${tactileQuestions.length}',
                                        style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (currentQuestionIndex + 1) /
                                        tactileQuestions.length,
                                    backgroundColor: Colors.grey[300],
                                    color: AppColors.primary,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'instruction:',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    questionType == 'word_recognition_by_touch'
                                        ? 'Listen to the sound and draw the letter you hear.'
                                        : 'Listen to the sound and draw the letter to complete the word.',
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _audioService.playSound(
                                                      currentQuestion.soundURL,
                                                      speed: 1.0),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.greenMint,
                                                foregroundColor:
                                                    AppColors.textPrimary,
                                                shape: const CircleBorder(),
                                                padding:
                                                    const EdgeInsets.all(24),
                                              ),
                                              child: StreamBuilder<PlayerState>(
                                                stream:
                                                    _audioService.playerState,
                                                builder: (context, snapshot) =>
                                                    Icon(
                                                  snapshot.data ==
                                                          PlayerState.playing
                                                      ? Icons.volume_up
                                                      : Icons.play_arrow,
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _audioService.playSound(
                                                      currentQuestion.soundURL,
                                                      speed: 0.5),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.pink[100],
                                                foregroundColor:
                                                    AppColors.textPrimary,
                                                shape: const CircleBorder(),
                                                padding:
                                                    const EdgeInsets.all(16),
                                              ),
                                              child: const Icon(
                                                  Icons.slow_motion_video,
                                                  size: 24),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (currentQuestion.content != null)
                                          Text(
                                            currentQuestion.content!,
                                            style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final canvasWidth = constraints.maxWidth;
                                      final canvasHeight = canvasWidth * 0.8;
                                      return Stack(
                                        children: [
                                          Container(
                                            width: canvasWidth,
                                            height: canvasHeight,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey[400]!),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Scribble(
                                                  notifier: scribbleNotifier,
                                                  drawPen: true),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  scribbleNotifier.clear();
                                                  selectedAnswer = null;
                                                  _hasDrawn = false;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[100],
                                                foregroundColor:
                                                    AppColors.textPrimary,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                elevation: 0,
                                              ),
                                              child: const Text(
                                                'Clear',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
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
                              color: !_hasDrawn
                                  ? Colors.grey[300]!.withOpacity(0.6)
                                  : AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(-2, -4),
                                  blurRadius: 4,
                                  color: AppColors.grey.withOpacity(0.7),
                                  inset: true,
                                ),
                                if (_hasDrawn)
                                  BoxShadow(
                                    offset: const Offset(2, 4),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.1),
                                    inset: false,
                                  ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: !_hasDrawn
                                  ? null
                                  : () async {
                                      if (isSubmitting) return;
                                      if (selectedAnswer == null) {
                                        await _recognizeLetter();
                                        if (selectedAnswer != null && mounted) {
                                          await _processAnswer(
                                              provider, isLastQuestion);
                                        }
                                      } else {
                                        await _processAnswer(
                                            provider, isLastQuestion);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLastQuestion ? 'Finish' : 'Next',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: !_hasDrawn
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
                                    color: !_hasDrawn
                                        ? Colors.grey[600]
                                        : AppColors.white,
                                  ),
                                ],
                              ),
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
