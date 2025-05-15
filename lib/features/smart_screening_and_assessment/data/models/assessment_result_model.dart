import 'package:equatable/equatable.dart';

class AssessmentResultModel extends Equatable {
  final String type; // visual, auditory, kinesthetic, tactile
  final int correctAnswers;
  final int totalQuestions;
  final String status; // e.g., completed

  const AssessmentResultModel({
    required this.type,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.status,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResultModel(
      type: json['type'] as String,
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'status': status,
    };
  }

  @override
  List<Object> get props => [type, correctAnswers, totalQuestions, status];
}
