import '../../domain/entities/progress_entity.dart';

abstract class ProgressRepositoryBase {
  Future<List<WeeklyProgressEntity>> fetchWeeklyProgress();
  Future<List<MonthlyProgressEntity>> fetchMonthlyProgress();
}
