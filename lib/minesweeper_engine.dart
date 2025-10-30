import 'package:flutter/widgets.dart';
import 'package:minesweeper/game_board_builder.dart';

enum Difficulty {
  easy,
  medium,
  hard,
}

class MinesweeperEngine extends ChangeNotifier {
  MinesweeperEngine({
    required this.rows,
    required this.columns,
    required this.difficulty,
  }) {
    _seedMines();
  }

  final int rows;
  final int columns;
  final Difficulty difficulty;

  final mineLocations = <Coords>{};

  void _seedMines() {
    final numSquares = rows * columns;
    final int numMines = switch (difficulty) {
      Difficulty.easy => (numSquares * 0.1).floor(),
      Difficulty.medium => (numSquares * 0.20).round(),
      Difficulty.hard => (numSquares * 0.30).round(),
    };

    final coordsToHoldMines = allCoords.toList()..shuffle();
    mineLocations.addAll(coordsToHoldMines.sublist(0, numMines));
  }

  Iterable<Coords> get allCoords sync* {
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        yield Coords(row: row, column: column);
      }
    }
  }
}
