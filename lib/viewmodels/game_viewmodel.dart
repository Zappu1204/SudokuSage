import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';
import '../utils/sudoku_generator.dart';
import '../utils/sudoku_solver.dart';
import '../utils/storage.dart';

enum GameState { initial, playing, paused, completed }

class GameViewModel extends ChangeNotifier {
  SudokuBoard? _board;
  GameState _gameState = GameState.initial;
  String _gameId = '';
  String _difficulty = 'Medium';
  int _size = 9;
  int _elapsedSeconds = 0;
  bool _highlightIdenticalNumbers = true;
  bool _highlightErrors = true;
  bool _autoEraseNotes = true;
  Timer? _timer;
  int _hintsUsed = 0;
  int _selectedRow = -1;
  int _selectedCol = -1;
  Map<String, Set<int>> _notes = {};
  
  // Getters
  SudokuBoard? get board => _board;
  GameState get gameState => _gameState;
  String get gameId => _gameId;
  String get difficulty => _difficulty;
  int get size => _size;
  int get elapsedSeconds => _elapsedSeconds;
  bool get highlightIdenticalNumbers => _highlightIdenticalNumbers;
  bool get highlightErrors => _highlightErrors;
  bool get autoEraseNotes => _autoEraseNotes;
  int get hintsUsed => _hintsUsed;
  int get selectedRow => _selectedRow;
  int get selectedCol => _selectedCol;
  Map<String, Set<int>> get notes => _notes;

  // Generate a new game
  void newGame(int size, String difficulty) {
    _size = size;
    _difficulty = difficulty;
    _gameState = GameState.initial;
    _elapsedSeconds = 0;
    _hintsUsed = 0;
    _selectedRow = -1;
    _selectedCol = -1;
    _notes = {};
    
    // Generate a unique game ID
    _gameId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Generate a new Sudoku board
    _board = SudokuGenerator.generateSudoku(size, difficulty);
    
    notifyListeners();
  }
  
  // Load a saved game
  Future<bool> loadGame(String gameId) async {
    try {
      final gameData = await StorageManager.loadGame(gameId);
      
      if (gameData == null) {
        return false;
      }
      
      _gameId = gameId;
      _difficulty = gameData['difficulty'];
      _size = gameData['size'];
      _elapsedSeconds = gameData['elapsedSeconds'];
      _gameState = GameState.values[gameData['gameState']];
      _hintsUsed = gameData['hintsUsed'] ?? 0;
      
      // Recreate the board
      List<List<int>> initialBoard = List<List<int>>.from(
        (gameData['initialBoard'] as List).map((row) => List<int>.from(row))
      );
      List<List<int>> currentBoard = List<List<int>>.from(
        (gameData['currentBoard'] as List).map((row) => List<int>.from(row))
      );
      List<List<int>> solution = List<List<int>>.from(
        (gameData['solution'] as List).map((row) => List<int>.from(row))
      );
      
      // Create fixed cells map for loaded game
      List<List<bool>> fixedCells = List.generate(
        _size,
        (i) => List.generate(
          _size,
          (j) => initialBoard[i][j] != 0,
        ),
      );
      
      _board = SudokuBoard(
        initialBoard: initialBoard,
        currentBoard: currentBoard,
        solution: solution,
        size: _size,
        fixedCells: fixedCells,
      );
      
      // Load notes
      if (gameData.containsKey('notes')) {
        Map<String, dynamic> notesData = gameData['notes'];
        _notes = {};
        
        notesData.forEach((key, value) {
          _notes[key] = Set<int>.from(value);
        });
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error loading game: $e');
      return false;
    }
  }
  
  // Save the current game
  Future<bool> saveGame() async {
    if (_board == null) {
      return false;
    }
    
    try {
      Map<String, dynamic> gameData = {
        'difficulty': _difficulty,
        'size': _size,
        'elapsedSeconds': _elapsedSeconds,
        'gameState': _gameState.index,
        'hintsUsed': _hintsUsed,
        'initialBoard': _board!.initialBoard,
        'currentBoard': _board!.currentBoard,
        'solution': _board!.solution,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Convert notes to a format that can be easily serialized
      Map<String, List<int>> serializedNotes = {};
      _notes.forEach((key, value) {
        serializedNotes[key] = value.toList();
      });
      gameData['notes'] = serializedNotes;
      
      return await StorageManager.saveGame(_gameId, gameData);
    } catch (e) {
      print('Error saving game: $e');
      return false;
    }
  }
  
  // Delete a saved game
  Future<bool> deleteGame(String gameId) async {
    return await StorageManager.deleteGame(gameId);
  }
  
  // Get all saved games
  Future<Map<String, dynamic>> getAllSavedGames() async {
    return await StorageManager.getAllSavedGames();
  }
  
  // Start or resume the game
  void startGame() {
    if (_gameState == GameState.initial || _gameState == GameState.paused) {
      _gameState = GameState.playing;
      _startTimer();
      notifyListeners();
    }
  }
  
  // Pause the game
  void pauseGame() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      _stopTimer();
      notifyListeners();
    }
  }
  
