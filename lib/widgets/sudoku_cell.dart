import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';

class SudokuCell extends StatelessWidget {
  final int row;
  final int col;
  final int size;
  
  const SudokuCell({
    super.key,
    required this.row,
    required this.col,
    required this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    final gameViewModel = Provider.of<GameViewModel>(context);
    final board = gameViewModel.board;
    final theme = Theme.of(context);
    
    if (board == null) {
      return Container();
    }
    
    final value = board.currentBoard[row][col];
    final isFixed = board.isCellFixed(row, col);
    final isSelected = gameViewModel.selectedRow == row && gameViewModel.selectedCol == col;
    final isSameRow = gameViewModel.selectedRow == row && gameViewModel.selectedCol >= 0;
    final isSameCol = gameViewModel.selectedCol == col && gameViewModel.selectedRow >= 0;
    final isSameBox = _isInSameBox(row, col, gameViewModel.selectedRow, gameViewModel.selectedCol, size);
    final shouldHighlightIdentical = gameViewModel.shouldHighlightIdentical(row, col);
    final shouldHighlightError = gameViewModel.shouldHighlightError(row, col);
    
    // Cell notes
    final cellKey = '$row,$col';
    final hasNotes = gameViewModel.notes.containsKey(cellKey) && gameViewModel.notes[cellKey]!.isNotEmpty;
    
    // Color the cell based on its state
    Color cellColor = theme.colorScheme.surface;
    
    if (isSelected) {
      cellColor = theme.colorScheme.primary.withOpacity(0.3);
    } else if (isSameRow || isSameCol || isSameBox) {
      cellColor = theme.colorScheme.primary.withOpacity(0.1);
    }
    
    if (shouldHighlightIdentical) {
      cellColor = theme.colorScheme.secondary.withOpacity(0.3);
    }
    
    if (shouldHighlightError) {
      cellColor = theme.colorScheme.error.withOpacity(0.3);
    }
    
    // Determine cell borders (thicker for box separation)
    final borderTop = _shouldHaveThickBorderTop(row, size) ? 1.5 : 0.5;
    final borderBottom = _shouldHaveThickBorderBottom(row, size) ? 1.5 : 0.5;
    final borderLeft = _shouldHaveThickBorderLeft(col, size) ? 1.5 : 0.5;
    final borderRight = _shouldHaveThickBorderRight(col, size) ? 1.5 : 0.5;
    
    return GestureDetector(
      onTap: () {
        if (gameViewModel.gameState == GameState.playing) {
          gameViewModel.selectCell(row, col);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          border: Border(
            top: BorderSide(width: borderTop, color: theme.dividerColor),
            bottom: BorderSide(width: borderBottom, color: theme.dividerColor),
            left: BorderSide(width: borderLeft, color: theme.dividerColor),
            right: BorderSide(width: borderRight, color: theme.dividerColor),
          ),
        ),
        child: Center(
          child: value != 0
              ? Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: isFixed ? FontWeight.bold : FontWeight.normal,
                    color: shouldHighlightError
                        ? theme.colorScheme.error
                        : isFixed
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
                  ),
                )
              : hasNotes
                  ? _buildNotes(context, cellKey, gameViewModel)
                  : null,
        ),
      ),
    );
  }
  
  // Build the notes grid for a cell
  Widget _buildNotes(BuildContext context, String cellKey, GameViewModel gameViewModel) {
    final notes = gameViewModel.notes[cellKey] ?? {};
    final boxSize = _getBoxSize(size);
    final gridSize = boxSize;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: size,
      itemBuilder: (context, index) {
        final number = index + 1;
        final hasNote = notes.contains(number);
        
        return hasNote
            ? Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: size <= 6 ? 9 : 8,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              )
            : Container();
      },
    );
  }
  
  // Check if a cell is in the same box as the selected cell
  bool _isInSameBox(int row1, int col1, int row2, int col2, int size) {
    if (row2 < 0 || col2 < 0) {
      return false;
    }
    
    final boxSize = _getBoxSize(size);
    final box1Row = row1 ~/ boxSize;
    final box1Col = col1 ~/ boxSize;
    final box2Row = row2 ~/ boxSize;
    final box2Col = col2 ~/ boxSize;
    
    return box1Row == box2Row && box1Col == box2Col;
  }
  
  // Get the box size based on the grid size
  int _getBoxSize(int size) {
    if (size == 4) return 2;
    if (size == 6) return 2;
    if (size == 9) return 3;
    return 3; // Default
  }
  
  // Determine if the cell should have a thick top border
  bool _shouldHaveThickBorderTop(int row, int size) {
    final boxSize = _getBoxSize(size);
    return row % boxSize == 0;
  }
  
  // Determine if the cell should have a thick bottom border
  bool _shouldHaveThickBorderBottom(int row, int size) {
    final boxSize = _getBoxSize(size);
    return (row + 1) % boxSize == 0 || row == size - 1;
  }
  
  // Determine if the cell should have a thick left border
  bool _shouldHaveThickBorderLeft(int col, int size) {
    final boxSize = _getBoxSize(size);
    return col % boxSize == 0;
  }
  
  // Determine if the cell should have a thick right border
  bool _shouldHaveThickBorderRight(int col, int size) {
    final boxSize = _getBoxSize(size);
    return (col + 1) % boxSize == 0 || col == size - 1;
  }
}