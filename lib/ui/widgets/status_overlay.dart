import 'package:flutter/material.dart';
import 'package:minesweeper/minesweeper_engine.dart';

class StatusOverlay extends StatelessWidget {
  const StatusOverlay({
    super.key,
    required this.status,
    required this.onPlayAgain,
  });

  final GameStatus status;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    if (status == GameStatus.inProgress) {
      return const SizedBox.shrink(key: ValueKey('none'));
    }

    final bool isWin = status == GameStatus.won;
    final Color borderColor = isWin ? Colors.green[600]! : Colors.red[600]!;
    final Color textColor = isWin ? Colors.green[700]! : Colors.red[700]!;
    final String title = isWin ? 'You Win!' : 'Game Over';
    final Color overlay = isWin
        ? Colors.black.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.15);

    return Stack(
      key: ValueKey(isWin ? 'won' : 'lost'),
      children: [
        Positioned.fill(
          child: ColoredBox(color: overlay),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
