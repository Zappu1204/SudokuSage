import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stats_viewmodel.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSizeIndex = 2; // Default to 9x9
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Refresh stats
    Provider.of<StatsViewModel>(context, listen: false).loadStats();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final statsViewModel = Provider.of<StatsViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              statsViewModel.loadStats();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Overview card with general stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          context,
                          'Games Played',
                          '${statsViewModel.gamesPlayed}',
                          Icons.games,
                        ),
                        _buildStatColumn(
                          context,
                          'Games Won',
                          '${statsViewModel.gamesWon}',
                          Icons.emoji_events,
                        ),
                        _buildStatColumn(
                          context,
                          'Win Rate',
                          '${statsViewModel.winRate.toStringAsFixed(1)}%',
                          Icons.stacked_bar_chart,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          context,
                          'Hints Used',
                          '${statsViewModel.hintsUsed}',
                          Icons.lightbulb_outline,
                        ),
                        _buildStatColumn(
                          context,
                          'Daily Streak',
                          '${statsViewModel.streakDays}',
                          Icons.local_fire_department,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Best Times section with grid size selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Times',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                // Grid size selector
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('4×4'),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text('6×6'),
                    ),
                    ButtonSegment<int>(
                      value: 2,
                      label: Text('9×9'),
                    ),
                  ],
                  selected: {_selectedSizeIndex},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _selectedSizeIndex = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Best times table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBestTimesTable(context, statsViewModel),
                ),
              ),
            ),
          ),
          
          // Reset stats button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                _showResetConfirmationDialog(context);
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Reset All Statistics'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildBestTimesTable(BuildContext context, StatsViewModel statsViewModel) {
    final gridSizes = ['4', '6', '9'];
    final difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];
    
    final selectedSize = gridSizes[_selectedSizeIndex];
    
    return Table(
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        width: 1.0,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1),
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Difficulty',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Best Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        
        // Data rows
        ...difficulties.map((difficulty) {
          final bestTime = statsViewModel.bestTimes[selectedSize]?[difficulty];
          final formattedTime = statsViewModel.formatTime(bestTime);
          
          return TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    difficulty,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: bestTime != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text(
          'Are you sure you want to reset all statistics? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<StatsViewModel>(context, listen: false).resetStats();
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistics have been reset'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}