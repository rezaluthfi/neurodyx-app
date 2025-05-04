import 'dart:io';
import 'package:neurodyx/features/scan/data/services/text_recognition_service.dart';
import 'package:neurodyx/features/scan/domain/entities/scan_entity.dart';
import 'package:neurodyx/features/scan/domain/repositories/scan_repository_base.dart';

class ScanRepository implements ScanRepositoryBase {
  final TextRecognitionService textRecognitionService;

  ScanRepository({required this.textRecognitionService});

  @override
  Future<ScanEntity> extractTextFromImage(File image) async {
    final extractedText = await textRecognitionService.extractText(image);
    return ScanEntity(extractedText: extractedText);
  }
}
