import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/grid_size_selector.dart';
import '../widgets/difficulty_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme section
              _buildSectionHeader(context, 'Theme'),
              _buildSettingsCard(
                context,
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme throughout the app'),
                  value: settingsViewModel.darkMode,
                  onChanged: (value) {
                    settingsViewModel.setDarkMode(value);
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Game Preferences section
              _buildSectionHeader(context, 'Game Preferences'),
              _buildSettingsCard(
                context,
                child: Column(
                  children: [
                    // Sound
                    SwitchListTile(
                      title: const Text('Sound Effects'),
                      subtitle: const Text('Play sounds during the game'),
                      value: settingsViewModel.soundEnabled,
                      onChanged: (value) {
                        settingsViewModel.setSoundEnabled(value);
                      },
                    ),
                    
                    const Divider(),
                    
                    // Haptic feedback
                    SwitchListTile(
                      title: const Text('Haptic Feedback'),
                      subtitle: const Text('Vibrate when interacting with the game'),
                      value: settingsViewModel.hapticFeedback,
                      onChanged: (value) {
                        settingsViewModel.setHapticFeedback(value);
                      },
                    ),
                    
                    const Divider(),
                    
                    // Highlight identical numbers
                    SwitchListTile(
                      title: const Text('Highlight Identical Numbers'),
                      subtitle: const Text('Highlight cells with the same value as the selected cell'),
                      value: settingsViewModel.highlightIdenticalNumbers,
                      onChanged: (value) {
                        settingsViewModel.setHighlightIdenticalNumbers(value);
                      },
                    ),
                    
                    const Divider(),
                    
                    // Highlight errors
                    SwitchListTile(
                      title: const Text('Highlight Errors'),
                      subtitle: const Text('Highlight incorrect numbers'),
                      value: settingsViewModel.highlightErrors,
                      onChanged: (value) {
                        settingsViewModel.setHighlightErrors(value);
                      },
                    ),
                    
                    const Divider(),
                    
                    // Auto erase notes
                    SwitchListTile(
                      title: const Text('Auto-Erase Notes'),
                      subtitle: const Text('Automatically remove notes when a number is placed'),
                      value: settingsViewModel.autoEraseNotes,
                      onChanged: (value) {
                        settingsViewModel.setAutoEraseNotes(value);
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Default Game Settings section
              _buildSectionHeader(context, 'Default Game Settings'),
              _buildSettingsCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'These settings will be applied when starting a new game',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    
                    const Divider(),
                    
                    // Default grid size
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridSizeSelector(
                        selectedSize: settingsViewModel.defaultGridSize,
                        onSizeChanged: (size) {
                          settingsViewModel.setDefaultGridSize(size);
                        },
                      ),
                    ),
                    
                    const Divider(),
                    
                    // Default difficulty
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DifficultySelector(
                        selectedDifficulty: settingsViewModel.defaultDifficulty,
                        onDifficultyChanged: (difficulty) {
                          settingsViewModel.setDefaultDifficulty(difficulty);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // About section
              _buildSectionHeader(context, 'About'),
              _buildSettingsCard(
                context,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Version'),
                      subtitle: const Text('1.0.0'),
                      leading: const Icon(Icons.info_outline),
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      title: const Text('Privacy Policy'),
                      leading: const Icon(Icons.privacy_tip_outlined),
                      onTap: () {
                        // Open privacy policy
                      },
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      title: const Text('Terms of Service'),
                      leading: const Icon(Icons.description_outlined),
                      onTap: () {
                        // Open terms of service
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}