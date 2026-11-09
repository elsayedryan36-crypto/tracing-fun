import 'package:flutter_test/flutter_test.dart';
import 'package:tracing_app/features/tracing/letter_check.dart';

void main() {
  test('tracing the letter centre line passes', () {
    for (final id in ['ar_0', 'ar_3', 'en_0', 'en_1', 'en_4']) {
      final line = LetterCheck.centreLine(id);
      expect(line, isNotEmpty, reason: id);
      expect(LetterCheck.passes(id, line), isTrue, reason: id);
    }
  });

  test('a trace one cell off the line still passes (rough trace)', () {
    // The app marks a 3x3 brush around each finger point, so mark the same way.
    const g = LetterCheck.grid;
    final shifted = <int>{};
    for (final c in LetterCheck.centreLine('en_0')) {
      final row = c ~/ g;
      final col = c % g + 1; // one cell to the right
      if (col >= g) continue;
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          final r = row + dr;
          final cc = col + dc;
          if (r < 0 || r >= g || cc < 0 || cc >= g) continue;
          shifted.add(r * g + cc);
        }
      }
    }
    expect(LetterCheck.passes('en_0', shifted), isTrue);
  });

  test('nothing traced does not pass', () {
    expect(LetterCheck.passes('en_0', <int>{}), isFalse);
  });

  test('a few dots do not pass', () {
    expect(LetterCheck.passes('en_0', {0, 1, 2, 500}), isFalse);
  });

  test('a different letter does not pass', () {
    expect(LetterCheck.passes('en_0', LetterCheck.centreLine('en_1')), isFalse);
    expect(LetterCheck.passes('en_2', LetterCheck.centreLine('en_3')), isFalse);
  });

  test('covering only half the letter does not pass', () {
    final line = LetterCheck.centreLine('en_1').toList()..sort();
    final half = line.take(line.length ~/ 2).toSet();
    expect(LetterCheck.coverage('en_1', half), lessThan(LetterCheck.minCoverage));
    expect(LetterCheck.passes('en_1', half), isFalse);
  });

  test('ب has its dot as a separate part', () {
    expect(LetterCheck.parts('ar_1').length, greaterThanOrEqualTo(2));
  });

  test('a trace that misses one part (the dot) does not pass', () {
    final parts = LetterCheck.parts('ar_1');
    final marked = {
      for (final p in parts.skip(1)) ...p,
    };
    expect(LetterCheck.passes('ar_1', marked), isFalse);
  });

  test('a trace that covers only about 80% of the letter does not pass', () {
    final line = LetterCheck.centreLine('en_1').toList()..sort();
    final most = line.take((line.length * 0.8).floor()).toSet();
    expect(LetterCheck.passes('en_1', most), isFalse);
  });

  test('a finished trace of every part passes for an Arabic letter', () {
    final line = LetterCheck.centreLine('ar_1');
    expect(LetterCheck.passes('ar_1', line), isTrue);
  });
}
