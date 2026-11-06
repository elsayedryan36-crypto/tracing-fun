import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which images have been unlocked via a rewarded ad, so a child
/// is never asked to re-watch an ad for something already earned.
class UnlockedImagesStore {
  UnlockedImagesStore._();
  static final UnlockedImagesStore instance = UnlockedImagesStore._();

  static const _prefsKey = 'unlocked_image_ids';

  Future<Set<String>> getUnlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? const [];
    return list.toSet();
  }

  Future<bool> isUnlocked(String imageId) async {
    final ids = await getUnlockedIds();
    return ids.contains(imageId);
  }

  Future<void> unlock(String imageId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_prefsKey) ?? const []).toSet();
    ids.add(imageId);
    await prefs.setStringList(_prefsKey, ids.toList());
  }
}
