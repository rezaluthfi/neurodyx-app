import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback onPressed;
  final bool isPrimary;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child ??
          Text(
            text ?? '',
            style: AppTextStyles.button.copyWith(
              color: isPrimary
                  ? AppColors.textPrimary
                  : AppColors.textPrimary.withOpacity(0.7),
              fontWeight: FontWeight.normal,
            ),
          ),
    );
  }
}
