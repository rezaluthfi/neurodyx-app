import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  String _selectedFont = 'Lexend Exa'; // Default font
  bool _isInitialized = false;

  String get selectedFont => _selectedFont;

  FontProvider() {
    // Constructor to initialize the provider
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadFont();
      _isInitialized = true;
    }
  }

  Future<void> _loadFont() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFont = prefs.getString('selectedFont');
      if (savedFont != null) {
        _selectedFont = savedFont;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading font: $e');
    }
  }

  Future<void> setFont(String font) async {
    try {
      _selectedFont = font;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedFont', font);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving font: $e');
    }
  }
}
