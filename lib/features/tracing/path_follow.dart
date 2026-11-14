import 'dart:math';
import 'dart:ui';

/// Checks a trace against the letter's centre-line guide.
///
/// Every point of the guide is a target. A target counts as traced when the
/// child's finger passed within [radius] of it. The letter is finished when
/// [minShare] of the targets are traced. Coordinates are normalised (0..1) in
/// the tracing area, like the guide itself.
class PathFollow {
  PathFollow(
    List<List<List<double>>> strokes, {
    this.radius = 0.06,
    this.minShare = 0.95,
  })  : _targets = [
          for (final stroke in strokes)
            for (final p in stroke) Offset(p[0], p[1]),
        ],
        _hit = List<bool>.filled(
          [for (final stroke in strokes) ...stroke].length,
          false,
        );

  /// How close (normalised units) the finger must pass to a guide point.
  final double radius;

  /// Share of guide points that must be traced to finish the letter.
  final double minShare;

  final List<Offset> _targets;
  final List<bool> _hit;
  int _hits = 0;

  /// Share of guide points traced so far (0..1).
  double get progress => _targets.isEmpty ? 0 : _hits / _targets.length;

  bool get passes => progress >= minShare;

  /// Whether each guide point has been traced (same order as the guide).
  List<bool> get hits => List.unmodifiable(_hit);

  /// Records the finger moving from [a] to [b].
  void addSegment(Offset a, Offset b) {
    for (var i = 0; i < _targets.length; i++) {
      if (_hit[i]) continue;
      if (_distanceToSegment(_targets[i], a, b) <= radius) {
        _hit[i] = true;
        _hits++;
      }
    }
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSquared == 0) return (p - a).distance;
    final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lengthSquared)
        .clamp(0.0, 1.0);
    final nearest = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return sqrt(pow(p.dx - nearest.dx, 2) + pow(p.dy - nearest.dy, 2));
  }
}
