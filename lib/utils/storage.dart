import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_board.dart';

class StorageManager {
  static const String SETTINGS_KEY = 'sudoku_settings';
  static const String SAVED_GAMES_KEY = 'saved_games';
  static const String STATS_KEY = 'sudoku_stats';

  // Save game settings
  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(SETTINGS_KEY, jsonEncode(settings));
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  // Load game settings
  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? settingsJson = prefs.getString(SETTINGS_KEY);
      
      if (settingsJson == null) {
        // Return default settings
        return {
          'darkMode': false,
          'soundEnabled': true,
          'hapticFeedback': true,
          'defaultGridSize': 9,
          'defaultDifficulty': 'Medium',
          'highlightIdenticalNumbers': true,
          'highlightErrors': true,
          'autoEraseNotes': true,
        };
      }
      
      return jsonDecode(settingsJson);
    } catch (e) {
      print('Error loading settings: $e');
      // Return default settings in case of error
      return {
        'darkMode': false,
        'soundEnabled': true,
        'hapticFeedback': true,
        'defaultGridSize': 9,
        'defaultDifficulty': 'Medium',
        'highlightIdenticalNumbers': true,
        'highlightErrors': true,
        'autoEraseNotes': true,
      };
    }
  }

  // Save a game
  static Future<bool> saveGame(String gameId, Map<String, dynamic> gameData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedGamesJson = prefs.getString(SAVED_GAMES_KEY);
      
      Map<String, dynamic> savedGames = {};
      if (savedGamesJson != null) {
        savedGames = jsonDecode(savedGamesJson);
      }
      
      // Add timestamp if not provided
      if (!gameData.containsKey('timestamp')) {
        gameData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      }
      
      savedGames[gameId] = gameData;
      return await prefs.setString(SAVED_GAMES_KEY, jsonEncode(savedGames));
    } catch (e) {
      print('Error saving game: $e');
      return false;
    }
  }

  // Load a specific game
  static Future<Map<String, dynamic>?> loadGame(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedGamesJson = prefs.getString(SAVED_GAMES_KEY);
      
      if (savedGamesJson == null) {
        return null;
      }
      
      Map<String, dynamic> savedGames = jsonDecode(savedGamesJson);
      return savedGames[gameId];
    } catch (e) {
      print('Error loading game: $e');
      return null;
    }
  }

  // Get all saved games
  static Future<Map<String, dynamic>> getAllSavedGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedGamesJson = prefs.getString(SAVED_GAMES_KEY);
      
      if (savedGamesJson == null) {
        return {};
      }
      
      return jsonDecode(savedGamesJson);
    } catch (e) {
      print('Error getting all saved games: $e');
      return {};
    }
  }

  // Delete a specific game
  static Future<bool> deleteGame(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedGamesJson = prefs.getString(SAVED_GAMES_KEY);
      
      if (savedGamesJson == null) {
        return true; // Nothing to delete
      }
      
      Map<String, dynamic> savedGames = jsonDecode(savedGamesJson);
      savedGames.remove(gameId);
      
      return await prefs.setString(SAVED_GAMES_KEY, jsonEncode(savedGames));
    } catch (e) {
      print('Error deleting game: $e');
      return false;
    }
  }

  // Delete all saved games
  static Future<bool> deleteAllSavedGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(SAVED_GAMES_KEY);
    } catch (e) {
      print('Error deleting all saved games: $e');
      return false;
    }
  }

  // Save game statistics
  static Future<bool> saveStats(Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(STATS_KEY, jsonEncode(stats));
    } catch (e) {
      print('Error saving stats: $e');
      return false;
    }
  }

  // Load game statistics
  static Future<Map<String, dynamic>> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString(STATS_KEY);
      
      if (statsJson == null) {
        // Return default stats
        return {
          'gamesPlayed': 0,
          'gamesWon': 0,
          'bestTimes': {
            '4': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
            '6': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
            '9': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
          },
          'hintsUsed': 0,
          'streakDays': 0,
          'lastPlayed': null,
        };
      }
      
      return jsonDecode(statsJson);
    } catch (e) {
      print('Error loading stats: $e');
      // Return default stats in case of error
      return {
        'gamesPlayed': 0,
        'gamesWon': 0,
        'bestTimes': {
          '4': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
          '6': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
          '9': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
        },
        'hintsUsed': 0,
        'streakDays': 0,
        'lastPlayed': null,
      };
    }
  }

  // Update game statistics after completing a game
  static Future<bool> updateStatsAfterGame(int size, String difficulty, int timeInSeconds, bool won, int hintsUsed) async {
    try {
      Map<String, dynamic> stats = await loadStats();
      
      // Update general statistics
      stats['gamesPlayed'] = (stats['gamesPlayed'] ?? 0) + 1;
      
      if (won) {
        stats['gamesWon'] = (stats['gamesWon'] ?? 0) + 1;
        
        // Update best time if this is better or there is no previous best time
        var bestTimes = stats['bestTimes'] ?? {
          '4': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
          '6': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
          '9': {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null},
        };
        
        if (bestTimes['$size'] == null) {
          bestTimes['$size'] = {'Easy': null, 'Medium': null, 'Hard': null, 'Expert': null};
        }
        
        var currentBest = bestTimes['$size'][difficulty];
        if (currentBest == null || timeInSeconds < currentBest) {
          bestTimes['$size'][difficulty] = timeInSeconds;
        }
        
        stats['bestTimes'] = bestTimes;
      }
      
      // Update hints used
      stats['hintsUsed'] = (stats['hintsUsed'] ?? 0) + hintsUsed;
      
      // Update streak
      int now = DateTime.now().millisecondsSinceEpoch;
      int? lastPlayed = stats['lastPlayed'];
      
      if (lastPlayed != null) {
        DateTime lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(lastPlayed);
        DateTime today = DateTime.now();
        DateTime lastPlayedDay = DateTime(lastPlayedDate.year, lastPlayedDate.month, lastPlayedDate.day);
        DateTime todayDay = DateTime(today.year, today.month, today.day);
        
        int differenceInDays = todayDay.difference(lastPlayedDay).inDays;
        
        if (differenceInDays == 1) {
          // Played on consecutive days
          stats['streakDays'] = (stats['streakDays'] ?? 0) + 1;
        } else if (differenceInDays > 1) {
          // Streak broken
          stats['streakDays'] = 1;
        }
      } else {
        // First time playing
        stats['streakDays'] = 1;
      }
      
      stats['lastPlayed'] = now;
      
      return await saveStats(stats);
    } catch (e) {
      print('Error updating stats after game: $e');
      return false;
    }
  }
}