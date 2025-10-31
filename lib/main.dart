import 'package:flutter/material.dart';
import 'web_context_menu/web_context_menu_stub.dart'
    if (dart.library.html) 'web_context_menu/web_context_menu_html.dart'
    as webcm;
import 'ui/screens/game_screen.dart';

void main() {
  // Disable the browser's default context menu on web so right-click can flag.
  webcm.disableContextMenu();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(30.0),
          child: Center(
            child: const GameScreen(rows: 9, columns: 9),
          ),
        ),
      ),
    );
  }
}
