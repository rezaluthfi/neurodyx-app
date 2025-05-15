import 'package:neurodyx/features/smart_screening_and_assessment/domain/entities/screening_question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.ageGroup,
    required super.question,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      ageGroup: json['ageGroup'] as String,
      question: json['question'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageGroup': ageGroup,
      'question': question,
    };
  }
}
