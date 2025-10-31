import 'package:flutter/material.dart';
import 'package:minesweeper/minesweeper_engine.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.engine,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    required this.onStart,
    required this.elapsedSeconds,
  });

  final MinesweeperEngine? engine;
  final Difficulty selectedDifficulty;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final VoidCallback onStart;
  final int elapsedSeconds;

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (engine == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Difficulty: '),
                const SizedBox(width: 8),
                DropdownButton<Difficulty>(
                  value: selectedDifficulty,
                  onChanged: (d) {
                    if (d != null) onDifficultyChanged(d);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Difficulty.easy,
                      child: Text('Easy'),
                    ),
                    DropdownMenuItem(
                      value: Difficulty.medium,
                      child: Text('Medium'),
                    ),
                    DropdownMenuItem(
                      value: Difficulty.hard,
                      child: Text('Hard'),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: engine!,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Text(
                '🚩 ${engine!.remainingFlags} / ${engine!.totalMines}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Text(
                '⏱ ${_formatTime(elapsedSeconds)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
