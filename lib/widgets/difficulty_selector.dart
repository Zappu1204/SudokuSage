import 'package:flutter/material.dart';

class DifficultySelector extends StatelessWidget {
  final String selectedDifficulty;
  final Function(String) onDifficultyChanged;
  
  const DifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildDifficultyChip(context, 'Easy'),
            _buildDifficultyChip(context, 'Medium'),
            _buildDifficultyChip(context, 'Hard'),
            _buildDifficultyChip(context, 'Expert'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDifficultyChip(BuildContext context, String difficulty) {
    final isSelected = selectedDifficulty == difficulty;
    
    // Define colors based on difficulty
    Color backgroundColor;
    Color textColor;
    
    switch (difficulty) {
      case 'Easy':
        backgroundColor = isSelected 
            ? Colors.green.shade100 
            : Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'Medium':
        backgroundColor = isSelected 
            ? Colors.blue.shade100 
            : Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'Hard':
        backgroundColor = isSelected 
            ? Colors.orange.shade100 
            : Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'Expert':
        backgroundColor = isSelected 
            ? Colors.red.shade100 
            : Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        backgroundColor = isSelected 
            ? Theme.of(context).colorScheme.primaryContainer 
            : Theme.of(context).colorScheme.surface;
        textColor = Theme.of(context).colorScheme.onSurface;
    }
    
    return ChoiceChip(
      label: Text(difficulty),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onDifficultyChanged(difficulty);
        }
      },
      backgroundColor: backgroundColor,
      selectedColor: backgroundColor,
      labelStyle: TextStyle(
        color: textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}