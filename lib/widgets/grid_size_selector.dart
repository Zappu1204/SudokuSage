import 'package:flutter/material.dart';

class GridSizeSelector extends StatelessWidget {
  final int selectedSize;
  final Function(int) onSizeChanged;
  
  const GridSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grid Size',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildSizeChip(context, 4, '4×4'),
            _buildSizeChip(context, 6, '6×6'),
            _buildSizeChip(context, 9, '9×9'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSizeChip(BuildContext context, int size, String label) {
    final isSelected = selectedSize == size;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSizeChanged(size);
        }
      },
      backgroundColor: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer 
          : Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimaryContainer 
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}