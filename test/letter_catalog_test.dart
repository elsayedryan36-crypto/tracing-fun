import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tracing_app/features/letters/letter_item.dart';

void main() {
  test('Arabic set has 28 letters, 5 free (ا ب ت ث ج)', () {
    final items = LetterCatalog.byGroup(LetterGroup.arabic);
    expect(items.length, 28);
    expect(items.where((i) => i.free).length, 5);
    expect(items.take(5).map((i) => i.glyph).toList(), ['ا', 'ب', 'ت', 'ث', 'ج']);
  });

  test('English set has 26 letters, 5 free (A–E)', () {
    final items = LetterCatalog.byGroup(LetterGroup.english);
    expect(items.length, 26);
    expect(items.where((i) => i.free).length, 5);
    expect(items.take(5).map((i) => i.glyph).toList(), ['A', 'B', 'C', 'D', 'E']);
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

  test('Free letters have a word and a word picture', () {
    final free = [
      ...LetterCatalog.byGroup(LetterGroup.arabic),
      ...LetterCatalog.byGroup(LetterGroup.english),
    ].where((i) => i.free);
    expect(free.length, 10);
    for (final item in free) {
      expect(item.word, isNotNull, reason: item.id);
      expect(item.wordPicture, 'assets/images/words/${item.id}.png');
      expect(item.outline, 'assets/letters/outlines/${item.id}.svg');
    }
  });

  test('Free words match the approved list', () {
    final ar = LetterCatalog.byGroup(LetterGroup.arabic);
    final en = LetterCatalog.byGroup(LetterGroup.english);
    expect([for (final i in ar.take(5)) i.word], ['أسد', 'بطة', 'تفاحة', 'ثعلب', 'جمل']);
    expect([for (final i in en.take(5)) i.word], ['Apple', 'Ball', 'Cat', 'Dog', 'Egg']);
  });

  test('Every letter and number has a word', () {
    for (final g in LetterGroup.values) {
      for (final item in LetterCatalog.byGroup(g)) {
        expect(item.word, isNotNull, reason: item.id);
        expect(item.word!.trim(), isNotEmpty, reason: item.id);
      }
    }
  });

  test('Every registered word picture exists on disk', () {
    for (final g in [LetterGroup.arabic, LetterGroup.english]) {
      for (final item in LetterCatalog.byGroup(g)) {
        if (item.wordPicture == null) continue;
        expect(File(item.wordPicture!).existsSync(), isTrue, reason: item.wordPicture);
      }
    }
  });

  test('Every registered sound file exists on disk', () {
    for (final g in [LetterGroup.arabic, LetterGroup.english]) {
      for (final item in LetterCatalog.byGroup(g)) {
        for (final path in [item.letterAudio, item.wordAudio]) {
          if (path == null) continue;
          expect(File(path).existsSync(), isTrue, reason: path);
        }
      }
    }
  });
}
