import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tracing_app/features/letters/letter_item.dart';
import 'package:tracing_app/features/letters/letters_screen.dart';
import 'package:tracing_app/features/reward/reward_screen.dart';
import 'package:tracing_app/features/settings/settings_cubit.dart';
import 'package:tracing_app/features/tracing/tracing_screen.dart';

void _landscape(WidgetTester tester) {
  tester.view.physicalSize = const Size(640, 360);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  final ar0 = LetterCatalog.byGroup(LetterGroup.arabic).first; // has word + picture
  final en1 = LetterCatalog.byGroup(LetterGroup.english)[1]; // no word picture yet

  for (final item in [ar0, en1]) {
    testWidgets('reward screen fits 640x360 for ${item.id}', (tester) async {
      _landscape(tester);
      await tester.pumpWidget(MaterialApp(home: RewardScreen(item: item)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('tracing screen fits 640x360 for ${item.id}', (tester) async {
      _landscape(tester);
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => SettingsCubit(),
          child: MaterialApp(home: TracingScreen(item: item)),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('letters gallery fits 640x360 and can scroll', (tester) async {
    SharedPreferences.setMockInitialValues({});
    _landscape(tester);
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => MaterialApp(
          home: LettersScreen(group: LetterGroup.arabic),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(find.byType(GridView), findsOneWidget);
    await tester.drag(find.byType(GridView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
