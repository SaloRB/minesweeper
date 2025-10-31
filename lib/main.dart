import 'dart:math';

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
              rows: 15,
              columns: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({required this.rows, required this.columns, super.key});

  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSquareWidth = constraints.maxWidth / columns;
        final maxSquareHeight = constraints.maxHeight / rows;
        final squareSize = min(maxSquareWidth, maxSquareHeight);

        final builder = GameBoardBuilder(
          squareSize: squareSize,
          constraints: Size(
            squareSize * columns,
            squareSize * rows,
          ),
          rows: rows,
          columns: columns,
        );

        return Center(
          child: SizedBox.fromSize(
            size: builder.constraints,
            child: _GameBoardInner(builder),
          ),
        );
      },
    );
  }
}

class _GameBoardInner extends StatefulWidget {
  const _GameBoardInner(this.builder);

  final GameBoardBuilder builder;

  @override
  State<_GameBoardInner> createState() => _GameBoardInnerState();
}

class _GameBoardInnerState extends State<_GameBoardInner> {
  late final MinesweeperEngine engine;

  @override
  void initState() {
    super.initState();

    engine = MinesweeperEngine(
      rows: widget.builder.rows,
      columns: widget.builder.columns,
      difficulty: Difficulty.medium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final coords = widget.builder.getRowColumnForCoordinates(
              details.localPosition,
            );

            engine.clickedCoordinates(coords);
          },

          child: Stack(
            children: [
              ...verticalLines(),
              ...horizontalLines(),
              ...borderWidgets(),
              ...revealedSquares(),
              ...drawMines(),
            ],
          ),
        );
      },
    );
  }

  Iterable<Widget> revealedSquares() sync* {
    for (final coords in engine.revealedLocations) {
      final mineCount = engine.adjacentMineCounts[coords];
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
    for (final coords in engine.mineLocations) {
      yield widget.builder
          .getCoordsContentsPosition(coords)
          .toWidget(Center(child: Text('💣')));
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
