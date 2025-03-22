import 'package:flutter/material.dart';
import '../utils/storage.dart';

class StatsViewModel extends ChangeNotifier {
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  Map<String, Map<String, int?>> _bestTimes = {
    '4': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
    '6': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
    '9': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
  };
  int _hintsUsed = 0;
  int _streakDays = 0;
  int? _lastPlayed;
  
  // Getters
  int get gamesPlayed => _gamesPlayed;
  int get gamesWon => _gamesWon;
  Map<String, Map<String, int?>> get bestTimes => _bestTimes;
  int get hintsUsed => _hintsUsed;
  int get streakDays => _streakDays;
  int? get lastPlayed => _lastPlayed;
  
  // Calculate win rate as a percentage
  double get winRate => _gamesPlayed > 0 ? (_gamesWon / _gamesPlayed) * 100 : 0.0;
  
  // Get best time for a specific grid size and difficulty
  int? getBestTime(int size, String difficulty) {
    return _bestTimes['$size']?[difficulty];
  }
  
  // Format time in minutes and seconds
  String formatTime(int? seconds) {
    if (seconds == null) {
      return "--:--";
    }
    
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
  
  // Load statistics from storage
  Future<void> loadStats() async {
    Map<String, dynamic> stats = await StorageManager.loadStats();
    
    _gamesPlayed = stats['gamesPlayed'] ?? 0;
    _gamesWon = stats['gamesWon'] ?? 0;
    _hintsUsed = stats['hintsUsed'] ?? 0;
    _streakDays = stats['streakDays'] ?? 0;
    _lastPlayed = stats['lastPlayed'];
    
    // Load best times
    if (stats.containsKey('bestTimes')) {
      Map<String, dynamic> bestTimesData = stats['bestTimes'];
      
      bestTimesData.forEach((sizeKey, difficulties) {
        if (difficulties is Map) {
          difficulties.forEach((difficultyKey, time) {
            if (_bestTimes.containsKey(sizeKey) && 
                _bestTimes[sizeKey]!.containsKey(difficultyKey)) {
              _bestTimes[sizeKey]![difficultyKey] = time;
            }
          });
        }
      });
    }
    
    notifyListeners();
  }
  
  // Reset all statistics
  Future<bool> resetStats() async {
    _gamesPlayed = 0;
    _gamesWon = 0;
    _bestTimes = {
      '4': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
      '6': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
      '9': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
    };
    _hintsUsed = 0;
    _streakDays = 0;
    _lastPlayed = null;
    
    Map<String, dynamic> stats = {
      'gamesPlayed': _gamesPlayed,
      'gamesWon': _gamesWon,
      'bestTimes': _bestTimes,
      'hintsUsed': _hintsUsed,
      'streakDays': _streakDays,
      'lastPlayed': _lastPlayed,
    };
    
    bool success = await StorageManager.saveStats(stats);
    
    if (success) {
      notifyListeners();
    }
    
    return success;
  }
}