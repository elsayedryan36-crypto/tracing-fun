import 'letter_masks.dart';

/// Checks a child's trace against the letter's shape.
///
/// The letter is a 32×32 grid (see letter_masks.dart): its ink, and its one-cell
/// centre line. The child's finger marks cells on the same grid.
///
/// A letter counts as traced only when:
/// * most of the whole centre line is covered ([minCoverage]), and
/// * every separate part of the letter is covered (for example the dot of ب), so
///   a child cannot finish after tracing only one part ([minPartCoverage]), and
/// * the trace does not wander far from the letter ([maxStray]).
///
/// The check is forgiving about shape (a rough trace is fine), but it does not
/// let the child finish early.
class LetterCheck {
  LetterCheck._();

  static const int grid = letterMaskGrid;
  static const int cellCount = grid * grid;

  /// Share of the whole centre line the child must cover.
  static const double minCoverage = 0.8;

  /// Share of each separate part of the letter the child must cover.
  static const double minPartCoverage = 0.7;

  /// Share of the child's marked cells allowed to be far from the letter.
  static const double maxStray = 0.3;

  /// How far (in cells) from the letter a trace may be and still count.
  static const int tolerance = 2;

  static final Map<String, _Target> _targets = {};

  /// The centre-line cells of a letter (used to draw the dotted guide).
  static Set<int> centreLine(String id) => _target(id).core;

  /// The separate parts of the centre line (for example a letter and its dot).
  static List<Set<int>> parts(String id) => _target(id).parts;

  /// Share of the whole centre line covered (0..1).
  static double coverage(String id, Set<int> marked) {
    final t = _target(id);
    if (t.core.isEmpty) return 0;
    return _share(t.core, marked);
  }

  static bool passes(String id, Set<int> marked) {
    if (marked.isEmpty) return false;
    final t = _target(id);
    if (t.core.isEmpty) return false;
    if (_share(t.core, marked) < minCoverage) return false;
    for (final part in t.parts) {
      if (_share(part, marked) < minPartCoverage) return false;
    }
    return _strayRatio(t, marked) <= maxStray;
  }

  /// A centre-line cell counts as covered when the trace is on it or next to it.
  /// Small fingers are not exact, so this gives about one cell of tolerance.
  static double _share(Set<int> target, Set<int> marked) {
    final reach = _dilate(marked, 1);
    var hit = 0;
    for (final cell in target) {
      if (reach.contains(cell)) hit++;
    }
    return hit / target.length;
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
      final core = centre.isEmpty ? ink : centre;
      return _Target(
        core: core,
        parts: _components(core),
        near: _dilate(ink, tolerance),
      );
    });
  }

  static Set<int> _decode(String hex) {
    final value = BigInt.parse(hex, radix: 16);
    final cells = <int>{};
    for (var i = 0; i < cellCount; i++) {
      // The first cell is the most significant bit.
      final bit = (value >> (cellCount - 1 - i)) & BigInt.one;
      if (bit == BigInt.one) cells.add(i);
    }
    return cells;
  }

  /// Splits cells into groups that touch each other (8 neighbours).
  static List<Set<int>> _components(Set<int> cells) {
    final left = {...cells};
    final parts = <Set<int>>[];
    while (left.isNotEmpty) {
      final start = left.first;
      final part = <int>{};
      final stack = [start];
      left.remove(start);
      while (stack.isNotEmpty) {
        final cell = stack.removeLast();
        part.add(cell);
        final r = cell ~/ grid;
        final c = cell % grid;
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            final nr = r + dr;
            final nc = c + dc;
            if (nr < 0 || nc < 0 || nr >= grid || nc >= grid) continue;
            final next = nr * grid + nc;
            if (left.remove(next)) stack.add(next);
          }
        }
      }
      parts.add(part);
    }
    return parts;
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
  const _Target({required this.core, required this.parts, required this.near});

  /// Centre-line cells the child should cover.
  final Set<int> core;

  /// The centre line split into separate parts.
  final List<Set<int>> parts;

  /// Cells close enough to the letter that a trace there is not stray.
  final Set<int> near;
}
