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

/// Overall game status.
enum GameStatus {
  inProgress,
  won,
  lost,
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

  /// Coordinates that have been flagged by the player (suspected mines).
  final flaggedLocations = <Coords>{};

  final mineLocations = <Coords>{};
  final adjacentMineCounts = <Coords, int>{};

  /// Current status of the game.
  GameStatus status = GameStatus.inProgress;

  /// Total number of mines on the board.
  int get totalMines => mineLocations.length;

  /// Number of flags remaining (never negative).
  int get remainingFlags {
    final remaining = totalMines - flaggedLocations.length;
    return remaining < 0 ? 0 : remaining;
  }

  /// Resets the game with the same board size and difficulty.
  ///
  /// Clears all revealed and flagged cells, re-seeds mines, recomputes
  /// adjacency counts, and sets [status] back to [GameStatus.inProgress].
  void reset() {
    revealedLocations.clear();
    flaggedLocations.clear();
    mineLocations.clear();
    adjacentMineCounts.clear();
    status = GameStatus.inProgress;
    _seedMines();
    notifyListeners();
  }

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

  /// Handles a user click on [coords].
  ///
  /// - If [coords] is out of bounds, this is a no-op.
  /// - If [coords] is a mine, this is a no-op (game-over handling not
  ///   implemented here).
  /// - If [coords] has one or more adjacent mines, only that square is
  ///   revealed.
  /// - If [coords] has zero adjacent mines, reveal all connected zero-adjacent
  ///   squares and their numbered perimeter recursively (classic minesweeper
  ///   flood fill).
  void clickedCoordinates(Coords coords) {
    if (status != GameStatus.inProgress) return;
    if (!isInBounds(coords)) return;
    if (flaggedLocations.contains(coords)) return; // don't reveal flagged cells

    // Chord action: clicking an already-revealed numbered cell reveals
    // all adjacent unflagged, unrevealed neighbors when the number of
    // adjacent flags equals the cell's number.
    if (revealedLocations.contains(coords)) {
      final count = adjacentMineCounts[coords] ?? 0;
      if (count > 0) {
        _chordReveal(coords, requiredFlagCount: count);
      }
      return; // Either performed a chord reveal or no-op.
    }
    // Ensure the first click is never a mine by relocating it elsewhere.
    if (revealedLocations.isEmpty && mineLocations.contains(coords)) {
      _relocateMineFrom(coords);
    }
    if (mineLocations.contains(coords)) {
      _revealAllMinesAndLose();
      notifyListeners();
      return;
    }

    final count = adjacentMineCounts[coords] ?? 0;
    if (count > 0) {
      revealedLocations.add(coords);
      _updateWinIfAny();
      notifyListeners();
      return;
    }

    _revealZeroRegion(coords);
    _updateWinIfAny();
    notifyListeners();
  }

  /// Perform a "chord" reveal on a numbered, already-revealed square.
  ///
  /// If the number of adjacent flagged cells equals [requiredFlagCount],
  /// reveal all adjacent cells that are not flagged and not already revealed.
  /// If any revealed neighbor is a mine, the game is lost immediately.
  void _chordReveal(Coords center, {required int requiredFlagCount}) {
    // Count adjacent flags
    final flaggedCount = neighborsOf(
      center,
    ).where((n) => flaggedLocations.contains(n)).length;

    if (flaggedCount != requiredFlagCount) return; // Not satisfied: no-op

    bool lost = false;
    for (final n in neighborsOf(center)) {
      if (flaggedLocations.contains(n)) continue;
      if (revealedLocations.contains(n)) continue;

      if (mineLocations.contains(n)) {
        lost = true;
        break;
      }

      final c = adjacentMineCounts[n] ?? 0;
      if (c == 0) {
        _revealZeroRegion(n);
      } else {
        revealedLocations.add(n);
      }
    }

    if (lost) {
      _revealAllMinesAndLose();
      notifyListeners();
      return;
    }

    _updateWinIfAny();
    notifyListeners();
  }

  /// Toggles a flag on [coords]. Flags cannot be placed on already-revealed
  /// cells. No-op when the game is not in progress or when [coords] is
  /// out-of-bounds.
  void toggleFlag(Coords coords) {
    if (status != GameStatus.inProgress) return;
    if (!isInBounds(coords)) return;
    if (revealedLocations.contains(coords)) return;

    if (!flaggedLocations.add(coords)) {
      // Was already present; remove instead (toggle off)
      flaggedLocations.remove(coords);
    }
    notifyListeners();
  }

  /// Reveals all connected zero-adjacent cells starting from [start] and also
  /// reveals their immediate non-mine neighbors (the numeric border).
  void _revealZeroRegion(Coords start) {
    final stack = <Coords>[];
    if (!revealedLocations.contains(start)) {
      revealedLocations.add(start);
    }
    stack.add(start);

    while (stack.isNotEmpty) {
      final current = stack.removeLast();

      for (final n in neighborsOf(current)) {
        if (mineLocations.contains(n)) continue;
        if (flaggedLocations.contains(n)) continue; // don't auto-reveal flags
        if (revealedLocations.contains(n)) continue;

        // Always reveal non-mine neighbors of a zero cell.
        revealedLocations.add(n);

        // If neighbor is also a zero, continue expanding.
        if ((adjacentMineCounts[n] ?? 0) == 0) {
          stack.add(n);
        }
      }
    }
  }

  /// Move a mine away from [from] to a random safe square and recompute
  /// adjacency counts. Used to guarantee the first click is never a mine.
  void _relocateMineFrom(Coords from) {
    final removed = mineLocations.remove(from);
    if (!removed) return;
    // Pick a new location that is not the clicked cell and not already a mine.
    final candidates =
        allCoords.where((c) => c != from && !mineLocations.contains(c)).toList()
          ..shuffle();
    if (candidates.isNotEmpty) {
      mineLocations.add(candidates.first);
    }
    _recomputeAdjacency();
  }

  void _recomputeAdjacency() {
    adjacentMineCounts.clear();
    for (final coords in allCoords) {
      adjacentMineCounts[coords] = getAdjacentMines(coords);
    }
  }

  /// Reveal all mines and mark the game as lost.
  void _revealAllMinesAndLose() {
    revealedLocations.addAll(mineLocations);
    status = GameStatus.lost;
  }

  /// Checks for victory and updates [status] accordingly.
  void _updateWinIfAny() {
    if (status != GameStatus.inProgress) return;
    final totalSafeSquares = rows * columns - mineLocations.length;
    if (revealedLocations.length >= totalSafeSquares) {
      status = GameStatus.won;
    }
  }

  /// Returns true if [coords] lies within the board boundaries.
  bool isInBounds(Coords coords) =>
      coords.row >= 0 &&
      coords.row < rows &&
      coords.column >= 0 &&
      coords.column < columns;

  /// Returns all in-bounds neighbors around [coords] (8-neighborhood).
  Iterable<Coords> neighborsOf(Coords coords) sync* {
    for (final dr in rowAdjacencyIterator) {
      for (final dc in columnAdjacencyIterator) {
        if (dr == 0 && dc == 0) continue;
        final n = Coords(row: coords.row + dr, column: coords.column + dc);
        if (isInBounds(n)) yield n;
      }
    }
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
