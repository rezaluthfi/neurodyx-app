import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow, Ink;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/therapy_results_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/providers/therapy_provider.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/audio_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/digital_ink_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/domain/usecases/recognize_letter_usecase.dart';
import 'package:provider/provider.dart';
import 'package:scribble/scribble.dart';

class WordRecognitionByTouchPage extends StatefulWidget {
  final String category;

  const WordRecognitionByTouchPage({super.key, required this.category});

  @override
  _WordRecognitionByTouchPageState createState() =>
      _WordRecognitionByTouchPageState();
}

class _WordRecognitionByTouchPageState
    extends State<WordRecognitionByTouchPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  late ScribbleNotifier scribbleNotifier;
  bool isSubmitting = false;
  bool _hasDrawn = false;

  // Create an AudioPlayer instance directly in the page
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  late AudioService _audioService;
  late DigitalInkService _digitalInkService;

  @override
  void initState() {
    super.initState();
    scribbleNotifier = ScribbleNotifier();
    scribbleNotifier.addListener(_onScribbleChanged);

    _audioService = context.read<AudioService>();
    _digitalInkService = context.read<DigitalInkService>();

    // Set up audio player listener
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Reset audio service
    _audioService.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Reset provider to clear model state
        context.read<TherapyProvider>().reset();
        context.read<TherapyProvider>().initializeModel();
        _fetchQuestions();
      }
    });
  }

  void _fetchQuestions() {
    Provider.of<TherapyProvider>(context, listen: false)
        .fetchQuestions('tactile', 'word_recognition_by_touch');
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
    _audioPlayer.dispose(); // Make sure to dispose the audio player
    super.dispose();
  }

  // Play sound directly using AudioPlayer
  Future<void> _playSound(String? url, {double speed = 1.0}) async {
    if (url == null || url.isEmpty) {
      CustomSnackBar.show(context,
          message: 'No audio available', type: SnackBarType.error);
      return;
    }

    try {
      // Stop any currently playing audio
      await _audioPlayer.stop();

      // Set playback rate (speed)
      await _audioPlayer.setPlaybackRate(speed);

      // Play the audio from URL
      await _audioPlayer.play(UrlSource(url));

      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context,
            message: 'Error playing audio: $e', type: SnackBarType.error);
      }
    }
  }

  Future<void> _recognizeLetter() async {
    if (!context.read<TherapyProvider>().isModelDownloaded) {
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

  void _navigateToResults() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const TherapyResultsPage(
          therapyType: 'Tactile',
          category: 'word_recognition_by_touch',
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _processAnswer(
      TherapyProvider provider, bool isLastQuestion) async {
    if (!mounted) return;
    provider.addAnswer(
      'tactile',
      provider.questions
          .where((q) =>
              q.type == 'tactile' && q.category == 'word_recognition_by_touch')
          .toList()[currentQuestionIndex]
          .id,
      selectedAnswer ?? '?',
    );

    if (isLastQuestion) {
      setState(() => isSubmitting = true);
      try {
        await _audioPlayer.stop(); // Stop any playing audio
        await provider.submitAnswers('tactile', 'word_recognition_by_touch');
        if (mounted) _navigateToResults();
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
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        Widget loadingScreen(String message, {bool showAttempts = false}) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Word Recognition by Touch',
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
                'Word Recognition by Touch',
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
                    Text(
                      'Error: ${provider.error ?? "Please check your internet connection and try again."}',
                      style:
                          TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => provider.initializeModel(),
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
                          onPressed: _navigateToResults,
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

        final questions = provider.questions
            .where((q) =>
                q.type == 'tactile' &&
                q.category == 'word_recognition_by_touch')
            .toList();
        if (questions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Word Recognition by Touch',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: const SafeArea(
              child: Center(
                child: Text(
                  'No questions available',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
              ),
            ),
          );
        }

        final currentQuestion = questions[currentQuestionIndex];
        final isLastQuestion = currentQuestionIndex == questions.length - 1;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Word Recognition by Touch',
                style: TextStyle(
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
                                        '${currentQuestionIndex + 1}/${questions.length}',
                                        style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (currentQuestionIndex + 1) /
                                        questions.length,
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
                                    currentQuestion.description ??
                                        'Listen to the sound and draw the letter you hear.',
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
                                              onPressed: () => _playSound(
                                                  currentQuestion.soundURL),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.greenMint,
                                                foregroundColor:
                                                    AppColors.textPrimary,
                                                shape: const CircleBorder(),
                                                padding:
                                                    const EdgeInsets.all(24),
                                              ),
                                              child: Icon(
                                                _isPlaying
                                                    ? Icons.volume_up
                                                    : Icons.play_arrow,
                                                size: 32,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: () => _playSound(
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
