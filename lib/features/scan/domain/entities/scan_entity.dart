import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ScanEntity extends Equatable {
  final String? extractedText;
  final String fontFamily;
  final double fontSize;
  final double characterSpacing;
  final double wordSpacing;
  final double lineHeight;
  final bool isBold;
  final Color textColor;
  final Color backgroundColor;

  const ScanEntity({
    this.extractedText,
    this.fontFamily = 'OpenDyslexic',
    this.fontSize = 18.0,
    this.characterSpacing = 0.5,
    this.wordSpacing = 5.0,
    this.lineHeight = 1.5,
    this.isBold = false,
    this.textColor = Colors.black,
    this.backgroundColor = const Color(0xFFFFF9C4), // Pale yellow
  });

  ScanEntity copyWith({
    String? extractedText,
    String? fontFamily,
    double? fontSize,
    double? characterSpacing,
    double? wordSpacing,
    double? lineHeight,
    bool? isBold,
    Color? textColor,
    Color? backgroundColor,
  }) {
    return ScanEntity(
      extractedText: extractedText ?? this.extractedText,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      characterSpacing: characterSpacing ?? this.characterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      isBold: isBold ?? this.isBold,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  List<Object?> get props => [
        extractedText,
        fontFamily,
        fontSize,
        characterSpacing,
        wordSpacing,
        lineHeight,
        isBold,
        textColor,
        backgroundColor,
      ];
}
