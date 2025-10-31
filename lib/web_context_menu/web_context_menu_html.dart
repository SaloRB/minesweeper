// Web implementation: disable default browser context menu so right-click can
// be used for in-app actions like flagging a square.
import 'dart:html' as html;

void disableContextMenu() {
  html.document.onContextMenu.listen((event) => event.preventDefault());
}
