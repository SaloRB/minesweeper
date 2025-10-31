import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/game_board_builder.dart';
import 'package:minesweeper/minesweeper_engine.dart';
import 'package:minesweeper/ui/board/game_grid.dart';
import 'package:minesweeper/ui/widgets/game_header.dart';
import 'package:minesweeper/ui/theme/minesweeper_theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.rows, required this.columns});

  final int rows;
  final int columns;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  MinesweeperEngine? engine;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _timerStarted = false;
  late final VoidCallback _engineListener;
  Difficulty _selectedDifficulty = Difficulty.easy;
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _engineListener = () {
      final e = engine;
      if (e == null) return;
      if (e.status == GameStatus.inProgress) {
        // Reset timer when a new game starts (no reveals yet)
        if (e.revealedLocations.isEmpty) {
          _stopTimer();
          if (_elapsedSeconds != 0 || _timerStarted) {
            setState(() {
              _elapsedSeconds = 0;
              _timerStarted = false;
            });
          }
        } else {
          // Start timer on first reveal
          _startTimerIfNeeded();
        }
      } else {
        // Stop when game is won or lost
        _stopTimer();
      }
    };
  }

  @override
  void dispose() {
    engine?.removeListener(_engineListener);
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    // Detach old engine if present
    engine?.removeListener(_engineListener);
    // Create a new engine with selected difficulty
    final newEngine = MinesweeperEngine(
      rows: widget.rows,
      columns: widget.columns,
      difficulty: _selectedDifficulty,
    );
    newEngine.addListener(_engineListener);
    setState(() {
      engine = newEngine;
      // Reset timer display
      _elapsedSeconds = 0;
      _timerStarted = false;
    });
  }

  void _startTimerIfNeeded() {
    if (_timerStarted) return;
    _timerStarted = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final e = engine;
      if (e == null || e.status != GameStatus.inProgress) {
        _stopTimer();
        return;
      }
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
      MinesweeperTheme.setMode(
        _isDarkTheme ? MinesweeperThemeMode.dark : MinesweeperThemeMode.light,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSquareWidth = constraints.maxWidth / widget.columns;
        final maxSquareHeight = constraints.maxHeight / widget.rows;
        final squareSize = min(maxSquareWidth, maxSquareHeight);

        final builder = GameBoardBuilder(
          squareSize: squareSize,
          constraints: Size(
            squareSize * widget.columns,
            squareSize * widget.rows,
          ),
          rows: widget.rows,
          columns: widget.columns,
        );

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameHeader(
                engine: engine,
                selectedDifficulty: _selectedDifficulty,
                onDifficultyChanged: (d) => setState(() {
                  _selectedDifficulty = d;
                }),
                onStart: _startGame,
                elapsedSeconds: _elapsedSeconds,
                isDarkTheme: _isDarkTheme,
                onToggleTheme: _toggleTheme,
              ),
              SizedBox.fromSize(
                size: builder.constraints,
                child: engine == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.play_circle_outline, size: 40),
                            SizedBox(height: 8),
                            Text('Select a difficulty and press Start'),
                          ],
                        ),
                      )
                    : GameGrid(builder: builder, engine: engine!),
              ),
            ],
          ),
        );
      },
    );
  }
}
