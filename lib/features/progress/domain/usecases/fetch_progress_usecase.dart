import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository_base.dart';

class FetchProgressUseCase {
  final ProgressRepositoryBase repository;

  FetchProgressUseCase({required this.repository});

  Future<(List<WeeklyProgressEntity>, List<MonthlyProgressEntity>)>
      execute() async {
    try {
      final weekly = await repository.fetchWeeklyProgress();
      final monthly = await repository.fetchMonthlyProgress();
      return (weekly, monthly);
    } catch (e) {
      throw Exception('Failed to fetch progress: $e');
    }
  }
}
