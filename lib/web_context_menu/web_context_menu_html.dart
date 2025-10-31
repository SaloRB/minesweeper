// Web implementation: disable default browser context menu so right-click can
// be used for in-app actions like flagging a square.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void disableContextMenu() {
  html.document.onContextMenu.listen((event) => event.preventDefault());
}
