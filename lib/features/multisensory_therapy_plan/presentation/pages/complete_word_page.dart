import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'therapy_results_page.dart';
import 'dart:async';

class CompleteWordPage extends StatefulWidget {
  const CompleteWordPage({super.key});

  @override
  _CompleteWordPageState createState() => _CompleteWordPageState();
}

class _CompleteWordPageState extends State<CompleteWordPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<Offset?> drawingPoints = [];
  bool isDrawingLocked = false;
  Timer? _inactivityTimer;
  String? recognizedLetter = '';
  String currentWord = '';

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'complete_word',
      'title': 'Complete the word by Touch',
      'instruction':
          'Fill in the missing letter by drawing it in the box. Use the clues to complete the word.',
      'word': '_poon',
      'correctAnswer': 's',
      'completedWord': 'spoon',
    },
  ];

  int get totalQuestions => questions.length;

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        isDrawingLocked = true;
      });
    });
  }

  String? recognizeLetter() {
    if (drawingPoints.isEmpty) return null;

    List<Offset> validPoints = [];
    for (var point in drawingPoints) {
      if (point != null) validPoints.add(point);
    }

    if (validPoints.isEmpty) return null;

    int strokeCount = 0;
    for (int i = 0; i < drawingPoints.length; i++) {
      if (drawingPoints[i] == null) strokeCount++;
    }
    strokeCount = strokeCount + 1;

    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (var point in validPoints) {
      minX = minX < point.dx ? minX : point.dx;
      maxX = maxX > point.dx ? maxX : point.dx;
      minY = minY < point.dy ? minY : point.dy;
      maxY = maxY > point.dy ? maxY : point.dy;
    }
    double width = maxX - minX;
    double height = maxY - minY;

    if (width < 5 || height < 5) return "unknown";

    final currentQuestion = questions[currentQuestionIndex];
    String expectedLetter = currentQuestion['correctAnswer'];

    if (expectedLetter == 's') {
      bool hasReasonableSize = height > 10 && width > 10;

      if (hasReasonableSize && strokeCount <= 2) {
        List<Offset> topHalf =
            validPoints.where((p) => p.dy < (minY + maxY) / 2).toList();
        List<Offset> bottomHalf =
            validPoints.where((p) => p.dy >= (minY + maxY) / 2).toList();

        if (topHalf.length > 3 && bottomHalf.length > 3) {
          List<double> xValues = validPoints.map((p) => p.dx).toList();
          xValues.sort();
          double xRange = xValues.last - xValues.first;

          if (xRange > width * 0.4 && validPoints.length > 10) {
            return 's';
          }
        }
      }
    }

    if (expectedLetter == 't') {
      if (strokeCount == 1 && height > width * 1.5) {
        return 't';
      }
    }

    if (width > height * 1.5) return "horizontal line";
    if (height > width * 1.5) return "vertical line";
    if (width / height > 0.8 && width / height < 1.2) return "circle";

    return "unrecognized shape";
  }

  Future<void> showAnswerFeedbackDialog({
    required BuildContext context,
    required bool isCorrect,
    required String correctAnswer,
    required VoidCallback onProceed,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            onProceed();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCorrect ? 'Correct!' : 'Incorrect!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  isCorrect
                      ? AssetPath.iconCorrectAnswer
                      : AssetPath.iconWrongAnswer,
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 80,
                      color: isCorrect ? Colors.green : Colors.red,
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (!isCorrect && currentQuestionIndex < totalQuestions - 1)
                  const Text(
                    'That’s okay! Try the next one!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    "You're doing great!",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void evaluateAnswer() {
    recognizedLetter = recognizeLetter();
    final currentQuestion = questions[currentQuestionIndex];
    if (recognizedLetter == currentQuestion['correctAnswer'] ||
        (recognizedLetter == 's' && currentQuestion['correctAnswer'] == 's') ||
        (recognizedLetter == 't' && currentQuestion['correctAnswer'] == 't')) {
      score++;
      currentWord = currentQuestion['completedWord'];
    }
  }

  void proceedToNextQuestion() {
    evaluateAnswer();

    bool isCorrect =
        recognizedLetter == questions[currentQuestionIndex]['correctAnswer'] ||
            (recognizedLetter == 's' &&
                questions[currentQuestionIndex]['correctAnswer'] == 's') ||
            (recognizedLetter == 't' &&
                questions[currentQuestionIndex]['correctAnswer'] == 't');

    void nextAction() {
      setState(() {
        if (currentQuestionIndex < totalQuestions - 1) {
          currentQuestionIndex++;
          drawingPoints.clear();
          recognizedLetter = '';
          currentWord = questions[currentQuestionIndex]['word'];
          isDrawingLocked = false;
          _inactivityTimer?.cancel();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TherapyResultsPage(
                therapyType: 'Tactile',
                score: score,
                totalQuestions: totalQuestions,
              ),
            ),
          );
        }
      });
    }

    showAnswerFeedbackDialog(
      context: context,
      isCorrect: isCorrect,
      correctAnswer: questions[currentQuestionIndex]['correctAnswer'],
      onProceed: nextAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == totalQuestions - 1;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.offWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            currentQuestion['title'],
            style: const TextStyle(
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
                Text(
                  'instruction :',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentQuestion['instruction'],
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
                        onPressed: () {
                          setState(() {
                            // Placeholder for audio playback logic
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenMint,
                          foregroundColor: AppColors.textPrimary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                        ),
                        child: const Icon(Icons.volume_up, size: 32),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Placeholder for mute logic
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[100],
                          foregroundColor: AppColors.textPrimary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.volume_down, size: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    currentWord.isEmpty ? currentQuestion['word'] : currentWord,
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'draw in here',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onPanUpdate: isDrawingLocked
                          ? null
                          : (details) {
                              setState(() {
                                drawingPoints.add(details.localPosition);
                                _startInactivityTimer();
                              });
                            },
                      onPanEnd: isDrawingLocked
                          ? null
                          : (details) {
                              setState(() {
                                drawingPoints.add(null);
                                _startInactivityTimer();
                              });
                            },
                      child: CustomPaint(
                        painter: DrawingPainter(points: drawingPoints),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                    onPressed: proceedToNextQuestion,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