  // Start the timer
  void _startTimer() {
    _stopTimer(); // Ensure any existing timer is stopped
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }
  
  // Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  // Select a cell
  void selectCell(int row, int col) {
    if (_board == null || _gameState != GameState.playing) {
      return;
    }
    
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }
  
  // Enter a number in the selected cell
  void enterNumber(int number) {
    if (_board == null || 
        _gameState != GameState.playing || 
        _selectedRow < 0 || 
        _selectedCol < 0 ||
        _board!.isCellFixed(_selectedRow, _selectedCol)) {
      return;
    }
    
    // Update the cell
    _board!.currentBoard[_selectedRow][_selectedCol] = number;
    
    // Clear notes for this cell
    String cellKey = '$_selectedRow,$_selectedCol';
    _notes.remove(cellKey);
    
    // If auto-erase notes is enabled, remove the number from notes in the same row, column, and box
    if (_autoEraseNotes && number > 0) {
      _removeNoteFromRelatedCells(_selectedRow, _selectedCol, number);
    }
    
    // Check if the board is complete
    if (_board!.isBoardComplete()) {
      _gameState = GameState.completed;
      _stopTimer();
      
      // Update statistics
      StorageManager.updateStatsAfterGame(
        _size, 
        _difficulty, 
        _elapsedSeconds, 
        true, 
        _hintsUsed
      );
    }
    
    notifyListeners();
  }
  
  // Add or remove a note in the selected cell
  void toggleNote(int number) {
    if (_board == null || 
        _gameState != GameState.playing || 
        _selectedRow < 0 || 
        _selectedCol < 0 ||
        _board!.isCellFixed(_selectedRow, _selectedCol) ||
        _board!.currentBoard[_selectedRow][_selectedCol] != 0) {
      return;
    }
    
    String cellKey = '$_selectedRow,$_selectedCol';
    
    if (!_notes.containsKey(cellKey)) {
      _notes[cellKey] = {};
    }
    
    // Toggle the note
    if (_notes[cellKey]!.contains(number)) {
      _notes[cellKey]!.remove(number);
      
      // Remove the entry if there are no notes left
      if (_notes[cellKey]!.isEmpty) {
        _notes.remove(cellKey);
      }
    } else {
      _notes[cellKey]!.add(number);
    }
    
    notifyListeners();
  }
  
  // Remove a specific note from all cells in the same row, column, and box
  void _removeNoteFromRelatedCells(int row, int col, int number) {
    // Handle row
    for (int c = 0; c < _size; c++) {
      _removeNoteFromCell(row, c, number);
    }
    
    // Handle column
    for (int r = 0; r < _size; r++) {
      _removeNoteFromCell(r, col, number);
    }
    
    // Handle box
    int boxSize = SudokuBoard.getBoxSize(_size);
    int boxStartRow = (row ~/ boxSize) * boxSize;
    int boxStartCol = (col ~/ boxSize) * boxSize;
    
    for (int r = boxStartRow; r < boxStartRow + boxSize; r++) {
      for (int c = boxStartCol; c < boxStartCol + boxSize; c++) {
        _removeNoteFromCell(r, c, number);
      }
    }
  }
  
