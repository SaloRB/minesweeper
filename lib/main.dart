import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/game_board_builder.dart';

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
              rows: 50,
              columns: 50,
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
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [...borderWidgets()],
    );
  }

  List<Widget> borderWidgets() {
    return [
      // Left border
      widget.builder.leftBorderPosition().toWidget(
        Container(
          color: Colors.grey,
        ),
      ),

      // Top border
      widget.builder.topBorderPosition().toWidget(
        Container(
          color: Colors.grey,
        ),
      ),

      // Bottom border
      widget.builder.bottomBorderPosition().toWidget(
        Container(
          color: Colors.grey,
        ),
      ),

      // Right border
      widget.builder.rightBorderPosition().toWidget(
        Container(
          color: Colors.grey,
        ),
      ),
    ];
  }
}
