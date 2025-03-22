import 'package:flutter/material.dart';
import '../models/sudoku_board.dart' as model;

class SudokuBoard extends StatelessWidget {
  final model.SudokuBoard board;
  final int selectedRow;
  final int selectedCol;
  final Function(int, int) onCellTap;
  final bool highlightIdenticalNumbers;
  final bool highlightErrors;
  final bool Function(int, int) shouldHighlightIdentical;
  final bool Function(int, int) shouldHighlightError;
  final Map<String, Set<int>> notes;

  const SudokuBoard({
    super.key,
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
    required this.highlightIdenticalNumbers,
    required this.highlightErrors,
    required this.shouldHighlightIdentical,
    required this.shouldHighlightError,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: board.size,
        ),
        itemCount: board.size * board.size,
        itemBuilder: (context, index) {
          int row = index ~/ board.size;
          int col = index % board.size;
          int value = board.currentBoard[row][col];
          bool isFixed = board.isCellFixed(row, col);
          bool isSelected = row == selectedRow && col == selectedCol;
          bool isInSameRow = row == selectedRow;
          bool isInSameCol = col == selectedCol;
          
          // Check if in the same box as the selected cell
          bool isInSameBox = false;
          if (selectedRow >= 0 && selectedCol >= 0) {
            int boxSize = _getBoxSize(board.size);
            int selectedBoxRow = selectedRow ~/ boxSize;
            int selectedBoxCol = selectedCol ~/ boxSize;
            int currentBoxRow = row ~/ boxSize;
            int currentBoxCol = col ~/ boxSize;
            isInSameBox = selectedBoxRow == currentBoxRow && selectedBoxCol == currentBoxCol;
          }
          
          bool highlightIdentical = highlightIdenticalNumbers && shouldHighlightIdentical(row, col);
          bool highlightError = highlightErrors && shouldHighlightError(row, col);
          
          // Get the cell notes
          Set<int>? cellNotes;
          String cellKey = '$row,$col';
          if (value == 0 && notes.containsKey(cellKey)) {
            cellNotes = notes[cellKey];
          }
          
          // Determine border widths based on position
          BorderSide borderSide = BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: 0.5,
          );
          
          BorderSide thickBorderSide = BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2.0,
          );
          
          // Determine if the cell needs thick borders for box separation
          int boxSize = _getBoxSize(board.size);
          bool needsBottomThickBorder = (row + 1) % boxSize == 0 && row < board.size - 1;
          bool needsRightThickBorder = (col + 1) % boxSize == 0 && col < board.size - 1;
          
          return GestureDetector(
            onTap: () => onCellTap(row, col),
            child: Container(
              decoration: BoxDecoration(
                color: _getCellBackgroundColor(
                  context,
                  isSelected,
                  isInSameRow,
                  isInSameCol,
                  isInSameBox,
                  highlightIdentical,
                  highlightError,
                ),
                border: Border(
                  top: row == 0 ? thickBorderSide : borderSide,
                  left: col == 0 ? thickBorderSide : borderSide,
                  bottom: needsBottomThickBorder ? thickBorderSide : borderSide,
                  right: needsRightThickBorder ? thickBorderSide : borderSide,
                ),
              ),
              alignment: Alignment.center,
              child: value == 0
                  ? _buildNotesGrid(context, cellNotes, board.size)
                  : Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: _getFontSize(board.size),
                        fontWeight: isFixed ? FontWeight.bold : FontWeight.normal,
                        color: _getCellTextColor(
                          context,
                          isFixed,
                          highlightError,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  // Build a grid of note numbers
  Widget _buildNotesGrid(BuildContext context, Set<int>? notes, int size) {
    if (notes == null || notes.isEmpty) {
      return const SizedBox();
    }
    
    // Calculate grid dimensions based on board size
    int gridSize;
    if (size == 4) {
      gridSize = 2;
    } else if (size == 6) {
      gridSize = 3;
    } else {
      gridSize = 3;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        childAspectRatio: 1.0,
      ),
      itemCount: size,
      itemBuilder: (context, index) {
        int number = index + 1;
        return Container(
          alignment: Alignment.center,
          child: notes.contains(number)
              ? Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: _getNoteFontSize(size),
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }

  // Determine cell background color based on state
  Color _getCellBackgroundColor(
    BuildContext context,
    bool isSelected,
    bool isInSameRow,
    bool isInSameCol,
    bool isInSameBox,
    bool highlightIdentical,
    bool highlightError,
  ) {
    if (highlightError) {
      return Colors.red.withOpacity(0.3);
    }
    
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.3);
    }
    
    if (highlightIdentical) {
      return Theme.of(context).colorScheme.tertiary.withOpacity(0.3);
    }
    
    if (isInSameRow || isInSameCol || isInSameBox) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.1);
    }
    
    return Colors.transparent;
  }

  // Determine cell text color based on state
  Color _getCellTextColor(
    BuildContext context,
    bool isFixed,
    bool highlightError,
  ) {
    if (highlightError) {
      return Colors.red;
    }
    
    if (isFixed) {
      return Theme.of(context).colorScheme.primary;
    }
    
    return Theme.of(context).colorScheme.onSurface;
  }

  // Determine font size based on board size
  double _getFontSize(int size) {
    if (size == 4) {
      return 24.0;
    } else if (size == 6) {
      return 20.0;
    } else {
      return 18.0;
    }
  }

  // Determine note font size based on board size
  double _getNoteFontSize(int size) {
    if (size == 4) {
      return 12.0;
    } else if (size == 6) {
      return 10.0;
    } else {
      return 8.0;
    }
  }
  
  // Get the box size based on board size
  int _getBoxSize(int size) {
    if (size == 4) return 2;
    if (size == 6) return 2;
    if (size == 9) return 3;
    return 3; // Default
  }
}