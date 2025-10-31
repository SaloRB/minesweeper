import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:minesweeper/game_board_builder.dart';
import 'package:minesweeper/minesweeper_engine.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(30.0),
          child: Center(
            child: GameBoard(
              rows: 5,
              columns: 5,
            ),
          ),
        ),
      ),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({required this.rows, required this.columns, super.key});

  final int rows;
  final int columns;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late final MinesweeperEngine engine;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _timerStarted = false;
  late final VoidCallback _engineListener;

  @override
  void initState() {
    super.initState();
    engine = MinesweeperEngine(
      rows: widget.rows,
      columns: widget.columns,
      difficulty: Difficulty.hard,
    );

    _engineListener = () {
      if (engine.status == GameStatus.inProgress) {
        // Reset timer when a new game starts (no reveals yet)
        if (engine.revealedLocations.isEmpty) {
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
    engine.addListener(_engineListener);
  }

  @override
  void dispose() {
    engine.removeListener(_engineListener);
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    if (_timerStarted) return;
    _timerStarted = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (engine.status != GameStatus.inProgress) {
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

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
              // Header above the grid: flags (left) and timer (right)
              ListenableBuilder(
                listenable: engine,
                builder: (context, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Text(
                          '🚩 ${engine.remainingFlags} / ${engine.totalMines}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Text(
                          '⏱ ${_formatTime(_elapsedSeconds)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox.fromSize(
                size: builder.constraints,
                child: _GameBoardInner(builder: builder, engine: engine),
              ),
            ],
          ),
        );
        // Close MouseRegion
      },
    );
  }
}

class _GameBoardInner extends StatefulWidget {
  const _GameBoardInner({required this.builder, required this.engine});

  final GameBoardBuilder builder;
  final MinesweeperEngine engine;

  @override
  State<_GameBoardInner> createState() => _GameBoardInnerState();
}

