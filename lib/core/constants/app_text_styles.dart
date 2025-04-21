import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle heading = GoogleFonts.lexendExa(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle body = GoogleFonts.lexendGiga(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final TextStyle button = GoogleFonts.lexendDeca(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primary,
  );
}
