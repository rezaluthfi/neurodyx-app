import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';

class ScanInitialUI extends StatelessWidget {
  const ScanInitialUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon camera with circle background and border
          Container(
            padding: const EdgeInsets.all(16), 
            decoration: BoxDecoration(
              color: AppColors.white, 
              shape: BoxShape.circle, 
            ),
            child: Image.asset(
              AssetPath.iconCamera,
              width: 72, 
              height: 72,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan Text',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Use the scan button below to capture text from images or documents',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}