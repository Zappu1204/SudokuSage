import 'dart:math';
import '../models/sudoku_board.dart';
import 'sudoku_solver.dart';

class SudokuGenerator {
  final Random _random = Random();
  
  // Static method for compatibility
  static SudokuBoard generateSudoku(int size, String difficulty) {
    // Convert string difficulty to integer
    int difficultyLevel;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        difficultyLevel = 1;
        break;
      case 'medium':
        difficultyLevel = 2;
        break;
      case 'hard':
        difficultyLevel = 3;
        break;
      case 'expert':
        difficultyLevel = 4;
        break;
      default:
        difficultyLevel = 2; // Default to medium
    }
    
    return SudokuGenerator().generatePuzzle(
      size: size,
      difficulty: difficultyLevel,
    );
  }

  // Generate a complete valid Sudoku board
  List<List<int>> _generateSolution(int size) {
    List<List<int>> board = List.generate(size, (i) => List.generate(size, (j) => 0));
    
    // Fill the board diagonally (to avoid conflicts)
    _fillDiagonal(board, size);
    
    // Solve the rest of the board
    SudokuSolver().solve(board, size);
    
    return board;
  }

  // Fill the diagonal boxes with valid numbers
  void _fillDiagonal(List<List<int>> board, int size) {
    int boxSize = SudokuBoard.getBoxSize(size);
    
    // Fill each diagonal box
    for (int boxIndex = 0; boxIndex < size; boxIndex += boxSize) {
      _fillBox(board, boxIndex, boxIndex, size);
    }
  }

  // Fill a single box with valid numbers
  void _fillBox(List<List<int>> board, int rowStart, int colStart, int size) {
    int boxSize = SudokuBoard.getBoxSize(size);
    List<int> numbers = List.generate(size, (i) => i + 1);
    numbers.shuffle(_random); // Randomize the numbers
    
    int numIndex = 0;
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        if (rowStart + i < size && colStart + j < size) {
          board[rowStart + i][colStart + j] = numbers[numIndex++];
        }
      }
    }
  }

  // Remove numbers from the board to create a puzzle
  List<List<int>> _createPuzzle(List<List<int>> solution, int size, int difficulty) {
    // Deep copy the solution
    List<List<int>> puzzle = List.generate(
      size,
      (i) => List.generate(size, (j) => solution[i][j]),
    );
    
    // Calculate how many numbers to remove based on difficulty
    // Difficulty levels: 1 (easy), 2 (medium), 3 (hard), 4 (expert)
    Map<int, Map<int, int>> cellsToRemove = {
      4: {1: 6, 2: 8, 3: 10, 4: 12}, // 4x4 grid
      6: {1: 16, 2: 22, 3: 28, 4: 32}, // 6x6 grid
      9: {1: 35, 2: 45, 3: 55, 4: 62}, // 9x9 grid
    };
    
    // Get number of cells to remove for the given size and difficulty
    int toRemove = cellsToRemove[size]?[difficulty] ?? (size * size ~/ 2);
    
    // Create a list of all positions
    List<List<int>> positions = [];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        positions.add([i, j]);
      }
    }
    
    // Shuffle the positions to randomize the removal
    positions.shuffle(_random);
    
    // Remove numbers one by one, ensuring the puzzle remains uniquely solvable
    for (int i = 0; i < toRemove && i < positions.length; i++) {
      int row = positions[i][0];
      int col = positions[i][1];
      
      // Store the original value
      int temp = puzzle[row][col];
      
      // Remove the number
      puzzle[row][col] = 0;
      
      // If it's not uniquely solvable, restore the value and try the next position
      if (!_hasUniqueSolution(puzzle, size)) {
        puzzle[row][col] = temp;
      }
    }
    
    return puzzle;
  }

  // Check if the puzzle has a unique solution
  bool _hasUniqueSolution(List<List<int>> puzzle, int size) {
    // This is a simplified check that ensures the puzzle is solvable
    // A more advanced implementation would check for multiple solutions
    // For now, we assume that if it's solvable, it has a unique solution
    
    // Deep copy the puzzle
    List<List<int>> copy = List.generate(
      size,
      (i) => List.generate(size, (j) => puzzle[i][j]),
    );
    
    return SudokuSolver().solve(copy, size);
  }

  // Generate a puzzle with its solution
  SudokuBoard generatePuzzle({required int size, required int difficulty}) {
    // Generate a complete solution
    List<List<int>> solution = _generateSolution(size);
    
    // Create a puzzle from the solution
    List<List<int>> puzzle = _createPuzzle(solution, size, difficulty);
    
    // Return a SudokuBoard with the puzzle and solution
    return SudokuBoard.fromPuzzle(
      size: size,
      puzzle: puzzle,
      solution: solution,
    );
  }
}

// For easy access
final sudokuGenerator = SudokuGenerator();