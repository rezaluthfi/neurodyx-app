import 'package:neurodyx/features/scan/domain/entities/scan_entity.dart';

class ScanModel extends ScanEntity {
  ScanModel({
    super.extractedText,
    super.fontFamily,
    super.fontSize,
    super.characterSpacing,
    super.wordSpacing,
    super.lineHeight,
    super.isBold,
    super.textColor,
    super.backgroundColor,
  });

  factory ScanModel.fromEntity(ScanEntity entity) {
    return ScanModel(
      extractedText: entity.extractedText,
      fontFamily: entity.fontFamily,
      fontSize: entity.fontSize,
      characterSpacing: entity.characterSpacing,
      wordSpacing: entity.wordSpacing,
      lineHeight: entity.lineHeight,
      isBold: entity.isBold,
      textColor: entity.textColor,
      backgroundColor: entity.backgroundColor,
    );
  }

  ScanEntity toEntity() {
    return ScanEntity(
      extractedText: extractedText,
      fontFamily: fontFamily,
      fontSize: fontSize,
      characterSpacing: characterSpacing,
      wordSpacing: wordSpacing,
      lineHeight: lineHeight,
      isBold: isBold,
      textColor: textColor,
      backgroundColor: backgroundColor,
    );
  }
}
