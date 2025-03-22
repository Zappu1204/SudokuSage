import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'viewmodels/game_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/stats_viewmodel.dart';
import 'views/home_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(),
        ),
        ChangeNotifierProvider<GameViewModel>(
          create: (_) => GameViewModel(),
        ),
        ChangeNotifierProvider<StatsViewModel>(
          create: (_) => StatsViewModel(),
        ),
      ],
      child: const SudokuMasterApp(),
    ),
  );
}

class SudokuMasterApp extends StatelessWidget {
  const SudokuMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    
    return MaterialApp(
      title: 'Sudoku Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: settingsViewModel.darkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: settingsViewModel.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}