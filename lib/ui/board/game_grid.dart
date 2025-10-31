import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minesweeper/ui/layout/game_board_builder.dart';
import 'package:minesweeper/engine/minesweeper_engine.dart';
import 'package:minesweeper/models/coords.dart';
import 'package:minesweeper/ui/widgets/status_overlay.dart';
import 'package:minesweeper/ui/theme/minesweeper_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({super.key, required this.builder, required this.engine});

  final GameBoardBuilder builder;
  final MinesweeperEngine engine;

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  Coords? _hovered;
  // Icon scale relative to a tile's side length
  static const double _bombScale = 0.75;
  static const double _flagScale = 0.70;

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
              color: MinesweeperTheme.hoverOverlayFill,
              borderRadius: BorderRadius.circular(2),
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

      final count = widget.engine.adjacentMineCounts[coords] ?? 0;

      if (count == 0) {
        yield widget.builder
            .getFillSquarePosition(coords)
            .toWidget(
              ColoredBox(color: MinesweeperTheme.zeroFillBackground),
            );
      } else {
        yield widget.builder
            .getCoordsContentsPosition(coords)
            .toWidget(
              Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.merriweather(
                    color: MinesweeperTheme.numberColor(count),
                    fontWeight: FontWeight.w700,
                    fontSize: widget.builder.squareSize * 0.6,
                    height: 1.0,
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
          .getFillSquarePosition(coords)
          .toWidget(
            Center(
              child: SvgPicture.asset(
                'assets/icons/bomb.svg',
                width: widget.builder.squareSize * _bombScale,
                height: widget.builder.squareSize * _bombScale,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                  BlendMode.srcIn,
                ),
                semanticsLabel: 'mine',
                placeholderBuilder: (context) => Text(
                  '💣',
                  style: TextStyle(
                    fontSize: widget.builder.squareSize * 0.7,
                  ),
                ),
              ),
            ),
          );
    }
  }

  Iterable<Widget> _flaggedSquares() sync* {
    for (final coords in widget.engine.flaggedLocations) {
      if (widget.engine.revealedLocations.contains(coords)) continue;
      yield widget.builder
          .getFillSquarePosition(coords)
          .toWidget(
            Center(
              child: SvgPicture.asset(
                'assets/icons/flag.svg',
                width: widget.builder.squareSize * _flagScale,
                height: widget.builder.squareSize * _flagScale,
                fit: BoxFit.contain,
                semanticsLabel: 'flag',
                placeholderBuilder: (context) => Text(
                  '🚩',
                  style: TextStyle(
                    fontSize: widget.builder.squareSize * 0.7,
                  ),
                ),
              ),
            ),
          );
    }
  }

  Iterable<Widget> _verticalLines() sync* {
    for (var i = 0; i < widget.builder.columns; i++) {
      yield widget.builder
          .verticalLinePosition(i)
          .toWidget(
            Container(
              color: MinesweeperTheme.verticalLineColor,
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
              color: MinesweeperTheme.horizontalLineColor,
            ),
          );
    }
  }

  List<Widget> _borderWidgets() {
    return [
      // Left border
      widget.builder.leftBorderPosition().toWidget(
        Container(
          color: MinesweeperTheme.borderColor,
        ),
      ),

      // Top border
      widget.builder.topBorderPosition().toWidget(
        Container(
          color: MinesweeperTheme.borderColor,
        ),
      ),

      // Bottom border
      widget.builder.bottomBorderPosition().toWidget(
        Container(
          color: MinesweeperTheme.borderColor,
        ),
      ),

      // Right border
      widget.builder.rightBorderPosition().toWidget(
        Container(
          color: MinesweeperTheme.borderColor,
        ),
      ),
    ];
  }
}
