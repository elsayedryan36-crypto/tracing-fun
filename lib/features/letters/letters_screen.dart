import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/common/localization/app_language.dart';
import '../../presentation/common/resources/color_manager.dart';
import '../../presentation/common/resources/font_manager.dart';
import '../../presentation/common/resources/routs_manager.dart';
import '../../presentation/common/resources/values_manager.dart';
import '../../presentation/common/state_renderer/state_renderer.dart';
import 'letter_item.dart';
import 'letters_cubit.dart';

/// Grid of letters or numbers. Free items open at once. Locked items show a
/// lock and open after the rewarded ad.
class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key, required this.group});

  final LetterGroup group;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LettersCubit(group)..load(),
      child: BlocListener<LettersCubit, LettersState>(
        listenWhen: (prev, curr) =>
            curr.lastUnlocked != null &&
            prev.lastUnlocked != curr.lastUnlocked,
        listener: (context, state) {
          final item = state.lastUnlocked!;
          final cubit = context.read<LettersCubit>();
          cubit.clearLastUnlocked();
          Navigator.of(context).pushNamed(Routes.tracing, arguments: item);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: tr('back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(_title()),
          ),
          body: BlocBuilder<LettersCubit, LettersState>(
            builder: (context, state) {
              if (state.loading) {
                return StateRenderer(
                  stateRendererType: StateRendererType.fullScreenLoadingState,
                  message: tr('loading'),
                  retryActionFunction: () {},
                );
              }
              if (state.failed) {
                return StateRenderer(
                  stateRendererType: StateRendererType.fullScreenErrorState,
                  message: tr('error_generic'),
                  retryActionFunction: () =>
                      context.read<LettersCubit>().load(),
                );
              }
              return _Grid(items: state.items);
            },
          ),
        ),
      ),
    );
  }

  String _title() {
    switch (group) {
      case LetterGroup.arabic:
        return tr('menu_arabic');
      case LetterGroup.english:
        return tr('menu_english');
      case LetterGroup.numbers:
        return tr('menu_numbers');
    }
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.items});

  final List<LetterItem> items;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LettersCubit>();
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.current,
      builder: (context, _, _) {
        return BlocBuilder<LettersCubit, LettersState>(
          buildWhen: (p, c) => p.unlockedIds != c.unlockedIds,
          builder: (context, state) {
            return GridView.count(
              crossAxisCount: 6,
              padding: EdgeInsets.all(AppPx.p12),
              mainAxisSpacing: AppPx.p8,
              crossAxisSpacing: AppPx.p8,
              children: [
                for (final item in items)
                  _LetterTile(
                    item: item,
                    isOpen: cubit.isOpen(item),
                    onTap: () {
                      if (cubit.isOpen(item)) {
                        Navigator.of(context)
                            .pushNamed(Routes.tracing, arguments: item);
                      } else {
                        cubit.requestUnlock(item);
                      }
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.item,
    required this.isOpen,
    required this.onTap,
  });

  final LetterItem item;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppPx.p12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isOpen ? ColorManager.white : ColorManager.lightGrey,
          borderRadius: BorderRadius.circular(AppPx.p12),
          border: Border.all(color: ColorManager.grey),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              item.glyph,
              style: TextStyle(
                fontFamily: item.group == LetterGroup.arabic
                    ? FontConstants.arabicFont
                    : null,
                fontSize: AppPx.p30,
                fontWeight: FontWeight.w800,
                color: isOpen ? ColorManager.darkPrimary : ColorManager.grey,
              ),
            ),
            if (!isOpen)
              Positioned(
                top: AppPx.p4,
                right: AppPx.p4,
                child: Icon(
                  Icons.lock,
                  size: AppPx.p16,
                  color: ColorManager.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
