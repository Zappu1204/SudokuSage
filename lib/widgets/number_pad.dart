import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final int size;
  final bool enabled;
  final Function(int) onNumberSelected;
  final bool isNoteMode;

  const NumberPad({
    super.key,
    required this.size,
    required this.enabled,
    required this.onNumberSelected,
    required this.isNoteMode,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size <= 6 ? 3 : 5,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: size + 1, // Numbers 1 to size + erase (0)
      itemBuilder: (context, index) {
        // The last item is the erase button (0)
        final number = index < size ? index + 1 : 0;
        final isEraseButton = number == 0;
        
        return GestureDetector(
          onTap: enabled ? () => onNumberSelected(number) : null,
          child: Container(
            decoration: BoxDecoration(
              color: _getButtonColor(context, number, isEraseButton),
              borderRadius: BorderRadius.circular(8),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isEraseButton
                  ? const Icon(Icons.backspace, size: 24)
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(context, number, isEraseButton),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // Determine the button color based on state and number
  Color _getButtonColor(BuildContext context, int number, bool isEraseButton) {
    if (!enabled) {
      return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    }
    
    if (isEraseButton) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    
    if (isNoteMode) {
      return Theme.of(context).colorScheme.secondaryContainer;
    }
    
    return Theme.of(context).colorScheme.primaryContainer;
  }

  // Determine text color
  Color _getTextColor(BuildContext context, int number, bool isEraseButton) {
    if (!enabled) {
      return Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);
    }
    
    if (isEraseButton) {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
    
    if (isNoteMode) {
      return Theme.of(context).colorScheme.onSecondaryContainer;
    }
    
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }
}