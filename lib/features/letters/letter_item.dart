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

  /// Word for the letter (see docs/word-list.md). Null for numbers without a word.
  final String? word;

  /// Word picture (AI-generated illustration). Null until the picture is made.
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

  /// Words from docs/word-list.md (approved draft). Index = position in the group.
  static const List<String> _arabicWords = [
    'أسد', 'بطة', 'تفاحة', 'ثعلب', 'جمل', 'حصان', 'خروف', 'دب', 'ذئب', 'رمان',
    'زرافة', 'سمكة', 'شمس', 'صقر', 'ضفدع', 'طائرة', 'ظبي', 'عنب', 'غيمة', 'فيل',
    'قمر', 'كتاب', 'ليمون', 'موزة', 'نحلة', 'هرم', 'وردة', 'يمامة',
  ];

  static const List<String> _englishWords = [
    'Apple', 'Ball', 'Cat', 'Dog', 'Egg', 'Fish', 'Grapes', 'House', 'Ice cream',
    'Juice', 'Kite', 'Lion', 'Moon', 'Nest', 'Orange', 'Pig', 'Queen', 'Rabbit',
    'Sun', 'Tree', 'Umbrella', 'Van', 'Watermelon', 'Xylophone', 'Yo-yo', 'Zebra',
  ];

  /// Words for numbers 0–10 (English; the Arabic words are in docs/word-list.md).
  static const List<String> _numberWords = [
    'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
  ];

  /// Letters that have a word picture file in assets/images/words/.
  /// Add an ID here when its picture file is added.
  static const Set<String> _pictured = {
    'ar_0', 'ar_1', 'ar_2', 'ar_3', 'ar_4', 'ar_5', 'ar_6', 'ar_7', 'ar_8', 'ar_9',
    'ar_10', 'ar_11', 'ar_12', 'ar_13', 'ar_14',
    'en_0', 'en_1', 'en_2', 'en_3', 'en_4', 'en_5', 'en_11', 'en_18',
  };

  static String? _wordPictureFor(String id) =>
      _pictured.contains(id) ? 'assets/images/words/$id.png' : null;

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
              wordPicture: _wordPictureFor('ar_$i'),
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
              wordPicture: _wordPictureFor('en_$i'),
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
              word: _numberWords[i],
            ),
        ];
    }
  }
}
