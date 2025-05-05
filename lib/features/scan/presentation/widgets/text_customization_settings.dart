import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/scan/presentation/widgets/font_utils.dart';
import 'package:provider/provider.dart';

void showTextCustomizationSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = Provider.of<ScanProvider>(context);
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Customize Text Display',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: provider.scanEntity.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'This is how your text will look with these settings.',
                    style: getTextStyle(provider.scanEntity),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSliderSetting(
                  title: 'Font Size',
                  value: provider.scanEntity.fontSize,
                  min: 12,
                  max: 32,
                  onChanged: (value) {
                    setModalState(() =>
                        provider.updateTextCustomization(fontSize: value));
                  },
                ),
                _buildSliderSetting(
                  title: 'Character Spacing',
                  value: provider.scanEntity.characterSpacing,
                  min: 0,
                  max: 3,
                  onChanged: (value) {
                    setModalState(() => provider.updateTextCustomization(
                        characterSpacing: value));
                  },
                ),
                _buildSliderSetting(
                  title: 'Word Spacing',
                  value: provider.scanEntity.wordSpacing,
                  min: 0,
                  max: 15,
                  onChanged: (value) {
                    setModalState(() =>
                        provider.updateTextCustomization(wordSpacing: value));
                  },
                ),
                _buildSliderSetting(
                  title: 'Line Spacing',
                  value: provider.scanEntity.lineHeight,
                  min: 1,
                  max: 3,
                  onChanged: (value) {
                    setModalState(() =>
                        provider.updateTextCustomization(lineHeight: value));
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Font Family',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFontOption(context, 'OpenDyslexicMono', setModalState,
                        provider.updateTextCustomization),
                    _buildFontOption(context, 'Lexend Exa', setModalState,
                        provider.updateTextCustomization),
                    _buildFontOption(context, 'Open Sans', setModalState,
                        provider.updateTextCustomization),
                    _buildFontOption(context, 'Atkinson Hyperlegible',
                        setModalState, provider.updateTextCustomization),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Bold Text',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: provider.scanEntity.isBold,
                      onChanged: (value) {
                        setModalState(() =>
                            provider.updateTextCustomization(isBold: value));
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Background Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption(context, Colors.white, setModalState,
                        provider.updateTextCustomization,
                        isBackground: true),
                    _buildColorOption(context, Colors.yellow.withOpacity(0.1),
                        setModalState, provider.updateTextCustomization,
                        isBackground: true),
                    _buildColorOption(context, Colors.blue.withOpacity(0.1),
                        setModalState, provider.updateTextCustomization,
                        isBackground: true),
                    _buildColorOption(context, Colors.pink.withOpacity(0.1),
                        setModalState, provider.updateTextCustomization,
                        isBackground: true),
                    _buildColorOption(context, Colors.grey.withOpacity(0.1),
                        setModalState, provider.updateTextCustomization,
                        isBackground: true),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Text Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption(context, Colors.black, setModalState,
                        provider.updateTextCustomization),
                    _buildColorOption(context, AppColors.primary, setModalState,
                        provider.updateTextCustomization),
                    _buildColorOption(context, Colors.blue.shade800,
                        setModalState, provider.updateTextCustomization),
                    _buildColorOption(context, Colors.brown.shade700,
                        setModalState, provider.updateTextCustomization),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setModalState(() => provider.resetTextCustomization());
                    },
                    child: const Text(
                      'Reset to Defaults',
                      style: TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildSliderSetting({
  required String title,
  required double value,
  required double min,
  required double max,
  required Function(double) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 14, color: AppColors.grey),
          ),
        ],
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: ((max - min) * 10).toInt(),
        activeColor: AppColors.primary,
        inactiveColor: AppColors.primary.withOpacity(0.2),
        onChanged: onChanged,
      ),
    ],
  );
}

Widget _buildFontOption(
    BuildContext context,
    String font,
    StateSetter setModalState,
    Function({String? fontFamily}) updateTextCustomization) {
  final provider = Provider.of<ScanProvider>(context, listen: false);
  final isSelected = provider.scanEntity.fontFamily == font;

  TextStyle optionStyle;
  switch (font) {
    case 'Lexend Exa':
      optionStyle = GoogleFonts.lexendExa(
        textStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 14,
        ),
      );
      break;
    case 'Open Sans':
      optionStyle = GoogleFonts.openSans(
        textStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 14,
        ),
      );
      break;
    case 'Atkinson Hyperlegible':
      optionStyle = GoogleFonts.atkinsonHyperlegible(
        textStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 14,
        ),
      );
      break;
    case 'OpenDyslexicMono':
    default:
      optionStyle = TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontFamily: 'OpenDyslexicMono',
        fontSize: 14,
      );
      break;
  }

  return GestureDetector(
    onTap: () {
      setModalState(() => updateTextCustomization(fontFamily: font));
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
        ),
      ),
      child: Text(
        font,
        style: optionStyle,
      ),
    ),
  );
}

Widget _buildColorOption(
    BuildContext context,
    Color color,
    StateSetter setModalState,
    Function({Color? textColor, Color? backgroundColor})
        updateTextCustomization,
    {bool isBackground = false}) {
  final provider = Provider.of<ScanProvider>(context, listen: false);
  final isSelected = isBackground
      ? provider.scanEntity.backgroundColor == color
      : provider.scanEntity.textColor == color;
  return GestureDetector(
    onTap: () {
      setModalState(() {
        if (isBackground) {
          updateTextCustomization(backgroundColor: color);
        } else {
          updateTextCustomization(textColor: color);
        }
      });
    },
    child: Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: AppColors.primary, size: 20)
          : null,
    ),
  );
}
