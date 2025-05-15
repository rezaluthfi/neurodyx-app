class TherapyQuestionModel {
  final String id;
  final String type;
  final String category;
  final String? content;
  final String? description;
  final String? imageURL;
  final String? soundURL; // Added soundURL
  final List<String>? options;
  final String? correctAnswer;
  final Map<String, String>? correctPairs;
  final List<String>? correctSequence;

  TherapyQuestionModel({
    required this.id,
    required this.type,
    required this.category,
    this.content,
    this.description,
    this.imageURL,
    this.soundURL, // Added to constructor
    this.options,
    this.correctAnswer,
    this.correctPairs,
    this.correctSequence,
  });

  factory TherapyQuestionModel.fromJson(Map<String, dynamic> json) {
    // Derive correctAnswer from correctPairs if not provided
    String? correctAnswer = json['correctAnswer'] as String?;
    final correctPairs =
        (json['correctPairs'] as Map<String, dynamic>?)?.cast<String, String>();
    if (correctAnswer == null && correctPairs != null) {
      correctAnswer =
          correctPairs.entries.map((e) => '${e.key}-${e.value}').join(',');
    }

    return TherapyQuestionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      content: json['content'] as String?,
      description: json['description'] as String?,
      imageURL: json['imageURL'] as String?,
      soundURL: json['soundURL'] as String?, // Parse soundURL
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      correctAnswer: correctAnswer,
      correctPairs: correctPairs,
      correctSequence:
          (json['correctSequence'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
