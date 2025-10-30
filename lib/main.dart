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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final coords = widget.builder.getRowColumnForCoordinates(
          details.localPosition,
        );

        print(coords);
      },

      child: Stack(
        children: [
          ...verticalLines(),
          ...horizontalLines(),
          ...borderWidgets(),
          ...drawMines(),
        ],
      ),
    );
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
