import '../models/screening_question_model.dart';
import '../models/screening_result_model.dart';
import '../services/screening_service.dart';
import '../../domain/repositories/screening_repository_base.dart';

class ScreeningRepository implements ScreeningRepositoryBase {
  final ScreeningService _screeningService;

  ScreeningRepository(this._screeningService);

  @override
  Future<List<QuestionModel>> getQuestions(String ageGroup) async {
    return await _screeningService.fetchQuestions(ageGroup);
  }

  @override
  Future<ScreeningResultModel> submitAnswers(
      List<bool> answers, String ageGroup) async {
    return await _screeningService.submitAnswers(answers, ageGroup);
  }
}
