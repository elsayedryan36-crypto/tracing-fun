import 'package:flutter_test/flutter_test.dart';
import 'package:tracing_app/features/letters/letter_item.dart';

void main() {
  test('Arabic set has 28 letters, 5 free', () {
    final items = LetterCatalog.byGroup(LetterGroup.arabic);
    expect(items.length, 28);
    expect(items.where((i) => i.free).length, 5);
  });

  test('English set has 26 letters, 5 free', () {
    final items = LetterCatalog.byGroup(LetterGroup.english);
    expect(items.length, 26);
    expect(items.where((i) => i.free).length, 5);
  });

  test('Numbers 0-10 are all locked', () {
    final items = LetterCatalog.byGroup(LetterGroup.numbers);
    expect(items.length, 11);
    expect(items.every((i) => !i.free), isTrue);
  });

  test('IDs are unique across groups', () {
    final ids = [
      for (final g in LetterGroup.values) ...LetterCatalog.byGroup(g),
    ].map((i) => i.id).toSet();
    expect(ids.length, 28 + 26 + 11);
  });
}
