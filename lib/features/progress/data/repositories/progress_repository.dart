import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository_base.dart';
import '../services/progress_service.dart';

class ProgressRepository implements ProgressRepositoryBase {
  final ProgressService progressService;

  ProgressRepository({required this.progressService});

  @override
  Future<List<WeeklyProgressEntity>> fetchWeeklyProgress() async {
    try {
      final models = await progressService.fetchWeeklyProgress();
      return models
          .map((model) => WeeklyProgressEntity(
                userID: model.userID,
                date: model.date,
                therapyCount: model.therapyCount,
                streakAchieved: model.streakAchieved,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch weekly progress: $e');
    }
  }

  @override
  Future<List<MonthlyProgressEntity>> fetchMonthlyProgress() async {
    try {
      final models = await progressService.fetchMonthlyProgress();
      return models
          .map((model) => MonthlyProgressEntity(
                date: model.date,
                status: model.status,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch monthly progress: $e');
    }
  }
}
