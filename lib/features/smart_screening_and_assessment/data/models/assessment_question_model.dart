import 'package:equatable/equatable.dart';

class AssessmentQuestionModel extends Equatable {
  final String id;
  final String type; // visual, auditory, kinesthetic, tactile
  final String category; // e.g., complete_word, letter_recognition
  final String? content; // e.g., "_at", "d", "b_llon"
  final String? imageURL;
  final String? soundURL;
  final List<String>? options; // for multiple-choice
  final String? correctAnswer; // for single answer
  final List<String>? correctSequence; // for letter_matching
  final Map<String, String>? correctPairs; // for number_letter_similarity
  final List<String>? leftItems; // for number_letter_similarity
  final List<String>? rightItems; // for number_letter_similarity

  const AssessmentQuestionModel({
    required this.id,
    required this.type,
    required this.category,
    this.content,
    this.imageURL,
    this.soundURL,
    this.options,
    this.correctAnswer,
    this.correctSequence,
    this.correctPairs,
    this.leftItems,
    this.rightItems,
  });

  factory AssessmentQuestionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      content: json['content'] as String?,
      imageURL: json['imageURL'] as String?,
      soundURL: json['soundURL'] as String?,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      correctAnswer: json['correctAnswer'] as String?,
      correctSequence:
          (json['correctSequence'] as List<dynamic>?)?.cast<String>(),
      correctPairs: (json['correctPairs'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
      leftItems: (json['leftItems'] as List<dynamic>?)?.cast<String>(),
      rightItems: (json['rightItems'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'content': content,
      'imageURL': imageURL,
      'soundURL': soundURL,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctSequence': correctSequence,
      'correctPairs': correctPairs,
      'leftItems': leftItems,
      'rightItems': rightItems,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        content,
        imageURL,
        soundURL,
        options,
        correctAnswer,
        correctSequence,
        correctPairs,
        leftItems,
        rightItems,
      ];
}
