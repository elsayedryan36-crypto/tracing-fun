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
    this.word,
    this.wordPicture,
  });

  /// Stable ID, also used as the key for unlocks and the check grid, e.g. `ar_0`, `en_0`, `num_3`.
  final String id;

  /// The character shown on the letter card, e.g. `ا`, `A`, `3`.
  final String glyph;
  final LetterGroup group;

  /// Position inside its group (0-based).
  final int index;

  /// Free items open without an ad. Locked items need the rewarded ad.
  final bool free;

  /// Coloring-page picture shown after a successful trace (kept from the coloring app).
  final String picture;

  /// Word for the letter, e.g. `تفاحة` or `Apple`. Null until the word is added.
  final String? word;

  /// Word picture (AI-generated illustration). Null until it is added.
  final String? wordPicture;

  /// Outline SVG shown on the tracing screen.
  String get outline => 'assets/letters/outlines/$id.svg';
}

/// The letter set for the first version (see TRACING_APP_SPEC.md, section 2).
///
/// Free: the first 5 Arabic letters (ا ب ت ث ج) and the first 5 English letters (A–E).
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

  /// Words for the letters that have a picture so far. Index = position in the group.
  /// Add more here as the owner approves each word.
  static const Map<int, String> _arabicWords = {
    0: 'أسد',
    1: 'بطة',
    2: 'تفاحة',
    3: 'ثعلب',
    4: 'جمل',
  };

  static const Map<int, String> _englishWords = {
    0: 'Apple',
    1: 'Ball',
    2: 'Cat',
    3: 'Dog',
    4: 'Egg',
  };

  /// Coloring-page pictures from the coloring app. Cycled per item.
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
              word: _arabicWords[i],
              wordPicture: _arabicWords.containsKey(i)
                  ? 'assets/images/words/ar_$i.png'
                  : null,
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
              word: _englishWords[i],
              wordPicture: _englishWords.containsKey(i)
                  ? 'assets/images/words/en_$i.png'
                  : null,
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
