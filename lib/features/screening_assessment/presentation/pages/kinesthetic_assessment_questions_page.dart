import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import '../../../../../core/constants/app_colors.dart';

class KinestheticAssessmentQuestionsPage extends StatefulWidget {
  const KinestheticAssessmentQuestionsPage({super.key});

  @override
  _KinestheticAssessmentQuestionsPageState createState() =>
      _KinestheticAssessmentQuestionsPageState();
}

class _KinestheticAssessmentQuestionsPageState
    extends State<KinestheticAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer; // For letter_differentiation
  List<String> droppedAnswers = []; // For letter_matching
  Map<String, String> matches =
      {}; // For number_letter_similarity: option -> match
  List<MapEntry<String, String>> matchedPairs =
      []; // Track matched pairs for line drawing
  Map<String, GlobalKey> optionKeys = {}; // Store option widget keys
  Map<String, GlobalKey> matchKeys = {}; // Store match widget keys
  final GlobalKey _customPaintKey = GlobalKey(); // Key for CustomPaint

  final List<Map<String, dynamic>> questions = [
    // Letter Differentiation
    {
      'type': 'letter_differentiation',
      'title': 'Letter Differentiation',
      'instruction': 'Drag the different letter to the box.',
      'options': ['p', 'p', 'p', 'q', 'p', 'p'],
      'correctAnswer': 'q',
      'dropCount': 1,
    },
    // Number & Letter Similarity
    {
      'type': 'number_letter_similarity',
      'title': 'Number & Letter Similarity',
      'instruction': 'Tap to match each letter/number with its pair.',
      'options': ['g', '4', 'q'],
      'matches': ['q', 'g', '4', 'A'],
      'correctAnswer': ['g-g', '4-4', 'q-q'], // Format: source-target
    },
    // Letter Matching
    {
      'type': 'letter_matching',
      'title': 'Letter Matching',
      'instruction':
          'Drag the correct letters into the boxes to complete the word.',
      'question': 'dog',
      'image': AssetPath.imgDummyKinesthetic1,
      'options': ['b', 'd', 'o', 'a', 'g'],
      'correctAnswer': ['d', 'o', 'g'],
      'dropCount': 3,
    },
  ];

  int get totalQuestions => questions.length;

  @override
  void initState() {
    super.initState();
    // Initialize keys for the first question
    _initializeKeys();

    // Schedule a post-frame callback to ensure widgets are laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _initializeKeys() {
    final currentQuestion = questions[currentQuestionIndex];

    // Clear existing keys
    optionKeys.clear();
    matchKeys.clear();

    // Initialize keys for options
    if (currentQuestion['options'] != null) {
      final options = currentQuestion['options'] as List<String>;
      for (int i = 0; i < options.length; i++) {
        String option = options[i];
        String optionId = '${option}_$i';
        optionKeys[optionId] = GlobalKey();
      }
    }

    // Initialize keys for matches (only for number_letter_similarity)
    if (currentQuestion['type'] == 'number_letter_similarity' &&
        currentQuestion['matches'] != null) {
      final matches = currentQuestion['matches'] as List<String>;
      for (int i = 0; i < matches.length; i++) {
        String match = matches[i];
        String matchId = '${match}_$i';
        matchKeys[matchId] = GlobalKey();
      }
    }
  }

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer; // Store the selected answer for validation
    });
  }

  void handleMatchSelection(String option, String match) {
    setState(() {
      // Remove the match if it's already matched with another option
      matches.removeWhere((key, value) => value == match);

      // Remove previous match for this option if any
      if (matches.containsKey(option)) {
        matches.remove(option);
      }

      // Add the new match
      matches[option] = match;
      matchedPairs = matches.entries.toList();

      // Trigger a rebuild on the next frame to ensure the lines are drawn correctly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
  }

  void clearSelection(String option) {
    setState(() {
      if (matches.containsKey(option)) {
        matches.remove(option);
        matchedPairs = matches.entries.toList();

        // Trigger a rebuild on the next frame to ensure the lines are redrawn
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  // Berikut adalah perbaikan untuk metode proceedToNextQuestion()
  void proceedToNextQuestion() {
    final currentQuestion = questions[currentQuestionIndex];
    bool canProceed = false;
    bool isCorrect = false;

    // Check if the user can proceed based on question type
    if (currentQuestion['type'] == 'letter_differentiation' &&
        selectedAnswer != null) {
      isCorrect = selectedAnswer == currentQuestion['correctAnswer'];
      canProceed = true;
    } else if (currentQuestion['type'] == 'number_letter_similarity' &&
        matches.length == (currentQuestion['options'] as List).length) {
      // Modified logic: Only mark as correct if ALL matches are correct
      // Count how many matches are correct
      int correctMatches = 0;
      final correctAnswers = currentQuestion['correctAnswer'] as List<String>;

      // Check if each pair is in the correct answers list
      for (var pair in matches.entries) {
        if (correctAnswers.contains('${pair.key}-${pair.value}')) {
          correctMatches++;
        }
      }

      // Only mark as correct if ALL matches are correct
      isCorrect = correctMatches == matches.length &&
          correctMatches == correctAnswers.length;
      canProceed = true;
    } else if (currentQuestion['type'] == 'letter_matching' &&
        droppedAnswers.length == currentQuestion['dropCount']) {
      isCorrect = listEquals(droppedAnswers, currentQuestion['correctAnswer']);
      canProceed = true;
    }

    if (canProceed) {
      // Add to score if correct
      if (isCorrect) {
        // For all question types, only give 1 point per question
        score++;
      }

      setState(() {
        if (currentQuestionIndex < totalQuestions - 1) {
          // Move to next question
          currentQuestionIndex++;

          // Reset state for next question
          selectedAnswer = null;
          droppedAnswers = [];
          matches = {};
          matchedPairs = [];

          // Initialize keys for the new question
          _initializeKeys();

          // Force redraw on next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        } else {
          // This is the last question - pop twice to return to DyslexiaAssessmentPage
          Navigator.of(context)
              .pop(score); // Pop KinestheticAssessmentQuestionsPage
          Navigator.of(context).pop(); // Pop AssessmentReadyPage
        }
      });
    }
  }

  // Helper method to compare lists (used for letter_matching)
  bool listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final questionType = currentQuestion['type'];
    final isLastQuestion = currentQuestionIndex == totalQuestions - 1;

    bool canProceed = false;
    if (questionType == 'letter_differentiation' && selectedAnswer != null) {
      canProceed = true;
    } else if (questionType == 'number_letter_similarity' &&
        matches.length == (currentQuestion['options'] as List).length) {
      canProceed = true;
    } else if (questionType == 'letter_matching' &&
        droppedAnswers.length == currentQuestion['dropCount']) {
      canProceed = true;
    }

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.offWhite,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
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

                // Instruction
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

                // Wrap the main content in an Expanded widget to make sure it doesn't overflow
                Expanded(
                  child: SingleChildScrollView(
                    child: buildQuestionContent(currentQuestion, questionType),
                  ),
                ),

                const SizedBox(height: 16),

                // Next Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: !canProceed
                        ? Colors.grey[300]!.withOpacity(0.6)
                        : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(-2, -4),
                        blurRadius: 4,
                        color: AppColors.grey.withOpacity(0.7),
                        inset: true,
                      ),
                      if (canProceed)
                        BoxShadow(
                          offset: const Offset(2, 4),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.1),
                          inset: false,
                        ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: canProceed ? proceedToNextQuestion : null,
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
                            color: !canProceed
                                ? Colors.grey[600]
                                : AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastQuestion ? Icons.check : Icons.arrow_forward,
                          size: 20,
                          color:
                              !canProceed ? Colors.grey[600] : AppColors.white,
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

  Widget buildQuestionContent(
      Map<String, dynamic> currentQuestion, String questionType) {
    switch (questionType) {
      case 'letter_differentiation':
        return buildLetterDifferentiationContent(currentQuestion);
      case 'number_letter_similarity':
        return buildNumberLetterSimilarityContent(currentQuestion);
      case 'letter_matching':
        return buildLetterMatchingContent(currentQuestion);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildLetterDifferentiationContent(
      Map<String, dynamic> currentQuestion) {
    return Column(
      children: [
        // Options (Draggable)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: (currentQuestion['options'] as List<String>)
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final option = entry.value;
            final optionId = '${option}_$index';
            return Draggable<String>(
              data: option,
              child: _buildOptionButton(option, id: optionId),
              feedback: _buildOptionButton(option),
              childWhenDragging: Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        // Drop Area
        Center(
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: selectedAnswer != null
                    ? Center(
                        child: Text(
                          selectedAnswer!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              );
            },
            onWillAccept: (data) => true,
            onAccept: (data) {
              setState(() {
                droppedAnswers = [data];
                selectedAnswer = data;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildNumberLetterSimilarityContent(
      Map<String, dynamic> currentQuestion) {
    // Get the options and matches
    final options = currentQuestion['options'] as List<String>;
    final matchesList = currentQuestion['matches'] as List<String>;

    // Make sure keys are initialized
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      final optionId = '${option}_$i';
      if (!optionKeys.containsKey(optionId)) {
        optionKeys[optionId] = GlobalKey();
      }
    }

    for (int i = 0; i < matchesList.length; i++) {
      final match = matchesList[i];
      final matchId = '${match}_$i';
      if (!matchKeys.containsKey(matchId)) {
        matchKeys[matchId] = GlobalKey();
      }
    }

    // Fixed container height is removed to prevent overflow issues
    return Column(
      children: [
        // This is the main container for match options
        // We wrap it in a SizedBox with a reasonable fixed height
        // and then put our matching UI in a Stack inside it
        SizedBox(
          height:
              400, // Give enough height to show all options with scrolling if needed
          child: Stack(
            children: [
              // CustomPaint for drawing lines
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: _customPaintKey,
                    painter: LinePainter(
                      pairs: matchedPairs,
                      optionKeys: optionKeys,
                      matchKeys: matchKeys,
                      options: options,
                      matches: matchesList,
                      constraints: const BoxConstraints(),
                      customPaintRenderBox: _customPaintKey.currentContext
                          ?.findRenderObject() as RenderBox?,
                    ),
                  ),
                ),
              ),

              // The actual UI elements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Options (Left Side) - with extra padding to ensure visibility
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final optionId = '${option}_$index';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: GestureDetector(
                              onTap: () => clearSelection(option),
                              child: _buildOptionButton(
                                option,
                                isSelected: matches.containsKey(option),
                                id: optionId,
                                key: optionKeys[optionId],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Matches (Right Side) - with extra padding to ensure visibility
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: matchesList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final match = entry.value;
                          final matchId = '${match}_$index';

                          bool isMatched = matches.containsValue(match);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: GestureDetector(
                              onTap: () {
                                // Find first unmatched option
                                final unmatched = options.firstWhere(
                                  (opt) => !matches.containsKey(opt),
                                  orElse: () => '',
                                );

                                if (unmatched.isNotEmpty && !isMatched) {
                                  handleMatchSelection(unmatched, match);
                                }
                              },
                              child: _buildOptionButton(
                                match,
                                isSelected: isMatched,
                                id: matchId,
                                key: matchKeys[matchId],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLetterMatchingContent(Map<String, dynamic> currentQuestion) {
    return Column(
      children: [
        // Show image if available
        if (currentQuestion['image'] != null)
          Image.asset(
            currentQuestion['image'], // Memuat gambar dari aset
            height: 150,
            width: 150,
            fit: BoxFit.cover, // Sesuaikan gambar dengan ukuran container
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                width: 150,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'Failed to load image: $error',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),

        // Show the word to complete
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (currentQuestion['question'] as String)
              .split('')
              .map((char) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      char,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 32),

        // Drop Areas for letters
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            (currentQuestion['dropCount'] as int),
            (index) => DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: droppedAnswers.length > index
                      ? Center(
                          child: Text(
                            droppedAnswers[index],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                );
              },
              onWillAccept: (data) => true,
              onAccept: (data) {
                setState(() {
                  if (droppedAnswers.length <= index) {
                    while (droppedAnswers.length < index) {
                      droppedAnswers.add('');
                    }
                    droppedAnswers.add(data);
                  } else {
                    droppedAnswers[index] = data;
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Options (Draggable letters)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: (currentQuestion['options'] as List<String>)
              .map((option) => Draggable<String>(
                    data: option,
                    child: _buildOptionButton(option),
                    feedback: _buildOptionButton(option),
                    childWhenDragging: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String text,
      {bool isSelected = false, String? id, Key? key}) {
    return Container(
      key: key, // Use the provided key for positioning
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey[200],
        border:
            isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            const Positioned(
              top: 2,
              right: 2,
              child: Icon(
                Icons.check,
                size: 16,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Painter for drawing lines between matched pairs
class LinePainter extends CustomPainter {
  final List<MapEntry<String, String>> pairs;
  final Map<String, GlobalKey> optionKeys;
  final Map<String, GlobalKey> matchKeys;
  final List<String> options;
  final List<String> matches;
  final BoxConstraints constraints;
  final RenderBox? customPaintRenderBox;

  LinePainter({
    required this.pairs,
    required this.optionKeys,
    required this.matchKeys,
    required this.options,
    required this.matches,
    required this.constraints,
    required this.customPaintRenderBox,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (customPaintRenderBox == null) return;

    for (var pair in pairs) {
      final option = pair.key;
      final match = pair.value;

      // Find the right keys for this pair
      GlobalKey? optionKey;
      GlobalKey? matchKey;

      // Find optionKey that contains this option
      for (var entry in optionKeys.entries) {
        if (entry.key.startsWith('${option}_')) {
          optionKey = entry.value;
          break;
        }
      }

      // Find matchKey that contains this match
      for (var entry in matchKeys.entries) {
        if (entry.key.startsWith('${match}_')) {
          matchKey = entry.value;
          break;
        }
      }

      if (optionKey != null && matchKey != null) {
        final RenderBox? optionRenderBox =
            optionKey.currentContext?.findRenderObject() as RenderBox?;
        final RenderBox? matchRenderBox =
            matchKey.currentContext?.findRenderObject() as RenderBox?;

        if (optionRenderBox != null && matchRenderBox != null) {
          try {
            // Get positions relative to the CustomPaint widget
            final optionPos = optionRenderBox.localToGlobal(Offset.zero);
            final matchPos = matchRenderBox.localToGlobal(Offset.zero);

            // Get the position of the CustomPaint widget itself
            final painterPos = customPaintRenderBox!.localToGlobal(Offset.zero);

            // Calculate positions relative to the CustomPaint widget
            final optionRelativePos = Offset(
              optionPos.dx - painterPos.dx + optionRenderBox.size.width,
              optionPos.dy - painterPos.dy + optionRenderBox.size.height / 2,
            );

            final matchRelativePos = Offset(
              matchPos.dx - painterPos.dx,
              matchPos.dy - painterPos.dy + matchRenderBox.size.height / 2,
            );

            // Draw the line
            canvas.drawLine(optionRelativePos, matchRelativePos, paint);
          } catch (e) {
            // Handle any errors safely
            print('Error drawing line: $e');
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
