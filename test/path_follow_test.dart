
import 'package:flutter_test/flutter_test.dart';
import 'package:tracing_app/features/letters/letter_item.dart';
import 'package:tracing_app/features/tracing/letter_paths.dart';
import 'package:tracing_app/features/tracing/path_follow.dart';

/// Walks the guide of [id] as a finger would: straight segments between points.
PathFollow _walk(String id, {double share = 1}) {
  final strokes = letterPaths[id]!;
  final follow = PathFollow(strokes);
  final total = strokes.fold<int>(0, (n, s) => n + s.length);
  var walked = 0;
  for (final stroke in strokes) {
    for (var i = 0; i < stroke.length; i++) {
      if (walked / total > share) return follow;
      walked++;
      final p = Offset(stroke[i][0], stroke[i][1]);
      final prev = i == 0 ? p : Offset(stroke[i - 1][0], stroke[i - 1][1]);
      follow.addSegment(prev, p);
    }
  }
  return follow;
}

void main() {
  test('following every guide point passes, for every letter', () {
    for (final item in LetterCatalog.byGroup(LetterGroup.arabic)
        .followedBy(LetterCatalog.byGroup(LetterGroup.english))) {
      if (!letterPaths.containsKey(item.id)) continue;
      expect(_walk(item.id).passes, isTrue, reason: item.id);
    }
  });

  test('nothing traced does not pass', () {
    expect(PathFollow(letterPaths['en_0']!).passes, isFalse);
  });

  test('half the guide does not pass, and progress is about half', () {
    final follow = _walk('en_1', share: 0.5);
    expect(follow.passes, isFalse);
    expect(follow.progress, closeTo(0.5, 0.1));
  });

  test('a rough trace about 1 cell off the line still passes', () {
    final strokes = letterPaths['en_0']!;
    final follow = PathFollow(strokes);
    for (final stroke in strokes) {
      for (var i = 1; i < stroke.length; i++) {
        final a = Offset(stroke[i - 1][0] + 0.02, stroke[i - 1][1]);
        final b = Offset(stroke[i][0] + 0.02, stroke[i][1]);
        follow.addSegment(a, b);
      }
    }
    expect(follow.passes, isTrue);
  });

  test('a fast drag between far-apart points still counts the guide between them', () {
    final follow = PathFollow([
      [[0.1, 0.5], [0.9, 0.5]],
    ]);
    follow.addSegment(const Offset(0.0, 0.5), const Offset(1.0, 0.5));
    expect(follow.passes, isTrue);
  });

  test('a trace far from the letter does not pass', () {
    final follow = PathFollow(letterPaths['en_0']!);
    for (var i = 0; i < 20; i++) {
      follow.addSegment(const Offset(0.01, 0.01), const Offset(0.02, 0.02));
    }
    expect(follow.passes, isFalse);
  });

  test('every letter has a dotted outline', () {
    for (final item in LetterCatalog.byGroup(LetterGroup.arabic)
        .followedBy(LetterCatalog.byGroup(LetterGroup.english))) {
      expect(letterOutlineDots[item.id], isNotNull, reason: item.id);
      expect(letterOutlineDots[item.id], isNotEmpty, reason: item.id);
    }
  });
}
