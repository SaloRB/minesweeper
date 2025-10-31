import 'package:flutter/material.dart';

/// Theme configuration for Minesweeper-specific visuals (grid, numbers, etc.).
class MinesweeperTheme {
  const MinesweeperTheme._();

  static MinesweeperThemeMode _mode = MinesweeperThemeMode.light;
  static final ValueNotifier<MinesweeperThemeMode> modeNotifier =
      ValueNotifier<MinesweeperThemeMode>(_mode);

  static MinesweeperThemeMode get mode => _mode;
  static void setMode(MinesweeperThemeMode value) {
    _mode = value;
    modeNotifier.value = value;
  }

  /// Background color used to fill zero-adjacent revealed squares.
  static Color get zeroFillBackground => switch (_mode) {
    MinesweeperThemeMode.light => Colors.grey.shade400,
    MinesweeperThemeMode.dark => Colors.grey.shade900,
  };

  /// Grid line colors
  static Color get verticalLineColor => switch (_mode) {
    MinesweeperThemeMode.light => Colors.grey.shade400,
    MinesweeperThemeMode.dark => Colors.grey.shade600,
  };

  static Color get horizontalLineColor => switch (_mode) {
    MinesweeperThemeMode.light => Colors.grey,
    MinesweeperThemeMode.dark => Colors.grey.shade700,
  };

  /// Outer border color of the grid
  static Color get borderColor => switch (_mode) {
    MinesweeperThemeMode.light => Colors.grey.shade700,
    MinesweeperThemeMode.dark => Colors.grey.shade500,
  };

  /// Color used for numeric counts (1..8) on revealed squares.
  static Color numberColor(int count) {
    return switch (count) {
      1 => Colors.blue.shade700,
      2 => Colors.green.shade700,
      3 => Colors.red.shade700,
      4 => Colors.indigo.shade700,
      5 => Colors.brown.shade700,
      6 => Colors.cyan.shade700,
      7 => Colors.black87,
      8 => Colors.grey.shade800,
      _ => Colors.black,
    };
  }

  /// Header chip styles (counter/timer)
  static Color get headerChipBackground => switch (_mode) {
    MinesweeperThemeMode.light => Colors.white,
    MinesweeperThemeMode.dark => Colors.grey.shade900,
  };
  static Color get headerChipText => switch (_mode) {
    MinesweeperThemeMode.light => Colors.black87,
    MinesweeperThemeMode.dark => Colors.white,
  };
  static Color get headerChipBorder => switch (_mode) {
    MinesweeperThemeMode.light => Colors.grey.shade400,
    MinesweeperThemeMode.dark => Colors.grey.shade700,
  };

  /// Hover overlay styles
  static Color get hoverOverlayFill => switch (_mode) {
    MinesweeperThemeMode.light => Colors.black.withValues(alpha: 0.04),
    MinesweeperThemeMode.dark => Colors.white.withValues(alpha: 0.06),
  };
  static Color get hoverOverlayBorder => switch (_mode) {
    MinesweeperThemeMode.light => Colors.black26,
    MinesweeperThemeMode.dark => Colors.white24,
  };

  /// Status overlay (win/loss) colors
  static Color get statusCardBackground => switch (_mode) {
    MinesweeperThemeMode.light => Colors.white,
    MinesweeperThemeMode.dark => Colors.black,
  };

  static Color get statusWinBorder => Colors.green.shade600;
  static Color get statusLoseBorder => Colors.red.shade600;
  static Color get statusWinText => Colors.green.shade700;
  static Color get statusLoseText => Colors.red.shade700;

  static Color get statusOverlayScrimWin => switch (_mode) {
    MinesweeperThemeMode.light => Colors.black.withValues(alpha: 0.10),
    MinesweeperThemeMode.dark => Colors.black.withValues(alpha: 0.25),
  };
  static Color get statusOverlayScrimLose => switch (_mode) {
    MinesweeperThemeMode.light => Colors.black.withValues(alpha: 0.15),
    MinesweeperThemeMode.dark => Colors.black.withValues(alpha: 0.30),
  };
}

enum MinesweeperThemeMode { light, dark }
