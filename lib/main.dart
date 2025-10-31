import 'package:flutter/material.dart';
import 'web_context_menu/web_context_menu_stub.dart'
    if (dart.library.html) 'web_context_menu/web_context_menu_html.dart'
    as webcm;
import 'ui/screens/game_screen.dart';
import 'ui/theme/minesweeper_theme.dart';

void main() {
  // Disable the browser's default context menu on web so right-click can flag.
  webcm.disableContextMenu();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MinesweeperThemeMode>(
      valueListenable: MinesweeperTheme.modeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == MinesweeperThemeMode.dark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            scaffoldBackgroundColor: const Color(0xFFF7F4F8),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(30.0),
              child: Center(
                child: GameScreen(rows: 9, columns: 9),
              ),
            ),
          ),
        );
      },
    );
  }
}
