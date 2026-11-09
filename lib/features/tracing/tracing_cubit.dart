import 'dart:math';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../letters/letter_item.dart';
import '../letters/letter_voice.dart';
import 'letter_check.dart';

class TracingState {
  const TracingState({
    this.strokes = const [],
    this.marked = const {},
    this.progress = 0,
    this.completed = false,
  });

  /// Each stroke is a list of points in normalised coordinates (0..1).
  final List<List<Offset>> strokes;

  /// Grid cells (0..1023) the child's finger has been on.
  final Set<int> marked;

  /// Share of the letter's centre line covered (0..1), for the progress bar.
  final double progress;

  final bool completed;

  TracingState copyWith({
    List<List<Offset>>? strokes,
    Set<int>? marked,
    double? progress,
    bool? completed,
  }) {
    return TracingState(
      strokes: strokes ?? this.strokes,
      marked: marked ?? this.marked,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
    );
  }
}

/// Traces a letter against its outline (see letter_check.dart).
class TracingCubit extends Cubit<TracingState> {
  TracingCubit(this.item) : super(const TracingState()) {
    LetterVoice.play(item.letterAudio);
  }

  static const int gridSize = LetterCheck.grid;

  final LetterItem item;
  Offset? _last;

  void startStroke(Offset p) {
    if (state.completed) return;
    _last = null;
    _addPoint(p, newStroke: true);
  }

  void extendStroke(Offset p) {
    if (state.completed) return;
    _addPoint(p, newStroke: false);
  }

  void _addPoint(Offset p, {required bool newStroke}) {
    final point = Offset(p.dx.clamp(0.0, 1.0), p.dy.clamp(0.0, 1.0));
    final strokes = [...state.strokes];
    if (newStroke || strokes.isEmpty) {
      strokes.add([point]);
    } else {
      strokes[strokes.length - 1] = [...strokes.last, point];
    }

    final marked = {...state.marked};
    final from = (newStroke || _last == null) ? point : _last!;
    _markLine(marked, from, point);
    _last = point;

    emit(
      state.copyWith(
        strokes: strokes,
        marked: marked,
        progress: LetterCheck.coverage(item.id, marked),
        completed: LetterCheck.passes(item.id, marked),
      ),
    );
  }

  /// Marks every cell between two points, so fast drags leave no gaps.
  void _markLine(Set<int> marked, Offset a, Offset b) {
    final length = (b - a).distance * gridSize;
    final steps = max(1, (length * 2).ceil());
    for (var i = 0; i <= steps; i++) {
      final p = Offset.lerp(a, b, i / steps)!;
      marked.addAll(_brush(p));
    }
  }

  /// The cell under the finger plus its neighbours (a 3×3 brush).
  Set<int> _brush(Offset p) {
    final col = (p.dx * gridSize).floor().clamp(0, gridSize - 1);
    final row = (p.dy * gridSize).floor().clamp(0, gridSize - 1);
    final cells = <int>{};
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        final r = row + dr;
        final c = col + dc;
        if (r < 0 || c < 0 || r >= gridSize || c >= gridSize) continue;
        cells.add(r * gridSize + c);
      }
    }
    return cells;
  }
}
