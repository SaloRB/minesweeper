import 'dart:ui';

import 'position.dart';

class GameBoardBuilder {
  GameBoardBuilder({
    required this.constraints,
    required this.squareSize,
  });

  final Size constraints;
  final double squareSize;

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
}
