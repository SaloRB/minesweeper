import 'package:flutter/widgets.dart';
import 'package:minesweeper/game_board_builder.dart';

/// Difficulty presets that control how many mines are placed on the board.
///
/// Percentages are approximate and based on the total number of squares:
/// - [Difficulty.easy] ≈ 10%
/// - [Difficulty.medium] ≈ 20%
/// - [Difficulty.hard] ≈ 30%
enum Difficulty {
  easy,
  medium,
  hard,
}

/// Core game logic for a simple Minesweeper implementation.
///
/// This engine is responsible for:
/// - Seeding random mine locations according to the given [difficulty].
/// - Exposing the set of all [mineLocations].
/// - Precomputing and exposing the number of adjacent mines for every square
///   via [adjacentMineCounts].
/// - Tracking which squares have been revealed in [revealedLocations].
///
/// Notes
/// - The engine does not currently manage win/lose state or flag placement.
/// - Neighbor lookups use an 8-neighborhood (N, NE, E, SE, S, SW, W, NW).
/// - Out-of-bounds neighbors are ignored implicitly (they don't exist in
///   [mineLocations]).
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

  /// Coordinates that have been revealed by the player.
  final revealedLocations = <Coords>{};
  final mineLocations = <Coords>{};
  final adjacentMineCounts = <Coords, int>{};

  /// Randomly populates [mineLocations] based on the chosen [difficulty] and
  /// precomputes [adjacentMineCounts] for all coordinates.
  void _seedMines() {
    final numSquares = rows * columns;
    final int numMines = switch (difficulty) {
      Difficulty.easy => (numSquares * 0.1).floor(),
      Difficulty.medium => (numSquares * 0.20).round(),
      Difficulty.hard => (numSquares * 0.30).round(),
    };

    final coordsToHoldMines = allCoords.toList()..shuffle();
    mineLocations.addAll(coordsToHoldMines.sublist(0, numMines));

    for (final coords in allCoords) {
      adjacentMineCounts[coords] = getAdjacentMines(coords);
    }
  }

  /// Marks the given [coords] as revealed and notifies listeners.
  void clickedCoordinates(Coords coords) {
    revealedLocations.add(coords);
    notifyListeners();
  }

  /// An iterator of every valid board coordinate in row-major order.
  Iterable<Coords> get allCoords sync* {
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        yield Coords(row: row, column: column);
      }
    }
  }

  /// Returns the number of mines in the 8 adjacent squares surrounding
  /// [coords].
  ///
  /// The center square itself is excluded. Out-of-bounds neighbors are
  /// ignored because they cannot be present in [mineLocations].
  int getAdjacentMines(Coords coords) {
    int adjacentMines = 0;
    for (int rowDelta in rowAdjacencyIterator) {
      for (int columnDelta in columnAdjacencyIterator) {
        final adjacentCoords = Coords(
          row: coords.row + rowDelta,
          column: coords.column + columnDelta,
        );

        if (coords == adjacentCoords) {
          continue;
        }

        if (mineLocations.contains(adjacentCoords)) {
          adjacentMines++;
        }
      }
    }

    return adjacentMines;
  }

  /// Row offsets used for neighbor traversal (-1, 0, +1).
  Iterable<int> get rowAdjacencyIterator sync* {
    yield -1;
    yield 0;
    yield 1;
  }

  /// Column offsets used for neighbor traversal (-1, 0, +1).
  Iterable<int> get columnAdjacencyIterator sync* {
    yield -1;
    yield 0;
    yield 1;
  }
}
