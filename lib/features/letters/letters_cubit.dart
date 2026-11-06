import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/rewarded_ad_service.dart';
import '../../data/services/unlocked_images_store.dart';
import 'letter_item.dart';

class LettersState {
  const LettersState({
    this.loading = true,
    this.failed = false,
    this.items = const [],
    this.unlockedIds = const {},
    this.lastUnlocked,
  });

  final bool loading;
  final bool failed;
  final List<LetterItem> items;
  final Set<String> unlockedIds;

  /// Set when a rewarded ad finishes. The screen opens this letter, then clears it.
  final LetterItem? lastUnlocked;

  LettersState copyWith({
    bool? loading,
    bool? failed,
    List<LetterItem>? items,
    Set<String>? unlockedIds,
    LetterItem? lastUnlocked,
    bool clearLastUnlocked = false,
  }) {
    return LettersState(
      loading: loading ?? this.loading,
      failed: failed ?? this.failed,
      items: items ?? this.items,
      unlockedIds: unlockedIds ?? this.unlockedIds,
      lastUnlocked:
          clearLastUnlocked ? null : (lastUnlocked ?? this.lastUnlocked),
    );
  }
}

class LettersCubit extends Cubit<LettersState> {
  LettersCubit(this.group) : super(const LettersState());

  final LetterGroup group;

  bool isOpen(LetterItem item) =>
      item.free || state.unlockedIds.contains(item.id);

  Future<void> load() async {
    emit(state.copyWith(loading: true, failed: false));
    try {
      final unlocked = await UnlockedImagesStore.instance.getUnlockedIds();
      emit(
        state.copyWith(
          loading: false,
          items: LetterCatalog.byGroup(group),
          unlockedIds: unlocked,
        ),
      );
    } catch (e) {
      debugPrint('letters load failed: $e');
      emit(state.copyWith(loading: false, failed: true));
    }
  }

  /// Called when a child taps a locked letter. Never waits with a fixed delay:
  /// the rewarded service opens the ad at once if it is loaded, or as soon as
  /// it loads. [markUnlocked] runs when the child has watched the ad.
  Future<void> requestUnlock(LetterItem item) async {
    if (isOpen(item)) {
      emit(state.copyWith(lastUnlocked: item));
      return;
    }
    await RewardedAdService.instance.showToUnlock(
      imageId: item.id,
      onUnlocked: () => markUnlocked(item),
    );
  }

  Future<void> markUnlocked(LetterItem item) async {
    await UnlockedImagesStore.instance.unlock(item.id);
    final ids = {...state.unlockedIds, item.id};
    emit(state.copyWith(unlockedIds: ids, lastUnlocked: item));
  }

  void clearLastUnlocked() => emit(state.copyWith(clearLastUnlocked: true));
}
