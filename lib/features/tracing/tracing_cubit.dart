import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../letters/letter_item.dart';
import '../letters/letter_voice.dart';
import 'letter_paths.dart';
import 'path_follow.dart';

class TracingState {
  const TracingState({
    this.strokes = const [],
    this.progress = 0,
    this.completed = false,
  });

  /// Each stroke is a list of points in normalised coordinates (0..1).
  final List<List<Offset>> strokes;

  /// Share of the centre-line guide the child has followed (0..1).
  final double progress;

  final bool completed;

  TracingState copyWith({
    List<List<Offset>>? strokes,
    double? progress,
    bool? completed,
  }) {
    return TracingState(
      strokes: strokes ?? this.strokes,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
    );
  }
}

/// Traces a letter by following its centre-line guide (see path_follow.dart).
class TracingCubit extends Cubit<TracingState> {
  TracingCubit(this.item) : super(const TracingState()) {
    _follow = PathFollow(letterPaths[item.id] ?? const []);
    LetterVoice.play(item.letterAudio);
  }

  final LetterItem item;
  late final PathFollow _follow;
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
    final from = (newStroke || _last == null) ? point : _last!;
    _follow.addSegment(from, point);
    _last = point;
    emit(
      state.copyWith(
        strokes: strokes,
        progress: _follow.progress,
        completed: _follow.passes,
      ),
    );
  }
}