class _GameBoardInnerState extends State<_GameBoardInner> {
  Coords? _hovered;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.engine,
      builder: (context, _) {
        final cursor = _isHoverClickable
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic;

        return MouseRegion(
          cursor: cursor,
          onHover: (event) {
            final coords = widget.builder.getRowColumnForCoordinates(
              event.localPosition,
            );
            if (!_sameCoords(_hovered, coords)) {
              setState(() => _hovered = coords);
            }
          },
          onExit: (_) => setState(() => _hovered = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final coords = widget.builder.getRowColumnForCoordinates(
                details.localPosition,
              );
              widget.engine.clickedCoordinates(coords);
            },
            onLongPressStart: (details) {
              final coords = widget.builder.getRowColumnForCoordinates(
                details.localPosition,
              );
              widget.engine.toggleFlag(coords);
            },
            onSecondaryTapUp: (details) {
              final coords = widget.builder.getRowColumnForCoordinates(
                details.localPosition,
              );
              widget.engine.toggleFlag(coords);
            },
            child: Stack(
              children: [
                ...verticalLines(),
                ...horizontalLines(),
                ...borderWidgets(),
                ...revealedSquares(),
                ...flaggedSquares(),
                if (widget.engine.status == GameStatus.lost) ...drawMines(),
                if (_hoverOverlay != null) _hoverOverlay!,
                // Static win/loss overlay with banner (no animations)
                _buildStatusOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _isHoverClickable {
    final h = _hovered;
    if (h == null) return false;
    if (widget.engine.status != GameStatus.inProgress) return false;
    if (!widget.engine.isInBounds(h)) return false;
    if (widget.engine.revealedLocations.contains(h)) return false;
    if (widget.engine.flaggedLocations.contains(h)) return false;
    return true;
  }

  bool _sameCoords(Coords? a, Coords b) =>
      a?.row == b.row && a?.column == b.column;

  Widget? get _hoverOverlay {
    if (!_showHoverOverlay) return null;
    final coords = _hovered!;
    return widget.builder
        .getFillSquarePosition(coords)
        .toWidget(
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              border: Border.all(color: Colors.black26, width: 1),
            ),
          ),
        );
  }

  // Show hover overlay for any unrevealed square (flagged or not) while the game is in progress.
  bool get _showHoverOverlay {
    final h = _hovered;
    if (h == null) return false;
    if (widget.engine.status != GameStatus.inProgress) return false;
    if (!widget.engine.isInBounds(h)) return false;
    if (widget.engine.revealedLocations.contains(h)) return false;
    return true;
  }

  Widget _buildStatusOverlay() {
    final status = widget.engine.status;
    if (status == GameStatus.inProgress) {
      return const SizedBox.shrink(key: ValueKey('none'));
    }

    final bool isWin = status == GameStatus.won;
    final Color borderColor = isWin ? Colors.green[600]! : Colors.red[600]!;
    final Color textColor = isWin ? Colors.green[700]! : Colors.red[700]!;
    final String title = isWin ? 'You Win!' : 'Game Over';
    final Color overlay = isWin
        ? Colors.black.withOpacity(0.10)
        : Colors.black.withOpacity(0.15);

    return Stack(
      key: ValueKey(isWin ? 'won' : 'lost'),
      children: [
        Positioned.fill(
          child: ColoredBox(color: overlay),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => widget.engine.reset(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Iterable<Widget> revealedSquares() sync* {
    for (final coords in widget.engine.revealedLocations) {
      // Do not render mines in the revealed layer; they are handled by drawMines()
      if (widget.engine.mineLocations.contains(coords)) continue;
      final mineCount = widget.engine.adjacentMineCounts[coords];
      Color color = Colors.black;

      switch (mineCount) {
        case 0:
          color = Colors.yellow[300]!;
        case 1:
          color = Colors.blue[300]!;
        case 2:
          color = Colors.green[300]!;
        case 3:
          color = Colors.red[300]!;
        case 4:
          color = Colors.purple[300]!;
        case 5:
          color = Colors.brown[300]!;
        case 6:
          color = Colors.blue[600]!;
      }
      if (mineCount == 0) {
        yield widget.builder
            .getFillSquarePosition(coords)
            .toWidget(
              ColoredBox(color: color),
            );
      } else {
        yield widget.builder
            .getCoordsContentsPosition(coords)
            .toWidget(
              Center(
                child: Text(
                  mineCount == 0 ? '' : '$mineCount',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
      }
    }
  }

  Iterable<Widget> drawMines() sync* {
    for (final coords in widget.engine.mineLocations) {
      yield widget.builder
          .getCoordsContentsPosition(coords)
          .toWidget(Center(child: Text('💣')));
    }
  }

  Iterable<Widget> flaggedSquares() sync* {
    for (final coords in widget.engine.flaggedLocations) {
      if (widget.engine.revealedLocations.contains(coords)) continue;
      yield widget.builder
          .getCoordsContentsPosition(coords)
          .toWidget(Center(child: Text('🚩')));
    }
  }

  Iterable<Widget> verticalLines() sync* {
    for (var i = 0; i < widget.builder.columns; i++) {
      yield widget.builder
          .verticalLinePosition(i)
          .toWidget(
            Container(
              color: Colors.grey[400],
            ),
          );
    }
  }

  Iterable<Widget> horizontalLines() sync* {
    for (var i = 0; i < widget.builder.rows; i++) {
      yield widget.builder
          .horizontalLinePosition(i)
          .toWidget(
            Container(
              color: Colors.grey,
            ),
          );
    }
  }

  List<Widget> borderWidgets() {
    return [
      // Left border
      widget.builder.leftBorderPosition().toWidget(
        Container(
          color: Colors.grey[700],
        ),
      ),

      // Top border
      widget.builder.topBorderPosition().toWidget(
        Container(
          color: Colors.grey[700],
        ),
      ),

      // Bottom border
      widget.builder.bottomBorderPosition().toWidget(
        Container(
          color: Colors.grey[700],
        ),
      ),

      // Right border
      widget.builder.rightBorderPosition().toWidget(
        Container(
          color: Colors.grey[700],
        ),
      ),
    ];
  }
}
