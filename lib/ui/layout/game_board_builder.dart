import 'dart:ui';

import 'package:minesweeper/models/coords.dart';
import 'position.dart';

class GameBoardBuilder {
  GameBoardBuilder({
    required this.constraints,
    required this.squareSize,
    required this.rows,
    required this.columns,
  });

  final Size constraints;
  final double squareSize;
  final int rows;
  final int columns;

  Position leftBorderPosition() => Position(
    left: -1,
    height: constraints.height,
    width: 2,
  );

  Position topBorderPosition() => Position(
    top: -1,
    width: constraints.width,
    height: 2,
  );

  Position rightBorderPosition() => Position(
    right: -1,
    height: constraints.height,
    width: 2,
  );

  Position bottomBorderPosition() => Position(
    bottom: -1,
    height: 2,
    width: constraints.width,
  );

  /// Draws the right boundary for the given column index.
  Position verticalLinePosition(int columnIndex) => Position(
    width: 1,
    height: constraints.height,
    left: (columnIndex + 1) * squareSize,
  );

  /// Draws the horizontal line for the given row index.
  Position horizontalLinePosition(int rowIndex) => Position(
    height: 1,
    width: constraints.width,
    top: (rowIndex + 1) * squareSize,
  );

  Position getCoordsContentsPosition(Coords coords) => Position(
    width: squareSize * 0.8,
    height: squareSize * 0.8,
    left: squareSize * coords.column + squareSize * 0.1,
    top: squareSize * coords.row + squareSize * 0.1,
  );

  Coords getRowColumnForCoordinates(Offset position) {
    return Coords(
      column: (position.dx / squareSize).floor(),
      row: (position.dy / squareSize).floor(),
    );
  }

  Position getFillSquarePosition(Coords coords) => Position(
    width: squareSize - 2,
    height: squareSize - 2,
    left: coords.column * squareSize + 1,
    top: coords.row * squareSize + 1,
  );
}
