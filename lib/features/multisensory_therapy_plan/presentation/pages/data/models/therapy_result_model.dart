import 'package:equatable/equatable.dart';

class TherapyResultModel extends Equatable {
  final String type;
  final String category;
  final int correctAnswers;
  final int totalQuestions;
  final String status;

  const TherapyResultModel({
    required this.type,
    required this.category,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.status,
  });

  factory TherapyResultModel.fromJson(Map<String, dynamic> json) {
    return TherapyResultModel(
      type: json['type'] as String? ?? 'unknown',
      category: json['category'] as String? ?? 'unknown',
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'category': category,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'status': status,
    };
  }

  @override
  List<Object> get props =>
      [type, category, correctAnswers, totalQuestions, status];
}
