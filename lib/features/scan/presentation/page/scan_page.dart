import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

class ScanPage extends StatefulWidget {
  final ValueNotifier<bool> hideNavBarNotifier;

  const ScanPage({super.key, required this.hideNavBarNotifier});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? selectedMedia;
  String? extractedText;
  bool isProcessing = false;

  // Text customization settings for dyslexia
  double characterSpacing = 0.5;
  double wordSpacing = 5.0;
  double lineHeight = 1.5;
  double fontSize = 18.0;
  String fontFamily = 'OpenDyslexic';
  bool isBold = false;
  Color textColor = Colors.black;
  Color backgroundColor = Colors.yellow.withOpacity(0.1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update navigation bar visibility based on selectedMedia
    widget.hideNavBarNotifier.value = selectedMedia != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              if (selectedMedia == null) _buildInitialUI(),
              if (selectedMedia != null) _buildResultsUI(),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedMedia == null
          ? FloatingActionButton(
              onPressed: _pickImage,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null,
      bottomNavigationBar: selectedMedia != null ? _buildInfoBar() : null,
    );
  }

  Widget _buildInfoBar() {
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
            onPressed: _showDyslexiaInfoDialog,
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

  void _showDyslexiaInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reading Tips for Dyslexia'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Customizing Your Reading Experience:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                    '• Try the OpenDyslexic font which is specially designed for readers with dyslexia'),
                Text('• Increase letter spacing to reduce crowding effects'),
                Text('• Add more space between words to make them distinct'),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCustomizationSettings();
              },
              child: const Text('Customize Text Now'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInitialUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 72, color: AppColors.primary),
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
              'Tap to scan text from images or documents',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text(
              'Start Scanning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scan Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.primary),
                    onPressed: _showCustomizationSettings,
                    tooltip: 'Customize Text',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => setState(() {
                      selectedMedia = null;
                      extractedText = null;
                      widget.hideNavBarNotifier.value = false;
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImagePreview(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Extracted Text',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildQuickCustomizeButtons(),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextResultView(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.copy,
                label: 'Copy',
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.text_fields,
                label: 'Customize',
                onPressed: _showCustomizationSettings,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (selectedMedia != null) {
      return Container(
        width: double.infinity,
        height: 250,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                selectedMedia!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 30,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                onPressed: _showFullScreenImage,
                tooltip: 'View Fullscreen',
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.grey.withOpacity(0.2),
      child: const Center(child: Text('No image selected.')),
    );
  }

  void _showFullScreenImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    selectedMedia!,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextResultView() {
    if (isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (extractedText != null && extractedText!.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        ),
        child: Text(
          extractedText!,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontFamily: fontFamily,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            letterSpacing: characterSpacing,
            wordSpacing: wordSpacing,
            height: lineHeight,
          ),
        ),
      );
    }
    if (selectedMedia != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        ),
        child: const Text(
          'No text detected in the image. Try another image.',
          style: TextStyle(fontSize: 16, color: AppColors.grey),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuickCustomizeButtons() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.text_decrease, size: 20),
          onPressed: () => setState(() {
            if (fontSize > 12) fontSize -= 2;
          }),
          tooltip: 'Decrease Font Size',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.text_increase, size: 20),
          onPressed: () => setState(() {
            fontSize += 2;
          }),
          tooltip: 'Increase Font Size',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.format_bold, size: 20),
          onPressed: () => setState(() {
            isBold = !isBold;
          }),
          color: isBold ? AppColors.primary : AppColors.grey,
          tooltip: 'Toggle Bold',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _showCustomizationSettings() {
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
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'This is how your text will look with these settings.',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                        fontFamily: fontFamily,
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                        letterSpacing: characterSpacing,
                        wordSpacing: wordSpacing,
                        height: lineHeight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSliderSetting(
                    title: 'Font Size',
                    value: fontSize,
                    min: 12,
                    max: 32,
                    onChanged: (value) {
                      setModalState(() => fontSize = value);
                      setState(() => fontSize = value);
                    },
                  ),
                  _buildSliderSetting(
                    title: 'Character Spacing',
                    value: characterSpacing,
                    min: 0,
                    max: 3,
                    onChanged: (value) {
                      setModalState(() => characterSpacing = value);
                      setState(() => characterSpacing = value);
                    },
                  ),
                  _buildSliderSetting(
                    title: 'Word Spacing',
                    value: wordSpacing,
                    min: 0,
                    max: 15,
                    onChanged: (value) {
                      setModalState(() => wordSpacing = value);
                      setState(() => wordSpacing = value);
                    },
                  ),
                  _buildSliderSetting(
                    title: 'Line Spacing',
                    value: lineHeight,
                    min: 1,
                    max: 3,
                    onChanged: (value) {
                      setModalState(() => lineHeight = value);
                      setState(() => lineHeight = value);
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
                      _buildFontOption('OpenDyslexic', setModalState),
                      _buildFontOption('Arial', setModalState),
                      _buildFontOption('Comic Sans MS', setModalState),
                      _buildFontOption('Verdana', setModalState),
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
                        value: isBold,
                        onChanged: (value) {
                          setModalState(() => isBold = value);
                          setState(() => isBold = value);
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
                      _buildColorOption(Colors.white, setModalState,
                          isBackground: true),
                      _buildColorOption(
                          Colors.yellow.withOpacity(0.1), setModalState,
                          isBackground: true),
                      _buildColorOption(
                          Colors.blue.withOpacity(0.1), setModalState,
                          isBackground: true),
                      _buildColorOption(
                          Colors.pink.withOpacity(0.1), setModalState,
                          isBackground: true),
                      _buildColorOption(
                          Colors.grey.withOpacity(0.1), setModalState,
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
                      _buildColorOption(Colors.black, setModalState),
                      _buildColorOption(AppColors.primary, setModalState),
                      _buildColorOption(Colors.blue.shade800, setModalState),
                      _buildColorOption(Colors.brown.shade700, setModalState),
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
                        setModalState(() {
                          fontSize = 18.0;
                          characterSpacing = 0.5;
                          wordSpacing = 5.0;
                          lineHeight = 1.5;
                          fontFamily = 'OpenDyslexic';
                          isBold = false;
                          textColor = Colors.black;
                          backgroundColor = Colors.yellow.withOpacity(0.1);
                        });
                        setState(() {
                          fontSize = 18.0;
                          characterSpacing = 0.5;
                          wordSpacing = 5.0;
                          lineHeight = 1.5;
                          fontFamily = 'OpenDyslexic';
                          isBold = false;
                          textColor = Colors.black;
                          backgroundColor = Colors.yellow.withOpacity(0.1);
                        });
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

  Widget _buildFontOption(String font, StateSetter setModalState) {
    final isSelected = fontFamily == font;
    return GestureDetector(
      onTap: () {
        setModalState(() => fontFamily = font);
        setState(() => fontFamily = font);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          font,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontFamily: font,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, StateSetter setModalState,
      {bool isBackground = false}) {
    final isSelected =
        isBackground ? backgroundColor == color : textColor == color;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (isBackground) {
            backgroundColor = color;
          } else {
            textColor = color;
          }
        });
        setState(() {
          if (isBackground) {
            backgroundColor = color;
          } else {
            textColor = color;
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
            color:
                isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: AppColors.primary, size: 20)
            : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  await _processPickedImage(pickedFile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  await _processPickedImage(pickedFile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPickedImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      setState(() {
        selectedMedia = File(pickedFile.path);
        isProcessing = true;
        extractedText = null;
        widget.hideNavBarNotifier.value = true;
      });
      final result = await _extractTextFromImage(selectedMedia!);
      setState(() {
        extractedText = result;
        isProcessing = false;
      });
    }
  }

  Future<String> _extractTextFromImage(File image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return 'Error: $e';
    } finally {
      textRecognizer.close();
    }
  }
}
