import 'dart:ui';

import 'package:equatable/equatable.dart';

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

  /// Draws the right boundary for the given column index, This means that when
  /// [columnIndex] is zero, this function draws the left-most line.
  /// [columnIndex] equals [columns], it draws a line which is covered by the
  /// right-most game board border.
  Position verticalLinePosition(int columnIndex) => Position(
    width: 1,
    height: constraints.height,
    left: (columnIndex + 1) * squareSize,
  );

  /// Draws the horizontal line for the given row index. This means that when
  /// [rowIndex] is zero, this function draws the top-most line. When
  /// [rowIndex] equals [rows], it draws a line which is covered by the bottom
  /// game board border.
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
      column: (position.dx / squareSize).ceil(),
      row: (position.dy / squareSize).ceil(),
    );
  }
}

class Coords extends Equatable {
  const Coords({
    required this.row,
    required this.column,
  });

  final int row;
  final int column;

  @override
  String toString() => 'Coords(row: $row, column: $column)';

  @override
  List<Object?> get props => [row, column];
}
