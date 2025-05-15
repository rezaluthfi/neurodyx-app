import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/models/therapy_category_model.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/models/therapy_question_model.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/models/therapy_result_model.dart';

abstract class TherapyRepositoryBase {
  Future<List<TherapyCategoryModel>> getCategories(String type);
  Future<List<TherapyQuestionModel>> getQuestions(String type, String category);
  Future<TherapyResultModel> submitAnswers(
      String type, String category, List<Map<String, dynamic>> submissions);
  Future<TherapyResultModel> getResults(String type, String category);
}
