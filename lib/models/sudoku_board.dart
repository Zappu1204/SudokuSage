class SudokuBoard {
  final int size;
  final List<List<int>> initialBoard;
  final List<List<int>> currentBoard;
  final List<List<int>> solution;

  // Keeps track of which cells are fixed (initial values)
  final List<List<bool>> fixedCells;

  SudokuBoard({
    required this.size,
    required this.initialBoard,
    required this.currentBoard,
    required this.solution,
    required this.fixedCells,
  });

  // Create a new board from a puzzle
  factory SudokuBoard.fromPuzzle({
    required int size,
    required List<List<int>> puzzle,
    required List<List<int>> solution,
  }) {
    // Deep copy the puzzle for the initial and current board
    List<List<int>> initialBoard = List.generate(
      size,
      (i) => List.generate(size, (j) => puzzle[i][j]),
    );

    List<List<int>> currentBoard = List.generate(
      size,
      (i) => List.generate(size, (j) => puzzle[i][j]),
    );

    // Create fixed cells map
    List<List<bool>> fixedCells = List.generate(
      size,
      (i) => List.generate(
        size,
        (j) => puzzle[i][j] != 0,
      ),
    );

    return SudokuBoard(
      size: size,
      initialBoard: initialBoard,
      currentBoard: currentBoard,
      solution: solution,
      fixedCells: fixedCells,
    );
  }

  // Create an empty board
  factory SudokuBoard.empty(int size) {
    List<List<int>> emptyBoard = List.generate(
      size,
      (i) => List.generate(size, (j) => 0),
    );

    List<List<bool>> fixedCells = List.generate(
      size,
      (i) => List.generate(size, (j) => false),
    );

    return SudokuBoard(
      size: size,
      initialBoard: emptyBoard,
      currentBoard: emptyBoard,
      solution: emptyBoard,
      fixedCells: fixedCells,
    );
  }

  // Clone the board
  SudokuBoard clone() {
    return SudokuBoard(
      size: size,
      initialBoard: List.generate(
        size,
        (i) => List.generate(size, (j) => initialBoard[i][j]),
      ),
      currentBoard: List.generate(
        size,
        (i) => List.generate(size, (j) => currentBoard[i][j]),
      ),
      solution: List.generate(
        size,
        (i) => List.generate(size, (j) => solution[i][j]),
      ),
      fixedCells: List.generate(
        size,
        (i) => List.generate(size, (j) => fixedCells[i][j]),
      ),
    );
  }

  // Update a cell
  void updateCell(int row, int col, int value) {
    if (!fixedCells[row][col]) {
      currentBoard[row][col] = value;
    }
  }

  // Clear a cell
  void clearCell(int row, int col) {
    if (!fixedCells[row][col]) {
      currentBoard[row][col] = 0;
    }
  }

  // Get a cell value
  int getCell(int row, int col) {
    return currentBoard[row][col];
  }

  // Check if a cell is fixed
  bool isFixed(int row, int col) {
    return fixedCells[row][col];
  }
  
  // Alias for isFixed to maintain compatibility
  bool isCellFixed(int row, int col) {
    return isFixed(row, col);
  }

  // Check if the board is complete
  bool isComplete() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (currentBoard[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }
  
  // Alias for isComplete to maintain compatibility
  bool isBoardComplete() {
    return isComplete();
  }

  // Check if the board is solved correctly
  bool isSolved() {
    if (!isComplete()) {
      return false;
    }

    // Check if the current board matches the solution
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (currentBoard[i][j] != solution[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  // Get the number of correct cells
  int getCorrectCellsCount() {
    int count = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (currentBoard[i][j] != 0 && currentBoard[i][j] == solution[i][j]) {
          count++;
        }
      }
    }
    return count;
  }

  // Reset the board to initial state
  void reset() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        currentBoard[i][j] = initialBoard[i][j];
      }
    }
  }

  // Convert board to a serializable map
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'initialBoard': initialBoard.map((row) => row.toList()).toList(),
      'currentBoard': currentBoard.map((row) => row.toList()).toList(),
      'solution': solution.map((row) => row.toList()).toList(),
      'fixedCells': fixedCells.map((row) => row.toList()).toList(),
    };
  }

  // Create a board from a serialized map
  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    final size = json['size'] as int;
    final initialBoard = (json['initialBoard'] as List).map((row) {
      return (row as List).map((cell) => cell as int).toList();
    }).toList();
    final currentBoard = (json['currentBoard'] as List).map((row) {
      return (row as List).map((cell) => cell as int).toList();
    }).toList();
    final solution = (json['solution'] as List).map((row) {
      return (row as List).map((cell) => cell as int).toList();
    }).toList();
    final fixedCells = (json['fixedCells'] as List).map((row) {
      return (row as List).map((cell) => cell as bool).toList();
    }).toList();

    return SudokuBoard(
      size: size,
      initialBoard: initialBoard,
      currentBoard: currentBoard,
      solution: solution,
      fixedCells: fixedCells,
    );
  }

  // Get the box size based on the grid size
  static int getBoxSize(int size) {
    if (size == 4) return 2;
    if (size == 6) return 2;
    if (size == 9) return 3;
    return 3; // Default
  }
  
  // Check if a cell's value is valid according to Sudoku rules
  bool isCellValid(int row, int col, int value) {
    if (value == 0) return true; // Empty cells are considered valid
    
    // Check row
    for (int j = 0; j < size; j++) {
      if (j != col && currentBoard[row][j] == value) {
        return false;
      }
    }
    
    // Check column
    for (int i = 0; i < size; i++) {
      if (i != row && currentBoard[i][col] == value) {
        return false;
      }
    }
    
    // Check box
    int boxSize = SudokuBoard.getBoxSize(size);
    int boxStartRow = (row ~/ boxSize) * boxSize;
    int boxStartCol = (col ~/ boxSize) * boxSize;
    
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        int r = boxStartRow + i;
        int c = boxStartCol + j;
        if (r != row && c != col && currentBoard[r][c] == value) {
          return false;
        }
      }
    }
    
    return true;
  }
}