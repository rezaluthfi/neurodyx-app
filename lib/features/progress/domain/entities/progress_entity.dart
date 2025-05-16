class WeeklyProgressEntity {
  final String userID;
  final DateTime date;
  final int therapyCount;
  final bool streakAchieved;

  WeeklyProgressEntity({
    required this.userID,
    required this.date,
    required this.therapyCount,
    required this.streakAchieved,
  });
}

class MonthlyProgressEntity {
  final DateTime date;
  final String status;

  MonthlyProgressEntity({
    required this.date,
    required this.status,
  });
}
