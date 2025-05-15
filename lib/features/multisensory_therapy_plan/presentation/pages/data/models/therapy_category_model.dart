import 'package:equatable/equatable.dart';

class TherapyCategoryModel extends Equatable {
  final String category;
  final String description;

  const TherapyCategoryModel({
    required this.category,
    required this.description,
  });

  factory TherapyCategoryModel.fromJson(Map<String, dynamic> json) {
    return TherapyCategoryModel(
      category: json['category'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
    };
  }

  @override
  List<Object> get props => [category, description];
}
