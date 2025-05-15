import 'package:neurodyx/features/multisensory_therapy_plan/domain/repositories/therapy_repository_base.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/services/therapy_services.dart';

import '../models/therapy_category_model.dart';
import '../models/therapy_question_model.dart';
import '../models/therapy_result_model.dart';

class TherapyRepository implements TherapyRepositoryBase {
  final TherapyService _therapyService;

  TherapyRepository(this._therapyService);

  @override
  Future<List<TherapyCategoryModel>> getCategories(String type) async {
    return await _therapyService.fetchCategories(type);
  }

  @override
  Future<List<TherapyQuestionModel>> getQuestions(
      String type, String category) async {
    return await _therapyService.fetchQuestions(type, category);
  }

  @override
  Future<TherapyResultModel> submitAnswers(String type, String category,
      List<Map<String, dynamic>> submissions) async {
    return await _therapyService.submitAnswers(type, category, submissions);
  }

  @override
  Future<TherapyResultModel> getResults(String type, String category) async {
    return await _therapyService.fetchResults(type, category);
  }
}
