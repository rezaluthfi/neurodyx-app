import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/scan/presentation/widgets/dyslexia_info_dialog.dart';

class ScanInfoBar extends StatelessWidget {
  const ScanInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Customize text display to make reading easier',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => showDyslexiaInfoDialog(context),
            child: const Text(
              'Learn More',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
