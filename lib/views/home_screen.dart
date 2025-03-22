import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/stats_viewmodel.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings and stats on startup
    Future.delayed(Duration.zero, () {
      final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
      final statsViewModel = Provider.of<StatsViewModel>(context, listen: false);
      
      settingsViewModel.initSettings();
      statsViewModel.loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameViewModel = Provider.of<GameViewModel>(context);
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    final statsViewModel = Provider.of<StatsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Master'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                const Icon(
                  Icons.grid_3x3,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'SUDOKU MASTER',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Challenge your mind with Sudoku puzzles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                
                // New Game Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // Start a new game with default settings
                      gameViewModel.newGame(
                        settingsViewModel.defaultGridSize,
                        settingsViewModel.defaultDifficulty,
                      );
                      
                      // Navigate to the game screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text(
                      'NEW GAME',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Continue Game Button
                FutureBuilder<Map<String, dynamic>>(
                  future: gameViewModel.getAllSavedGames(),
                  builder: (context, snapshot) {
                    bool hasSavedGames = snapshot.hasData && snapshot.data!.isNotEmpty;
                    
                    return SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: hasSavedGames
                            ? () {
                                // Show a dialog to select a saved game
                                _showSavedGamesDialog(context, snapshot.data!);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        child: const Text(
                          'CONTINUE GAME',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Additional buttons in a grid layout
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // Settings button
                    _buildMenuButton(
                      context,
                      'SETTINGS',
                      Icons.settings,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    
                    // Stats button
                    _buildMenuButton(
                      context,
                      'STATISTICS',
                      Icons.bar_chart,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatsScreen(),
                          ),
                        );
                      },
                    ),
                    
                    // Help button
                    _buildMenuButton(
                      context,
                      'HELP',
                      Icons.help,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpScreen(),
                          ),
                        );
                      },
                    ),
                    
                    // Custom game button
                    _buildMenuButton(
                      context,
                      'CUSTOM GAME',
                      Icons.tune,
                      () {
                        _showCustomGameDialog(context);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Stats preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Stats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(context, 'Games', '${statsViewModel.gamesPlayed}'),
                          _buildStatItem(context, 'Win Rate', '${statsViewModel.winRate.toStringAsFixed(1)}%'),
                          _buildStatItem(context, 'Streak', '${statsViewModel.streakDays}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a menu button with icon and text
  Widget _buildMenuButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a stat item with label and value
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Show a dialog to select a saved game
  void _showSavedGamesDialog(BuildContext context, Map<String, dynamic> savedGames) {
    showDialog(
      context: context,
      builder: (context) {
        // Convert saved games to a list sorted by timestamp (newest first)
        List<MapEntry<String, dynamic>> gamesList = savedGames.entries.toList();
        gamesList.sort((a, b) {
          int timestampA = a.value['timestamp'] ?? 0;
          int timestampB = b.value['timestamp'] ?? 0;
          return timestampB.compareTo(timestampA);
        });
        
        return AlertDialog(
          title: const Text('Saved Games'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: gamesList.length,
              itemBuilder: (context, index) {
                final gameEntry = gamesList[index];
                final gameId = gameEntry.key;
                final gameData = gameEntry.value;
                
                // Format date
                String dateStr = 'Unknown date';
                if (gameData['timestamp'] != null) {
                  final date = DateTime.fromMillisecondsSinceEpoch(gameData['timestamp']);
                  dateStr = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                }
                
                // Format time played
                final seconds = gameData['elapsedSeconds'] ?? 0;
                final minutes = seconds ~/ 60;
                final remainingSeconds = seconds % 60;
                final timeStr = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
                
                return ListTile(
                  title: Text('${gameData['difficulty']} (${gameData['size']}x${gameData['size']})'),
                  subtitle: Text('$dateStr • Time: $timeStr'),
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    
                    // Load the selected game
                    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
                    gameViewModel.loadGame(gameId).then((success) {
                      if (success) {
                        // Navigate to the game screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameScreen(),
                          ),
                        );
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to load the game.'),
                          ),
                        );
                      }
                    });
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Delete the game
                      final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
                      gameViewModel.deleteGame(gameId).then((success) {
                        if (success) {
                          // Close dialog and show a snackbar
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Game deleted successfully.'),
                            ),
                          );
                          
                          // Refresh the dialog
                          gameViewModel.getAllSavedGames().then((updatedGames) {
                            if (updatedGames.isNotEmpty) {
                              _showSavedGamesDialog(context, updatedGames);
                            }
                          });
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  // Show a dialog to configure a custom game
  void _showCustomGameDialog(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
    int selectedGridSize = settingsViewModel.defaultGridSize;
    String selectedDifficulty = settingsViewModel.defaultDifficulty;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Custom Game'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grid Size:'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildGridSizeButton(context, 4, selectedGridSize, (size) {
                        setState(() => selectedGridSize = size);
                      }),
                      _buildGridSizeButton(context, 6, selectedGridSize, (size) {
                        setState(() => selectedGridSize = size);
                      }),
                      _buildGridSizeButton(context, 9, selectedGridSize, (size) {
                        setState(() => selectedGridSize = size);
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Difficulty:'),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      _buildDifficultyRadio(context, 'Easy', selectedDifficulty, (difficulty) {
                        setState(() => selectedDifficulty = difficulty);
                      }),
                      _buildDifficultyRadio(context, 'Medium', selectedDifficulty, (difficulty) {
                        setState(() => selectedDifficulty = difficulty);
                      }),
                      _buildDifficultyRadio(context, 'Hard', selectedDifficulty, (difficulty) {
                        setState(() => selectedDifficulty = difficulty);
                      }),
                      _buildDifficultyRadio(context, 'Expert', selectedDifficulty, (difficulty) {
                        setState(() => selectedDifficulty = difficulty);
                      }),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    
                    // Start a new game with the selected settings
                    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
                    gameViewModel.newGame(selectedGridSize, selectedDifficulty);
                    
                    // Navigate to the game screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  child: const Text('START'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build a grid size selection button
  Widget _buildGridSizeButton(BuildContext context, int size, int selectedSize, Function(int) onSelected) {
    final isSelected = size == selectedSize;
    
    return InkWell(
      onTap: () => onSelected(size),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$size×$size',
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Build a difficulty radio button
  Widget _buildDifficultyRadio(BuildContext context, String difficulty, String selectedDifficulty, Function(String) onSelected) {
    return RadioListTile<String>(
      title: Text(difficulty),
      value: difficulty,
      groupValue: selectedDifficulty,
      onChanged: (value) => onSelected(value!),
      dense: true,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}