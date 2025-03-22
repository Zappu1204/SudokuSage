import '../models/sudoku_board.dart';

class SudokuSolver {
  // Solve a Sudoku board using backtracking
  bool solve(List<List<int>> board, int size) {
    // Find an empty cell
    List<int>? emptyCell = _findEmptyCell(board, size);
    
    // If no empty cell is found, the board is solved
    if (emptyCell == null) {
      return true;
    }
    
    int row = emptyCell[0];
    int col = emptyCell[1];
    
    // Try each number from 1 to size
    for (int num = 1; num <= size; num++) {
      // Check if the number is valid in this position
      if (_isValid(board, row, col, num, size)) {
        // Place the number
        board[row][col] = num;
        
        // Recursively solve the rest of the board
        if (solve(board, size)) {
          return true;
        }
        
        // If this number doesn't lead to a solution, reset it
        board[row][col] = 0;
      }
    }
    
    // No solution found with current configuration
    return false;
  }

  // Find an empty cell (value 0)
  List<int>? _findEmptyCell(List<List<int>> board, int size) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == 0) {
          return [i, j];
        }
      }
    }
    return null; // No empty cell found
  }

  // Check if a number is valid in a given position
  bool _isValid(List<List<int>> board, int row, int col, int num, int size) {
    // Check row
    for (int j = 0; j < size; j++) {
      if (board[row][j] == num) {
        return false;
      }
    }
    
    // Check column
    for (int i = 0; i < size; i++) {
      if (board[i][col] == num) {
        return false;
      }
    }
    
    // Check box
    int boxSize = SudokuBoard.getBoxSize(size);
    int boxStartRow = row - (row % boxSize);
    int boxStartCol = col - (col % boxSize);
    
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        if (board[boxStartRow + i][boxStartCol + j] == num) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  // Get a list of valid numbers for a given cell
  List<int> getValidNumbers(List<List<int>> board, int row, int col, int size) {
    if (board[row][col] != 0) {
      return []; // Cell is already filled
    }
    
    List<int> validNumbers = [];
    for (int num = 1; num <= size; num++) {
      if (_isValid(board, row, col, num, size)) {
        validNumbers.add(num);
      }
    }
    
    return validNumbers;
  }
  
  // Check how many possible solutions exist (up to 2)
  int countSolutions(List<List<int>> board, int size) {
    // Deep copy the board
    List<List<int>> boardCopy = List.generate(
      size,
      (i) => List.generate(size, (j) => board[i][j]),
    );
    
    // First solution
    bool hasSolution = solve(boardCopy, size);
    if (!hasSolution) {
      return 0;
    }
    
    // Deep copy the first solution
    List<List<int>> firstSolution = List.generate(
      size,
      (i) => List.generate(size, (j) => boardCopy[i][j]),
    );
    
    // Try to find a different solution
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == 0) {
          for (int num = 1; num <= size; num++) {
            // If this is a valid number different from the first solution
            if (_isValid(board, i, j, num, size) && num != firstSolution[i][j]) {
              // Create a new board with this number
              List<List<int>> newBoard = List.generate(
                size,
                (r) => List.generate(size, (c) => board[r][c]),
              );
              newBoard[i][j] = num;
              
              // Check if this board can be solved
              if (solve(newBoard, size)) {
                return 2; // Found at least 2 solutions
              }
            }
          }
        }
      }
    }
    
    return 1; // Only one solution
  }
  
  // Get a hint for a specific cell
  String getHint(SudokuBoard board, int row, int col) {
    if (board.isFixed(row, col) || board.getCell(row, col) != 0) {
      return "This cell is already filled.";
    }
    
    int correctValue = board.solution[row][col];
    List<int> validNumbers = getValidNumbers(
      board.currentBoard,
      row,
      col,
      board.size,
    );
    
    if (validNumbers.isEmpty) {
      return "There are no valid numbers for this cell based on the current board state. Check for mistakes in other cells.";
    }
    
    if (validNumbers.length == 1) {
      return "There is only one possible number for this cell: $correctValue.";
    }
    
    // Analyze row, column, and box constraints
    String hint = "Looking at ";
    List<String> constraints = [];
    
    // Row constraint
    bool rowHasNumber = false;
    for (int j = 0; j < board.size; j++) {
      if (board.currentBoard[row][j] == correctValue) {
        rowHasNumber = true;
        break;
      }
    }
    if (!rowHasNumber) {
      constraints.add("row ${row + 1}");
    }
    
    // Column constraint
    bool colHasNumber = false;
    for (int i = 0; i < board.size; i++) {
      if (board.currentBoard[i][col] == correctValue) {
        colHasNumber = true;
        break;
      }
    }
    if (!colHasNumber) {
      constraints.add("column ${col + 1}");
    }
    
    // Box constraint
    int boxSize = SudokuBoard.getBoxSize(board.size);
    int boxRow = row ~/ boxSize;
    int boxCol = col ~/ boxSize;
    bool boxHasNumber = false;
    
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        int r = boxRow * boxSize + i;
        int c = boxCol * boxSize + j;
        if (board.currentBoard[r][c] == correctValue) {
          boxHasNumber = true;
          break;
        }
      }
      if (boxHasNumber) break;
    }
    if (!boxHasNumber) {
      constraints.add("box ${boxRow * boxSize + boxCol + 1}");
    }
    
    if (constraints.isNotEmpty) {
      hint += constraints.join(", ") + ", ";
      if (constraints.length == 1) {
        hint += "you need to place $correctValue somewhere in this region.";
      } else {
        hint += "the number $correctValue is missing from these regions.";
      }
    } else {
      // If no specific constraints, give a general hint
      hint = "Consider which numbers are already present in this row, column, and box. The correct value is $correctValue.";
    }
    
    return hint;
  }
  
  // Generate hint explanation (static method for easy access)
  static String generateHintExplanation(
    List<List<int>> board,
    int row,
    int col,
    int correctValue,
    int size,
  ) {
    // Create a temporary board object
    List<List<bool>> fixedCells = List.generate(
      size,
      (i) => List.generate(size, (j) => board[i][j] != 0),
    );
    
    SudokuBoard tempBoard = SudokuBoard(
      size: size,
      initialBoard: board,
      currentBoard: board,
      solution: board,
      fixedCells: fixedCells,
    );
    
    return _generateHintExplanationImpl(tempBoard, row, col, correctValue);
  }
  
  // Implementation of hint explanation
  static String _generateHintExplanationImpl(
    SudokuBoard board,
    int row,
    int col,
    int correctValue,
  ) {
    if (board.isFixed(row, col) || board.getCell(row, col) != 0) {
      return "This cell is already filled.";
    }
    
    // Analyze row, column, and box constraints
    String hint = "Looking at ";
    List<String> constraints = [];
    
    // Row constraint
    bool rowHasNumber = false;
    for (int j = 0; j < board.size; j++) {
      if (board.currentBoard[row][j] == correctValue) {
        rowHasNumber = true;
        break;
      }
    }
    if (!rowHasNumber) {
      constraints.add("row ${row + 1}");
    }
    
    // Column constraint
    bool colHasNumber = false;
    for (int i = 0; i < board.size; i++) {
      if (board.currentBoard[i][col] == correctValue) {
        colHasNumber = true;
        break;
      }
    }
    if (!colHasNumber) {
      constraints.add("column ${col + 1}");
    }
    
    // Box constraint
    int boxSize = SudokuBoard.getBoxSize(board.size);
    int boxRow = row ~/ boxSize;
    int boxCol = col ~/ boxSize;
    bool boxHasNumber = false;
    
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        int r = boxRow * boxSize + i;
        int c = boxCol * boxSize + j;
        if (board.currentBoard[r][c] == correctValue) {
          boxHasNumber = true;
          break;
        }
      }
      if (boxHasNumber) break;
    }
    if (!boxHasNumber) {
      constraints.add("box ${boxRow * boxSize + boxCol + 1}");
    }
    
    if (constraints.isNotEmpty) {
      hint += constraints.join(", ") + ", ";
      if (constraints.length == 1) {
        hint += "you need to place $correctValue somewhere in this region.";
      } else {
        hint += "the number $correctValue is missing from these regions.";
      }
    } else {
      // If no specific constraints, give a general hint
      hint = "Consider which numbers are already present in this row, column, and box. The correct value is $correctValue.";
    }
    
    return hint;
  }
}

// For easy access
final sudokuSolver = SudokuSolver();