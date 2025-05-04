import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/scan/presentation/widgets/text_customization_settings.dart';

void showDyslexiaInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Reading Tips for Dyslexia'),
        content: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: const Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Customizing Your Reading Experience:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                        '• Try the OpenDyslexic font which is specially designed for readers with dyslexia'),
                    Text(
                        '• Increase letter spacing to reduce crowding effects'),
                    Text(
                        '• Add more space between words to make them distinct'),
                    Text(
                        '• Use colored backgrounds like pale yellow to reduce visual stress'),
                    Text(
                        '• Adjust line spacing to help track from one line to the next'),
                    SizedBox(height: 16),
                    Text(
                      'Reading Strategies:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                        '• Use a ruler or your finger to track along lines of text'),
                    Text('• Take breaks when needed to prevent fatigue'),
                    Text('• Read aloud to engage multiple senses'),
                    Text('• Break longer text into smaller, manageable chunks'),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showTextCustomizationSettings(context);
            },
            child: const Text('Customize Text Now'),
          ),
        ],
      );
    },
  );
}
