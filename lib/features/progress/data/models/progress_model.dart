class WeeklyProgressModel {
  final String userID;
  final DateTime date;
  final int therapyCount;
  final bool streakAchieved;

  WeeklyProgressModel({
    required this.userID,
    required this.date,
    required this.therapyCount,
    required this.streakAchieved,
  });

  factory WeeklyProgressModel.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressModel(
      userID: json['userID'] as String,
      date: DateTime.parse(json['date'] as String),
      therapyCount: json['therapyCount'] as int,
      streakAchieved: json['streakAchieved'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'date': date.toIso8601String(),
      'therapyCount': therapyCount,
      'streakAchieved': streakAchieved,
    };
  }
}

class MonthlyProgressModel {
  final DateTime date;
  final String status;

  MonthlyProgressModel({
    required this.date,
    required this.status,
  });

  factory MonthlyProgressModel.fromJson(Map<String, dynamic> json) {
    return MonthlyProgressModel(
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
