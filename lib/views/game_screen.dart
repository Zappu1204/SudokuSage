import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_timer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Start the game when the screen is opened
    Future.delayed(Duration.zero, () {
      final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
      if (gameViewModel.gameState == GameState.initial) {
        gameViewModel.startGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameViewModel = Provider.of<GameViewModel>(context);
    
    // Create a WillPopScope to handle back button press
    return WillPopScope(
      onWillPop: () async {
        // If the game is in playing state, pause it before going back
        if (gameViewModel.gameState == GameState.playing) {
          gameViewModel.pauseGame();
          // Show confirmation dialog
          return await _showExitConfirmation(context) ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${gameViewModel.difficulty} (${gameViewModel.size}×${gameViewModel.size})',
          ),
          centerTitle: true,
          actions: [
            // Timer widget in the app bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: GameTimer(
                  elapsedSeconds: gameViewModel.elapsedSeconds,
                  isRunning: gameViewModel.gameState == GameState.playing,
                ),
              ),
            ),
          ],
        ),
        body: gameViewModel.board == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Game state indicator
                  if (gameViewModel.gameState != GameState.playing)
                    Container(
                      width: double.infinity,
                      color: gameViewModel.gameState == GameState.completed
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        gameViewModel.gameState == GameState.completed
                            ? 'Completed! 🎉'
                            : 'Paused',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  // Main game content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sudoku board
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AspectRatio(
                            aspectRatio: 1.0, // Keep board square
                            child: SudokuBoard(
                              board: gameViewModel.board!,
                              selectedRow: gameViewModel.selectedRow,
                              selectedCol: gameViewModel.selectedCol,
                              onCellTap: (row, col) {
                                if (gameViewModel.gameState == GameState.playing) {
                                  gameViewModel.selectCell(row, col);
                                }
                              },
                              highlightIdenticalNumbers: gameViewModel.highlightIdenticalNumbers,
                              highlightErrors: gameViewModel.highlightErrors,
                              shouldHighlightIdentical: gameViewModel.shouldHighlightIdentical,
                              shouldHighlightError: gameViewModel.shouldHighlightError,
                              notes: gameViewModel.notes,
                            ),
                          ),
                        ),
                        
                        // Controls and number pad
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Game controls
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GameControls(
                                    isPaused: gameViewModel.gameState == GameState.paused,
                                    isCompleted: gameViewModel.gameState == GameState.completed,
                                    canUndo: false, // Add undo functionality later
                                    onPause: () => gameViewModel.pauseGame(),
                                    onResume: () => gameViewModel.startGame(),
                                    onHint: () => _showHintDialog(context, gameViewModel),
                                    onErase: () => gameViewModel.clearCell(),
                                    onNoteMode: (enabled) {
                                      // Toggle note mode (implement in GameViewModel)
                                      setState(() {
                                        _noteMode = enabled;
                                      });
                                    },
                                    onSave: () {
                                      gameViewModel.saveGame().then((success) {
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Game saved successfully!'),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Failed to save the game.'),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    onUndo: () {
                                      // Implement undo functionality later
                                    },
                                  ),
                                ),
                                
                                // Number pad
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: NumberPad(
                                      size: gameViewModel.size,
                                      enabled: gameViewModel.gameState == GameState.playing &&
                                        gameViewModel.selectedRow >= 0 &&
                                        gameViewModel.selectedCol >= 0 &&
                                        !gameViewModel.board!.isCellFixed(
                                          gameViewModel.selectedRow,
                                          gameViewModel.selectedCol,
                                        ),
                                      onNumberSelected: (number) {
                                        if (_noteMode) {
                                          gameViewModel.toggleNote(number);
                                        } else {
                                          gameViewModel.enterNumber(number);
                                        }
                                      },
                                      isNoteMode: _noteMode,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // State for note mode
  bool _noteMode = false;

  // Show exit confirmation dialog
  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text('Do you want to save your progress before exiting?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Exit without saving
            },
            child: const Text('DON\'T SAVE'),
          ),
          ElevatedButton(
            onPressed: () {
              final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
              gameViewModel.saveGame().then((success) {
                if (success) {
                  Navigator.of(context).pop(true); // Exit after saving
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save the game. Please try again.'),
                    ),
                  );
                  Navigator.of(context).pop(false); // Don't exit if save failed
                }
              });
            },
            child: const Text('SAVE & EXIT'),
          ),
        ],
      ),
    );
  }

  // Show hint dialog
  void _showHintDialog(BuildContext context, GameViewModel gameViewModel) {
    if (gameViewModel.selectedRow < 0 || gameViewModel.selectedCol < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cell first to get a hint.'),
        ),
      );
      return;
    }
    
    if (gameViewModel.board!.isCellFixed(gameViewModel.selectedRow, gameViewModel.selectedCol)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is an initial cell and cannot be changed.'),
        ),
      );
      return;
    }

    // Get hint explanation
    String hintText = gameViewModel.getHint();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hintText),
            const SizedBox(height: 16),
            const Text('Would you like to fill in the correct value?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('NO, THANKS'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              gameViewModel.applyHint();
            },
            child: const Text('YES, PLEASE'),
          ),
        ],
      ),
    );
  }
}