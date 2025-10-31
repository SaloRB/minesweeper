import 'package:flutter/material.dart';
import 'package:minesweeper/game_board_builder.dart';
import 'package:minesweeper/minesweeper_engine.dart';
import 'package:minesweeper/ui/widgets/status_overlay.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({super.key, required this.builder, required this.engine});

  final GameBoardBuilder builder;
  final MinesweeperEngine engine;

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
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
                ..._verticalLines(),
                ..._horizontalLines(),
                ..._borderWidgets(),
                ..._revealedSquares(),
                ..._flaggedSquares(),
                if (widget.engine.status == GameStatus.lost) ..._drawMines(),
                if (_hoverOverlay != null) _hoverOverlay!,
                StatusOverlay(
                  status: widget.engine.status,
                  onPlayAgain: widget.engine.reset,
                ),
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
              color: Colors.black.withValues(alpha: 0.04),
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

  Iterable<Widget> _revealedSquares() sync* {
    for (final coords in widget.engine.revealedLocations) {
      // Do not render mines in the revealed layer; they are handled by _drawMines()
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

  Iterable<Widget> _drawMines() sync* {
    for (final coords in widget.engine.mineLocations) {
      yield widget.builder
          .getCoordsContentsPosition(coords)
          .toWidget(const Center(child: Text('💣')));
    }
  }

  Iterable<Widget> _flaggedSquares() sync* {
    for (final coords in widget.engine.flaggedLocations) {
      if (widget.engine.revealedLocations.contains(coords)) continue;
      yield widget.builder
          .getCoordsContentsPosition(coords)
          .toWidget(const Center(child: Text('🚩')));
    }
  }

  Iterable<Widget> _verticalLines() sync* {
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

  Iterable<Widget> _horizontalLines() sync* {
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

  List<Widget> _borderWidgets() {
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
