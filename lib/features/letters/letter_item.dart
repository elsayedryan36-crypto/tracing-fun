/// One letter or number the child can trace.
enum LetterGroup { arabic, english, numbers }

class LetterItem {
  const LetterItem({
    required this.id,
    required this.glyph,
    required this.group,
    required this.index,
    required this.free,
    required this.picture,
  });

  /// Stable ID, also used as the key for unlocks, e.g. `ar_0`, `en_0`, `num_3`.
  final String id;

  /// The character shown on the tracing screen, e.g. `ا`, `A`, `3`.
  final String glyph;
  final LetterGroup group;

  /// Position inside its group (0-based).
  final int index;

  /// Free items open without an ad. Locked items need the rewarded ad.
  final bool free;

  /// Reward picture shown after a successful trace.
  /// Stand-in art from the coloring app until the owner uploads the real set.
  final String picture;
}

/// The letter set for the first version (see TRACING_APP_SPEC.md, section 2).
///
/// Free: the first 5 Arabic letters and the first 5 English letters.
/// Locked: every other letter, and the numbers 0–10.
class LetterCatalog {
  LetterCatalog._();

  static const List<String> arabic = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص',
    'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي',
  ];

  static const List<String> english = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static const int freePerLanguage = 5;

  /// Stand-in pictures from the coloring app. Cycled per item.
  static const List<String> _pictures = [
    'assets/images/letters/1.svg',
    'assets/images/dragons/1.svg',
    'assets/images/zoo/1.svg',
    'assets/images/sea/1.svg',
    'assets/images/fairy/1.svg',
    'assets/images/space/1.svg',
    'assets/images/planet/1.svg',
    'assets/images/food/1.svg',
    'assets/images/transportation/1.svg',
    'assets/images/circis/1.svg',
  ];

  static String _pictureFor(int i) => _pictures[i % _pictures.length];

  static List<LetterItem> byGroup(LetterGroup group) {
    switch (group) {
      case LetterGroup.arabic:
        return [
          for (var i = 0; i < arabic.length; i++)
            LetterItem(
              id: 'ar_$i',
              glyph: arabic[i],
              group: group,
              index: i,
              free: i < freePerLanguage,
              picture: _pictureFor(i),
            ),
        ];
      case LetterGroup.english:
        return [
          for (var i = 0; i < english.length; i++)
            LetterItem(
              id: 'en_$i',
              glyph: english[i],
              group: group,
              index: i,
              free: i < freePerLanguage,
              picture: _pictureFor(i + 3),
            ),
        ];
      case LetterGroup.numbers:
        return [
          for (var i = 0; i <= 10; i++)
            LetterItem(
              id: 'num_$i',
              glyph: '$i',
              group: group,
              index: i,
              free: false,
              picture: _pictureFor(i + 5),
            ),
        ];
    }
  }
}
