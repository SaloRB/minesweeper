import 'package:flutter/widgets.dart';
import 'package:minesweeper/models/coords.dart';

/// Difficulty presets that control how many mines are placed on the board.
///
/// Percentages are approximate and based on the total number of squares:
/// - [Difficulty.easy] ≈ 10%
/// - [Difficulty.medium] ≈ 20%
/// - [Difficulty.hard] ≈ 30%
enum Difficulty { easy, medium, hard }

/// Overall game status.
enum GameStatus { inProgress, won, lost }

/// Core game logic for a simple Minesweeper implementation.
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

  void reset() {
    revealedLocations.clear();
    flaggedLocations.clear();
    mineLocations.clear();
    adjacentMineCounts.clear();
    status = GameStatus.inProgress;
    _seedMines();
    notifyListeners();
  }

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

  void clickedCoordinates(Coords coords) {
    if (status != GameStatus.inProgress) return;
    if (!isInBounds(coords)) return;
    if (flaggedLocations.contains(coords)) return;

    // Chord action for already-revealed numbered cells
    if (revealedLocations.contains(coords)) {
      final count = adjacentMineCounts[coords] ?? 0;
      if (count > 0) {
        _chordReveal(coords, requiredFlagCount: count);
      }
      return;
    }

    // First click safety: relocate mine if needed
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

  void toggleFlag(Coords coords) {
    if (status != GameStatus.inProgress) return;
    if (!isInBounds(coords)) return;
    if (revealedLocations.contains(coords)) return;

    if (!flaggedLocations.add(coords)) {
      flaggedLocations.remove(coords);
    }
    notifyListeners();
  }

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
        if (flaggedLocations.contains(n)) continue;
        if (revealedLocations.contains(n)) continue;

        revealedLocations.add(n);

        if ((adjacentMineCounts[n] ?? 0) == 0) {
          stack.add(n);
        }
      }
    }
  }

  void _relocateMineFrom(Coords from) {
    final removed = mineLocations.remove(from);
    if (!removed) return;
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

  void _revealAllMinesAndLose() {
    revealedLocations.addAll(mineLocations);
    status = GameStatus.lost;
  }

  void _updateWinIfAny() {
    if (status != GameStatus.inProgress) return;
    final totalSafeSquares = rows * columns - mineLocations.length;
    if (revealedLocations.length >= totalSafeSquares) {
      status = GameStatus.won;
    }
  }

  bool isInBounds(Coords coords) =>
      coords.row >= 0 &&
      coords.row < rows &&
      coords.column >= 0 &&
      coords.column < columns;

  Iterable<Coords> neighborsOf(Coords coords) sync* {
    for (final dr in rowAdjacencyIterator) {
      for (final dc in columnAdjacencyIterator) {
        if (dr == 0 && dc == 0) continue;
        final n = Coords(row: coords.row + dr, column: coords.column + dc);
        if (isInBounds(n)) yield n;
      }
    }
  }

  Iterable<Coords> get allCoords sync* {
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        yield Coords(row: row, column: column);
      }
    }
  }

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

  Iterable<int> get rowAdjacencyIterator sync* {
    yield -1;
    yield 0;
    yield 1;
  }

  Iterable<int> get columnAdjacencyIterator sync* {
    yield -1;
    yield 0;
    yield 1;
  }

  void _chordReveal(Coords center, {required int requiredFlagCount}) {
    final flaggedCount = neighborsOf(
      center,
    ).where((n) => flaggedLocations.contains(n)).length;

    if (flaggedCount != requiredFlagCount) return;

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
}