  // Remove a specific note from a cell
  void _removeNoteFromCell(int row, int col, int number) {
    String cellKey = '$row,$col';
    
    if (_notes.containsKey(cellKey)) {
      _notes[cellKey]!.remove(number);
      
      if (_notes[cellKey]!.isEmpty) {
        _notes.remove(cellKey);
      }
    }
  }
  
  // Clear the selected cell
  void clearCell() {
    if (_board == null || 
        _gameState != GameState.playing || 
        _selectedRow < 0 || 
        _selectedCol < 0 ||
        _board!.isCellFixed(_selectedRow, _selectedCol)) {
      return;
    }
    
    _board!.currentBoard[_selectedRow][_selectedCol] = 0;
    notifyListeners();
  }
  
  // Get a hint for the selected cell
  String getHint() {
    if (_board == null || 
        _gameState != GameState.playing || 
        _selectedRow < 0 || 
        _selectedCol < 0 ||
        _board!.isCellFixed(_selectedRow, _selectedCol)) {
      return "Select an empty cell to get a hint.";
    }
    
    // Get the correct value for the cell
    int correctValue = _board!.solution[_selectedRow][_selectedCol];
    
    // If the cell already has the correct value, notify the user
    if (_board!.currentBoard[_selectedRow][_selectedCol] == correctValue) {
      return "This cell already has the correct value.";
    }
    
    // Generate an explanation for the hint
    String explanation = SudokuSolver.generateHintExplanation(
      _board!.currentBoard, 
      _selectedRow, 
      _selectedCol, 
      correctValue, 
      _size
    );
    
    // Increment the hint counter
    _hintsUsed++;
    
    notifyListeners();
    return explanation;
  }
  
  // Apply the hint to the selected cell
  void applyHint() {
    if (_board == null || 
        _gameState != GameState.playing || 
        _selectedRow < 0 || 
        _selectedCol < 0 ||
        _board!.isCellFixed(_selectedRow, _selectedCol)) {
      return;
    }
    
    // Get the correct value for the cell
    int correctValue = _board!.solution[_selectedRow][_selectedCol];
    
    // Apply the value
    _board!.currentBoard[_selectedRow][_selectedCol] = correctValue;
    
    // Clear notes for this cell
    String cellKey = '$_selectedRow,$_selectedCol';
    _notes.remove(cellKey);
    
    // If auto-erase notes is enabled, remove the number from notes in the same row, column, and box
    if (_autoEraseNotes && correctValue > 0) {
      _removeNoteFromRelatedCells(_selectedRow, _selectedCol, correctValue);
    }
    
    // Increment the hint counter
    _hintsUsed++;
    
    // Check if the board is complete
    if (_board!.isBoardComplete()) {
      _gameState = GameState.completed;
      _stopTimer();
      
      // Update statistics
      StorageManager.updateStatsAfterGame(
        _size, 
        _difficulty, 
        _elapsedSeconds, 
        true, 
        _hintsUsed
      );
    }
    
    notifyListeners();
  }
  
  // Set the game settings
  void setSettings({
    bool? highlightIdenticalNumbers,
    bool? highlightErrors,
    bool? autoEraseNotes,
  }) {
    if (highlightIdenticalNumbers != null) {
      _highlightIdenticalNumbers = highlightIdenticalNumbers;
    }
    
    if (highlightErrors != null) {
      _highlightErrors = highlightErrors;
    }
    
    if (autoEraseNotes != null) {
      _autoEraseNotes = autoEraseNotes;
    }
    
    notifyListeners();
  }
  
  // Check if a cell should be highlighted due to having the same number as the selected cell
  bool shouldHighlightIdentical(int row, int col) {
    if (!_highlightIdenticalNumbers || 
        _board == null || 
        _selectedRow < 0 || 
        _selectedCol < 0) {
      return false;
    }
    
    int selectedValue = _board!.currentBoard[_selectedRow][_selectedCol];
    return selectedValue != 0 && _board!.currentBoard[row][col] == selectedValue;
  }
  
  // Check if a cell should be highlighted as an error
  bool shouldHighlightError(int row, int col) {
    if (!_highlightErrors || _board == null) {
      return false;
    }
    
    int value = _board!.currentBoard[row][col];
    return value != 0 && !_board!.isCellValid(row, col, value);
  }
  
  // Dispose resources
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}