import 'package:flutter/material.dart';
import '../utils/storage.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _darkMode = false;
  bool _soundEnabled = true;
  bool _hapticFeedback = true;
  int _defaultGridSize = 9;
  String _defaultDifficulty = 'Medium';
  bool _highlightIdenticalNumbers = true;
  bool _highlightErrors = true;
  bool _autoEraseNotes = true;
  
  // Getters
  bool get darkMode => _darkMode;
  bool get soundEnabled => _soundEnabled;
  bool get hapticFeedback => _hapticFeedback;
  int get defaultGridSize => _defaultGridSize;
  String get defaultDifficulty => _defaultDifficulty;
  bool get highlightIdenticalNumbers => _highlightIdenticalNumbers;
  bool get highlightErrors => _highlightErrors;
  bool get autoEraseNotes => _autoEraseNotes;
  
  // Initialize settings
  Future<void> initSettings() async {
    Map<String, dynamic> settings = await StorageManager.loadSettings();
    
    _darkMode = settings['darkMode'] ?? false;
    _soundEnabled = settings['soundEnabled'] ?? true;
    _hapticFeedback = settings['hapticFeedback'] ?? true;
    _defaultGridSize = settings['defaultGridSize'] ?? 9;
    _defaultDifficulty = settings['defaultDifficulty'] ?? 'Medium';
    _highlightIdenticalNumbers = settings['highlightIdenticalNumbers'] ?? true;
    _highlightErrors = settings['highlightErrors'] ?? true;
    _autoEraseNotes = settings['autoEraseNotes'] ?? true;
    
    notifyListeners();
  }
  
  // Save settings to storage
  Future<bool> saveSettings() async {
    Map<String, dynamic> settings = {
      'darkMode': _darkMode,
      'soundEnabled': _soundEnabled,
      'hapticFeedback': _hapticFeedback,
      'defaultGridSize': _defaultGridSize,
      'defaultDifficulty': _defaultDifficulty,
      'highlightIdenticalNumbers': _highlightIdenticalNumbers,
      'highlightErrors': _highlightErrors,
      'autoEraseNotes': _autoEraseNotes,
    };
    
    bool success = await StorageManager.saveSettings(settings);
    return success;
  }
  
  // Update dark mode setting
  void setDarkMode(bool value) {
    _darkMode = value;
    saveSettings();
    notifyListeners();
  }
  
  // Update sound enabled setting
  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    saveSettings();
    notifyListeners();
  }
  
  // Update haptic feedback setting
  void setHapticFeedback(bool value) {
    _hapticFeedback = value;
    saveSettings();
    notifyListeners();
  }
  
  // Update default grid size
  void setDefaultGridSize(int value) {
    if (value == 4 || value == 6 || value == 9) {
      _defaultGridSize = value;
      saveSettings();
      notifyListeners();
    }
  }
  
  // Update default difficulty
  void setDefaultDifficulty(String value) {
    if (['Easy', 'Medium', 'Hard', 'Expert'].contains(value)) {
      _defaultDifficulty = value;
      saveSettings();
      notifyListeners();
    }
  }
  
  // Update highlight identical numbers setting
  void setHighlightIdenticalNumbers(bool value) {
    _highlightIdenticalNumbers = value;
    saveSettings();
    notifyListeners();
  }
  
  // Update highlight errors setting
  void setHighlightErrors(bool value) {
    _highlightErrors = value;
    saveSettings();
    notifyListeners();
  }
  
  // Update auto erase notes setting
  void setAutoEraseNotes(bool value) {
    _autoEraseNotes = value;
    saveSettings();
    notifyListeners();
  }
}