import 'dart:async';
import 'package:flutter/material.dart';

class GameTimer extends StatefulWidget {
  final bool isPaused;
  final int elapsedSeconds;
  final bool isRunning;
  final Function(int)? onTimeUpdate;

  const GameTimer({
    super.key, 
    this.isPaused = false, 
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.onTimeUpdate,
  });

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  late Timer _timer;
  late int _seconds;
  late bool _isPaused;

  @override
  void initState() {
    super.initState();
    _seconds = widget.elapsedSeconds;
    _isPaused = !widget.isRunning || widget.isPaused;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(GameTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning || widget.isPaused != oldWidget.isPaused) {
      _isPaused = !widget.isRunning || widget.isPaused;
    }
    if (widget.elapsedSeconds != oldWidget.elapsedSeconds) {
      _seconds = widget.elapsedSeconds;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
          widget.onTimeUpdate?.call(_seconds);
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    String hoursStr = hours > 0 ? '${hours.toString()}:' : '';
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    
    return '$hoursStr$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer, size: 18),
        const SizedBox(width: 4),
        Text(
          _formatTime(_seconds),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _isPaused 
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}