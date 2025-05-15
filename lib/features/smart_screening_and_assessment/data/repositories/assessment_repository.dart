import '../services/assessment_service.dart';
import '../../data/models/assessment_question_model.dart';
import '../../data/models/assessment_result_model.dart';
import '../../domain/repositories/assessment_repository_base.dart';

class AssessmentRepository implements AssessmentRepositoryBase {
  final AssessmentService _assessmentService;

  AssessmentRepository(this._assessmentService);

  @override
  Future<List<AssessmentQuestionModel>> getQuestions() async {
    return await _assessmentService.fetchQuestions();
  }

  @override
  Future<AssessmentResultModel> submitAnswers(
      String type, List<Map<String, dynamic>> submissions) async {
    return await _assessmentService.submitAnswers(type, submissions);
  }

  @override
  Future<List<AssessmentResultModel>> getResults() async {
    return await _assessmentService.fetchResults();
  }
}
