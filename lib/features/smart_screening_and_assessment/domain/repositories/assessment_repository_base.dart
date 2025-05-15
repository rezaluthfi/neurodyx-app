import '../../data/models/assessment_question_model.dart';
import '../../data/models/assessment_result_model.dart';

abstract class AssessmentRepositoryBase {
  Future<List<AssessmentQuestionModel>> getQuestions();
  Future<AssessmentResultModel> submitAnswers(
      String type, List<Map<String, dynamic>> submissions);
  Future<List<AssessmentResultModel>> getResults();
}
