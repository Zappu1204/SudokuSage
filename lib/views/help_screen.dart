import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'What is Sudoku?',
                [
                  'Sudoku is a logic-based number placement puzzle where the objective is to fill a grid with digits so that each column, each row, and each of the subgrids contains all of the digits from 1 to the grid size (4, 6, or 9) without repetition.',
                  'Sudoku Master offers multiple grid sizes: 4×4 (with 2×2 boxes), 6×6 (with 2×3 boxes), and 9×9 (with 3×3 boxes).',
                ],
              ),
              
              _buildSection(
                context,
                'How to Play',
                [
                  '1. Select an empty cell by tapping on it.',
                  '2. Enter a number by tapping on the number pad below.',
                  '3. To add notes (small numbers), toggle the "Notes" button and then tap numbers.',
                  '4. Continue filling cells until the entire grid is completed correctly.',
                ],
              ),
              
              _buildSection(
                context,
                'Game Controls',
                [
                  '• Erase: Removes a number from the selected cell.',
                  '• Notes: Toggle notes mode to add small numbers as candidates.',
                  '• Hint: Provides a hint for the selected cell.',
                  '• Pause: Pauses the game timer.',
                  '• Save: Saves your current game progress.',
                ],
              ),
              
              _buildSection(
                context,
                'Difficulty Levels',
                [
                  '• Easy: More filled cells at the start, suitable for beginners.',
                  '• Medium: Balanced difficulty with fewer starting numbers.',
                  '• Hard: Requires more advanced solving techniques.',
                  '• Expert: The most challenging puzzles with minimal starting clues.',
                ],
              ),
              
              _buildSection(
                context,
                'Solving Techniques',
                [
                  '• Scanning: Look for rows, columns, and boxes where only one cell can contain a specific number.',
                  '• Candidate Elimination: Use notes to mark possible numbers for each cell, then eliminate candidates as you solve.',
                  '• Cross-Hatching: Find where a number can be placed in a row/column within a box.',
                  '• Advanced Techniques: For harder puzzles, you may need techniques like X-Wing, Swordfish, or XY-Wing patterns.',
                ],
              ),
              
              _buildSection(
                context,
                'Features',
                [
                  '• Multiple grid sizes (4×4, 6×6, 9×9)',
                  '• Four difficulty levels',
                  '• Note-taking system',
                  '• Hint system with difficulty rating',
                  '• Auto-save and resume functionality',
                  '• Performance statistics tracking',
                  '• Import puzzles from camera',
                ],
              ),
              
              _buildSection(
                context,
                'Tips',
                [
                  '• Always start with the easiest cells that have the fewest possibilities.',
                  '• Use notes to keep track of possible numbers for each cell.',
                  '• Look for "naked singles" (cells with only one possible value).',
                  '• When stuck, try different strategies or use the hint feature.',
                  '• Practice regularly to improve your solving skills and recognition of patterns.',
                ],
              ),
              
              const SizedBox(height: 32),
              
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Got it!'),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, List<String> paragraphs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          ...paragraphs.map((paragraph) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                paragraph,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }),
        ],
      ),
    );
  }
}