import 'letter_masks.dart';

/// Checks a child's trace against the letter's shape.
///
/// The letter is a 32×32 grid (see letter_masks.dart): its ink, and its one-cell
/// centre line. The child's finger marks cells on the same grid. Two numbers
/// decide the result:
///
/// * coverage: how much of the letter's centre line the child has covered.
/// * stray: how much of the child's trace is far from the letter.
///
/// The check is forgiving on purpose (ages 3–5): the trace may be rough, as
/// long as it follows the letter and does not wander far off it.
class LetterCheck {
  LetterCheck._();

  static const int grid = letterMaskGrid;
  static const int cellCount = grid * grid;

  /// Share of the centre line the child must cover.
  static const double minCoverage = 0.6;

  /// Share of the child's marked cells allowed to be far from the letter.
  static const double maxStray = 0.3;

  /// How far (in cells) from the letter a trace may be and still count.
  static const int tolerance = 2;

  static final Map<String, _Target> _targets = {};

  /// The centre-line cells of a letter (used by tests and to show progress).
  static Set<int> centreLine(String id) => _target(id).core;

  static bool passes(String id, Set<int> marked) {
    if (marked.isEmpty) return false;
    final t = _target(id);
    return coverage(id, marked) >= minCoverage &&
        _strayRatio(t, marked) <= maxStray;
  }

  /// Share of the centre line covered (0..1).
  static double coverage(String id, Set<int> marked) {
    final t = _target(id);
    if (t.core.isEmpty) return 0;
    var hit = 0;
    for (final cell in t.core) {
      if (marked.contains(cell)) hit++;
    }
    return hit / t.core.length;
  }

  static double _strayRatio(_Target t, Set<int> marked) {
    if (marked.isEmpty) return 1;
    var stray = 0;
    for (final cell in marked) {
      if (!t.near.contains(cell)) stray++;
    }
    return stray / marked.length;
  }

  static _Target _target(String id) {
    return _targets.putIfAbsent(id, () {
      final inkHex = letterMaskHex[id];
      final centreHex = letterCentreHex[id];
      if (inkHex == null || centreHex == null) {
        throw ArgumentError('No check grid for letter id: $id');
      }
      final ink = _decode(inkHex);
      final centre = _decode(centreHex);
      return _Target(
        core: centre.isEmpty ? ink : centre,
        near: _dilate(ink, tolerance),
      );
    });
  }

  static Set<int> _decode(String hex) {
    final value = BigInt.parse(hex, radix: 16);
    final cells = <int>{};
    for (var i = 0; i < cellCount; i++) {
      // Bit 0 of the value is the last cell (bottom-right).
      final bit = (value >> (cellCount - 1 - i)) & BigInt.one;
      if (bit == BigInt.one) cells.add(i);
    }
    return cells;
  }

  static Set<int> _dilate(Set<int> cells, int radius) {
    final out = <int>{};
    for (final cell in cells) {
      final r = cell ~/ grid;
      final c = cell % grid;
      for (var dr = -radius; dr <= radius; dr++) {
        for (var dc = -radius; dc <= radius; dc++) {
          final nr = r + dr;
          final nc = c + dc;
          if (nr < 0 || nc < 0 || nr >= grid || nc >= grid) continue;
          out.add(nr * grid + nc);
        }
      }
    }
    return out;
  }
}

class _Target {
  const _Target({required this.core, required this.near});

  /// Centre line cells the child should cover.
  final Set<int> core;

  /// Cells close enough to the letter that a trace there is not stray.
  final Set<int> near;
}
