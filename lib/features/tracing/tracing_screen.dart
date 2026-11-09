import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../presentation/common/localization/app_language.dart';
import '../../presentation/common/resources/color_manager.dart';
import '../../presentation/common/resources/font_manager.dart';
import '../../presentation/common/resources/routs_manager.dart';
import '../../presentation/common/resources/values_manager.dart';
import '../../presentation/common/services/sound_service.dart';
import '../letters/letter_item.dart';
import '../settings/settings_cubit.dart';
import 'letter_paths.dart';
import 'tracing_cubit.dart';

/// Trace a letter with one finger. No ads on this screen.
class TracingScreen extends StatelessWidget {
  const TracingScreen({super.key, required this.item});

  final LetterItem item;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TracingCubit(item),
      child: BlocListener<TracingCubit, TracingState>(
        listenWhen: (prev, curr) => !prev.completed && curr.completed,
        listener: (context, state) {
          final sfxOn = context.read<SettingsCubit>().state.sfxOn;
          if (sfxOn) {
            BrushSoundService.instance.playOnce('sounds/magic.mp3');
          }
          Navigator.of(context).pushReplacementNamed(
            Routes.reward,
            arguments: item,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: tr('back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: const [_SoundButtons()],
          ),
          body: Center(
            child: ValueListenableBuilder<String>(
              valueListenable: AppLanguage.current,
              builder: (context, _, _) => _TraceArea(item: item),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundButtons extends StatelessWidget {
  const _SoundButtons();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final cubit = context.read<SettingsCubit>();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: tr('music'),
              icon: Icon(
                settings.musicOn ? Icons.music_note : Icons.music_off,
              ),
              onPressed: () => cubit.setMusic(!settings.musicOn),
            ),
            IconButton(
              tooltip: tr('sound_effects'),
              icon: Icon(
                settings.sfxOn ? Icons.volume_up : Icons.volume_off,
              ),
              onPressed: () => cubit.setSfx(!settings.sfxOn),
            ),
          ],
        );
      },
    );
  }
}

class _TraceArea extends StatelessWidget {
  const _TraceArea({required this.item});

  final LetterItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = (size.height * 0.6).clamp(0.0, size.width * 0.5);
    final cubit = context.read<TracingCubit>();

    return BlocBuilder<TracingCubit, TracingState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('trace_hint'),
              style: TextStyle(
                fontSize: AppPx.p12,
                color: ColorManager.darkPrimary,
              ),
            ),
            if (item.word != null) ...[
              SizedBox(height: AppPx.p4),
              Text(
                item.word!,
                style: TextStyle(
                  fontFamily: item.group == LetterGroup.arabic
                      ? FontConstants.arabicFont
                      : null,
                  fontSize: AppPx.p16,
                  fontWeight: FontWeight.w800,
                  color: ColorManager.darkPrimary,
                ),
              ),
            ],
            SizedBox(height: AppPx.p8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => cubit.startStroke(
                Offset(d.localPosition.dx / side, d.localPosition.dy / side),
              ),
              onPanUpdate: (d) => cubit.extendStroke(
                Offset(d.localPosition.dx / side, d.localPosition.dy / side),
              ),
              child: SizedBox(
                width: side,
                height: side,
                child: Stack(
                  children: [
                    // Guide: the letter outline in light grey, for the child to follow.
                    SvgPicture.asset(
                      item.outline,
                      width: side,
                      height: side,
                      colorFilter: ColorFilter.mode(
                        ColorManager.lightGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    // Dotted path to follow, with a green start dot and arrows.
                    CustomPaint(
                      size: Size(side, side),
                      painter: _PathGuidePainter(
                        letterPaths[item.id] ?? const [],
                      ),
                    ),
                    CustomPaint(
                      size: Size(side, side),
                      painter: _StrokePainter(state.strokes),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppPx.p8),
            SizedBox(
              width: side,
              child: LinearProgressIndicator(value: state.progress),
            ),
          ],
        );
      },
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorManager.pinkPrimary
      ..strokeWidth = size.shortestSide * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.isNotEmpty) {
          canvas.drawCircle(
            Offset(stroke.first.dx * size.width, stroke.first.dy * size.height),
            paint.strokeWidth / 2,
            Paint()..color = ColorManager.pinkPrimary,
          );
        }
        continue;
      }
      final path = Path()
        ..moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}

/// Draws the guide path: dots along each stroke, a green start dot, and an arrow.
class _PathGuidePainter extends CustomPainter {
  _PathGuidePainter(this.strokes);

  final List<List<List<double>>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()
      ..color = ColorManager.pinkPrimary.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final start = Paint()
      ..color = ColorManager.green
      ..style = PaintingStyle.fill;
    final arrow = Paint()
      ..color = ColorManager.darkPrimary
      ..strokeWidth = size.shortestSide * 0.012
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final radius = size.shortestSide * 0.018;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final points = [
        for (final p in stroke) Offset(p[0] * size.width, p[1] * size.height),
      ];
      for (final p in points) {
        canvas.drawCircle(p, radius, dot);
      }
      canvas.drawCircle(points.first, radius * 1.6, start);
      if (points.length >= 2) {
        final mid = points.length ~/ 2;
        final from = points[mid > 0 ? mid - 1 : 0];
        final to = points[mid < points.length - 1 ? mid + 1 : points.length - 1];
        final d = to - from;
        final len = d.distance;
        if (len > 0) {
          final u = d / len;
          final tip = points[mid];
          final back = tip - u * radius * 3;
          final side = Offset(-u.dy, u.dx) * radius * 1.4;
          canvas.drawLine(tip, back + side, arrow);
          canvas.drawLine(tip, back - side, arrow);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathGuidePainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
