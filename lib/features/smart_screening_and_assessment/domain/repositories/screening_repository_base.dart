import '../../data/models/screening_question_model.dart';
import '../../data/models/screening_result_model.dart';

abstract class ScreeningRepositoryBase {
  Future<List<QuestionModel>> getQuestions(String ageGroup);
  Future<ScreeningResultModel> submitAnswers(
      List<bool> answers, String ageGroup);
}
