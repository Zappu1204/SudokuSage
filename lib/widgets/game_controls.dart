import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  final bool isPaused;
  final bool isCompleted;
  final bool canUndo;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onHint;
  final VoidCallback onErase;
  final ValueChanged<bool> onNoteMode;
  final VoidCallback onSave;
  final VoidCallback onUndo;

  const GameControls({
    super.key,
    required this.isPaused,
    required this.isCompleted,
    required this.canUndo,
    required this.onPause,
    required this.onResume,
    required this.onHint,
    required this.onErase,
    required this.onNoteMode,
    required this.onSave,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Pause/Resume button
            if (!isCompleted)
              _buildControlButton(
                context,
                isPaused ? Icons.play_arrow : Icons.pause,
                isPaused ? 'Resume' : 'Pause',
                isPaused ? onResume : onPause,
                isPaused ? Colors.green : Colors.orange,
              ),
            
            // Save button
            _buildControlButton(
              context,
              Icons.save,
              'Save',
              onSave,
              Colors.blue,
            ),
            
            // Note mode button
            if (!isCompleted)
              _buildToggleButton(
                context,
                Icons.edit_note,
                'Notes',
                (value) => onNoteMode(value),
              ),
            
            // Erase button
            if (!isCompleted)
              _buildControlButton(
                context,
                Icons.backspace,
                'Erase',
                onErase,
                Colors.red,
              ),
            
            // Hint button
            if (!isCompleted)
              _buildControlButton(
                context,
                Icons.lightbulb,
                'Hint',
                onHint,
                Colors.amber,
              ),
            
            // Undo button (disabled for now)
            if (!isCompleted && canUndo)
              _buildControlButton(
                context,
                Icons.undo,
                'Undo',
                onUndo,
                Colors.teal,
              ),
          ],
        ),
      ),
    );
  }

  // Build a normal control button
  Widget _buildControlButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            color: color,
            tooltip: label,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Build a toggle button for note mode
  Widget _buildToggleButton(
    BuildContext context,
    IconData icon,
    String label,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              bool isSelected = false;
              
              return IconButton(
                onPressed: () {
                  setState(() {
                    isSelected = !isSelected;
                  });
                  onChanged(isSelected);
                },
                icon: Icon(icon),
                isSelected: isSelected,
                selectedIcon: Icon(icon, color: Colors.white),
                color: Theme.of(context).colorScheme.secondary,
                tooltip: label,
              );
            },
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}