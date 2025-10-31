# minesweeper

A new Flutter project.

## About

Classic Minesweeper built with Flutter. Clear the board by revealing all safe cells without triggering any mines. Runs on Flutter-supported platforms.

## How to play

- Reveal a cell to see if it is safe.
- Numbers show how many mines are adjacent.
- Flag cells you suspect contain mines.
- Win by revealing all non-mine cells.

## Controls

- Mobile: tap to reveal, long-press to flag.
- Desktop/Web: left-click to reveal, right-click or Shift+click to flag.

## Run locally

- Prerequisites: Flutter SDK installed
- Install deps: flutter pub get
- Run: flutter run

## Tech

- Flutter (Dart)
- Null-safety, hot reload, cross-platform UI

## Code structure

- `lib/minesweeper_engine.dart`: Core game rules, board state, flood-fill reveal, flags, win/loss.
- `lib/game_board_builder.dart` and `lib/position.dart`: Lightweight layout helpers to position grid elements.
- `lib/ui/` UI layer (widgets only):
  - `ui/screens/game_screen.dart`: Screen that owns the engine lifecycle, timer, difficulty, and composes the UI.
  - `ui/board/game_grid.dart`: Interactive grid surface (mouse hover, click/flag gestures, rendering layers).
  - `ui/widgets/game_header.dart`: Difficulty selector (pre-game) and flags/timer header (in-game).
  - `ui/widgets/status_overlay.dart`: Win/Loss overlay with Play again.
- `lib/web_context_menu/`: Small web-only shim to disable the browser context menu so right-click can place flags in the web build.

The app entry point `lib/main.dart` is intentionally thin: it disables the web context menu (on web) and boots the `GameScreen` inside a `MaterialApp`.
