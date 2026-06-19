import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:show_fps/show_fps.dart';

// Regression test for: TypeError: Null check operator used on a null value
//   #0 State.setState (framework.dart:1219)
//   #1 ShowFPSState.update (show_fps.dart:178)
//
// Root cause: ShowFPSState.update unconditionally re-registers itself via
// addPostFrameCallback on every frame, but dispose() never cancels these
// callbacks. When the widget is removed from the tree the next post-frame
// fires update(), which calls setState() on a dead element, hitting the
// null-check crash inside _element!.markNeedsBuild().
//
// Fix: guard update() with `if (!mounted) return;` so that both the
// setState() call and the re-registration are skipped after disposal.

void main() {
  testWidgets('ShowFPS does not crash when unmounted between frames',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShowFPS(
          visible: false,
          child: SizedBox.shrink(),
        ),
      ),
    );

    // Replace ShowFPS with a plain widget, triggering disposal of ShowFPSState.
    await tester.pumpWidget(
      const MaterialApp(home: SizedBox.shrink()),
    );

    // Pump several more frames. Without the mounted guard, the lingering
    // post-frame callback would fire here and crash with a null-check error.
    await tester.pump();
    await tester.pump();
    await tester.pump();
  });

  testWidgets('ShowFPS does not crash when visible and then unmounted',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShowFPS(
          visible: true,
          showChart: true,
          child: SizedBox.shrink(),
        ),
      ),
    );

    // Let a few frames accumulate timing data.
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    // Remove the widget mid-stream.
    await tester.pumpWidget(
      const MaterialApp(home: SizedBox.shrink()),
    );

    // Subsequent frames must not crash.
    await tester.pump();
    await tester.pump();
  });
}
