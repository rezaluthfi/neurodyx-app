import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/scan_entity.dart';

TextStyle getTextStyle(ScanEntity entity) {
  TextStyle baseStyle = TextStyle(
    fontSize: entity.fontSize,
    color: entity.textColor,
    fontWeight: entity.isBold ? FontWeight.bold : FontWeight.normal,
    letterSpacing: entity.characterSpacing,
    wordSpacing: entity.wordSpacing,
    height: entity.lineHeight,
  );

  switch (entity.fontFamily) {
    case 'Lexend Exa':
      return GoogleFonts.lexendExa(textStyle: baseStyle);
    case 'Open Sans':
      return GoogleFonts.openSans(textStyle: baseStyle);
    case 'Atkinson Hyperlegible':
      return GoogleFonts.atkinsonHyperlegible(textStyle: baseStyle);
    case 'OpenDyslexicMono':
    default:
      return baseStyle.copyWith(fontFamily: 'OpenDyslexicMono');
  }
}
