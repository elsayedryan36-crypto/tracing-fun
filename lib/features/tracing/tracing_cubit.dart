import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../letters/letter_item.dart';

class TracingState {
  const TracingState({
    this.strokes = const [],
    this.covered = const {},
    this.completed = false,
  });

  /// Each stroke is a list of points in normalised coordinates (0..1).
  final List<List<Offset>> strokes;

  /// Grid cells the child has touched.
  final Set<int> covered;
  final bool completed;

  double get progress => covered.length / TracingCubit.totalCells;

  TracingState copyWith({
    List<List<Offset>>? strokes,
    Set<int>? covered,
    bool? completed,
  }) {
    return TracingState(
      strokes: strokes ?? this.strokes,
      covered: covered ?? this.covered,
      completed: completed ?? this.completed,
    );
  }
}

/// Success check for the first version.
///
/// The guide box is split into a 4×4 grid. A trace succeeds when the child
/// has touched at least [passRatio] of the cells. This is forgiving on purpose
/// (ages 3–5). A later version can compare against the real letter outline.
class TracingCubit extends Cubit<TracingState> {
  TracingCubit(this.item) : super(const TracingState());

  static const int gridSize = 4;
  static const int totalCells = gridSize * gridSize;
  static const double passRatio = 0.6;

  final LetterItem item;

  void startStroke(Offset p) {
    if (state.completed) return;
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

    final covered = {...state.covered, _cellOf(point)};
    final done = covered.length / totalCells >= passRatio;

    emit(
      state.copyWith(
        strokes: strokes,
        covered: covered,
        completed: done,
      ),
    );
  }

  int _cellOf(Offset p) {
    final col = (p.dx * gridSize).floor().clamp(0, gridSize - 1);
    final row = (p.dy * gridSize).floor().clamp(0, gridSize - 1);
    return row * gridSize + col;
  }
}
