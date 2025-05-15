import 'package:neurodyx/features/smart_screening_and_assessment/domain/entities/screening_result_entity.dart';

class ScreeningResultModel extends ScreeningResultEntity {
  const ScreeningResultModel({
    required super.riskLevel,
  });

  factory ScreeningResultModel.fromJson(Map<String, dynamic> json) {
    return ScreeningResultModel(
      riskLevel: json['riskLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'riskLevel': riskLevel,
    };
  }
}
