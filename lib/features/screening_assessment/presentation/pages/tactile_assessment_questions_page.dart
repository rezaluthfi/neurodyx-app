import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'dart:async';

import '../../../../../core/constants/app_colors.dart';

class TactileAssessmentQuestionsPage extends StatefulWidget {
  const TactileAssessmentQuestionsPage({super.key});

  @override
  _TactileAssessmentQuestionsPageState createState() =>
      _TactileAssessmentQuestionsPageState();
}

class _TactileAssessmentQuestionsPageState
    extends State<TactileAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<Offset?> drawingPoints = []; // To store drawing points
  bool isPlaying = false; // For audio playback state
  String? recognizedLetter = ''; // To store the recognized letter
  bool isDrawingLocked = false; // To lock drawing after inactivity
  Timer? _inactivityTimer; // Timer for detecting drawing inactivity

  final List<Map<String, dynamic>> questions = [
    // Word Recognition by Touch
    {
      'type': 'word_recognition',
      'title': 'Word Recognition by Touch',
      'instruction': 'Can you draw this letter? Try writing it in the box!',
      'letter': 'U',
      'correctAnswer': 'U',
    },
    // Complete the Word by Touch
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

  // Start or reset the inactivity timer
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        isDrawingLocked = true; // Lock drawing after 2 seconds of inactivity
      });
    });
  }

  // Enhanced letter recognition algorithm
  String? recognizeLetter() {
    if (drawingPoints.isEmpty) return null;

    // Only keep non-null points for analysis
    List<Offset> validPoints = [];
    for (var point in drawingPoints) {
      if (point != null) validPoints.add(point);
    }

    if (validPoints.isEmpty) return null;

    // Count strokes (segments separated by null)
    int strokeCount = 0;
    for (int i = 0; i < drawingPoints.length; i++) {
      if (drawingPoints[i] == null) strokeCount++;
    }
    strokeCount = strokeCount + 1; // Add 1 for the last stroke

    // Calculate bounding box
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

    if (width < 5 || height < 5) {
      // Drawing too small to analyze accurately
      return "unknown"; // Return "unknown" instead of null
    }

    // Get current question to contextualize recognition
    final currentQuestion = questions[currentQuestionIndex];
    String expectedLetter = currentQuestion['correctAnswer'];

    // ---- LETTER DETECTION ALGORITHMS ----

    // Detect U shape
    if (expectedLetter == 'U') {
      // Less strict criteria for U detection
      bool isVertical = height > width * 0.8; // Less strict height requirement

      // Check for bottom curve
      List<Offset> bottomPoints = validPoints
          .where((p) => p.dy > (minY + maxY) / 2) // Points in bottom half
          .toList();

      if (bottomPoints.isNotEmpty && isVertical) {
        // Check for gap at top
        List<Offset> topPoints = validPoints
            .where((p) => p.dy < minY + height * 0.2) // Top 20% points
            .toList();

        // Sort by x position to find spread
        List<double> topXValues = topPoints.map((p) => p.dx).toList();
        topXValues.sort();

        // If we have a reasonable U shape with some points at bottom
        if (bottomPoints.length > validPoints.length * 0.3) {
          return 'U';
        }
      }
    }

    // Detect S shape - MUCH more lenient
    else if (expectedLetter == 's') {
      // S typically has a reasonable aspect ratio
      bool hasReasonableSize = height > 10 && width > 10;

      // S shape typically changes direction - look for both left and right horizontal movement
      if (hasReasonableSize && strokeCount <= 2) {
        // Look for roughly equal distribution of points in top and bottom halves
        List<Offset> topHalf =
            validPoints.where((p) => p.dy < (minY + maxY) / 2).toList();
        List<Offset> bottomHalf =
            validPoints.where((p) => p.dy >= (minY + maxY) / 2).toList();

        // For S, we usually want points in both halves
        if (topHalf.length > 3 && bottomHalf.length > 3) {
          // Look for horizontal movement
          List<double> xValues = validPoints.map((p) => p.dx).toList();
          xValues.sort();
          double xRange = xValues.last - xValues.first;

          // If there's horizontal movement and a reasonable number of points, likely an S
          if (xRange > width * 0.4 && validPoints.length > 10) {
            return 's';
          }
        }
      }
    }

    // Return specific letter guesses for common shapes
    if (width > height * 1.5) {
      return "horizontal line"; // Possibly "-", "_"
    } else if (height > width * 1.5) {
      return "vertical line"; // Winning "I", "l", "1"
    } else if (width / height > 0.8 && width / height < 1.2) {
      return "circle"; // Possibly "O", "0"
    }

    // If we can't determine the letter with confidence, return a descriptive message
    return "unrecognized shape";
  }

  void evaluateAnswer() {
    final currentQuestion = questions[currentQuestionIndex];

    // Recognize the drawn letter
    recognizedLetter = recognizeLetter();

    // Check if the recognized letter matches the expected answer
    if (recognizedLetter == currentQuestion['correctAnswer']) {
      score++; // Increment score

      // For complete_word type, update the displayed word
      if (currentQuestion['type'] == 'complete_word') {
        questions[currentQuestionIndex]['word'] =
            currentQuestion['completedWord']; // Display the completed word
      }
    }
  }

  void proceedToNextQuestion() {
    // Evaluate the answer first without showing feedback
    evaluateAnswer();

    setState(() {
      // Move to next question or finish
      if (currentQuestionIndex < totalQuestions - 1) {
        currentQuestionIndex++;
        drawingPoints.clear();
        recognizedLetter = '';
        isDrawingLocked = false; // Unlock drawing for the next question
        _inactivityTimer?.cancel();
      } else {
        // Finish: Pop twice to return to DyslexiaAssessmentPage with score
        Navigator.pop(context, score); // Pop TactileAssessmentQuestionsPage
        Navigator.pop(context, score); // Pop AssessmentReadyPage
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == totalQuestions - 1;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.offWhite,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove default back button
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
                // Progress Indicator - Adding this from VisualAssessmentQuestionsPage
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
                const SizedBox(height: 16),

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

                // Audio Control Buttons
                // Sound Playback Buttons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isPlaying =
                                true; // Update state if needed for audio logic
                          });
                          // Add audio playback logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenMint,
                          foregroundColor: AppColors.textPrimary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.volume_up, size: 24),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isPlaying =
                                false; // Update state if needed for audio logic
                          });
                          // Add mute logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[100],
                          foregroundColor: AppColors.textPrimary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.volume_off, size: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Display Letter or Word
                Center(
                  child: Text(
                    currentQuestion['type'] == 'word_recognition'
                        ? currentQuestion['letter']
                        : currentQuestion['word'],
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

                // Drawing Area with Outline
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
                                _startInactivityTimer(); // Reset timer on draw
                              });
                            },
                      onPanEnd: isDrawingLocked
                          ? null
                          : (details) {
                              setState(() {
                                drawingPoints.add(null); // End of stroke
                                _startInactivityTimer(); // Start timer on draw end
                              });
                            },
                      child: CustomPaint(
                        painter: DrawingPainter(points: drawingPoints),
                        size: Size.infinite, // Allow full expansion
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Next button
                Row(
                  children: [
                    Expanded(
                      child: Container(
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

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}

mixin Ascending {}

// Custom Painter for Drawing
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
