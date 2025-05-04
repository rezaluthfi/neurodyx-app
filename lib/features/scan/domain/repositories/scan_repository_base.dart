import 'dart:io';
import 'package:neurodyx/features/scan/domain/entities/scan_entity.dart';

abstract class ScanRepositoryBase {
  Future<ScanEntity> extractTextFromImage(File image);
}
