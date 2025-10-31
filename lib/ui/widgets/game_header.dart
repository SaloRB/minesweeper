import 'package:flutter/material.dart';
import 'package:minesweeper/engine/minesweeper_engine.dart';
import 'package:minesweeper/ui/theme/minesweeper_theme.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.engine,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    required this.onStart,
    required this.elapsedSeconds,
    required this.isDarkTheme,
    required this.onToggleTheme,
  });

  final MinesweeperEngine? engine;
  final Difficulty selectedDifficulty;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final VoidCallback onStart;
  final int elapsedSeconds;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

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
            Row(
              children: [
                IconButton(
                  tooltip: isDarkTheme ? 'Switch to light' : 'Switch to dark',
                  onPressed: onToggleTheme,
                  icon: Icon(
                    isDarkTheme ? Icons.wb_sunny : Icons.nightlight_round,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ],
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
                color: MinesweeperTheme.headerChipBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MinesweeperTheme.headerChipBorder),
              ),
              child: Text(
                '🚩 ${engine!.remainingFlags}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MinesweeperTheme.headerChipText,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: MinesweeperTheme.headerChipBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: MinesweeperTheme.headerChipBorder,
                    ),
                  ),
                  child: Text(
                    '⏱ ${_formatTime(elapsedSeconds)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MinesweeperTheme.headerChipText,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isDarkTheme ? 'Switch to light' : 'Switch to dark',
                  onPressed: onToggleTheme,
                  icon: Icon(
                    isDarkTheme ? Icons.wb_sunny : Icons.nightlight_round,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
