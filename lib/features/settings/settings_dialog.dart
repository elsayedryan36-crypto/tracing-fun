import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/common/localization/app_language.dart';
import 'settings_cubit.dart';

/// Settings popup: music, sound effects, and language.
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('settings')),
      content: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(tr('music')),
                value: settings.musicOn,
                onChanged: (v) => context.read<SettingsCubit>().setMusic(v),
              ),
              SwitchListTile(
                title: Text(tr('sound_effects')),
                value: settings.sfxOn,
                onChanged: (v) => context.read<SettingsCubit>().setSfx(v),
              ),
              ValueListenableBuilder<String>(
                valueListenable: AppLanguage.current,
                builder: (context, code, _) {
                  return DropdownButton<String>(
                    value: code,
                    items: [
                      for (final option in AppLanguage.options)
                        DropdownMenuItem(
                          value: option.code,
                          child: Text(option.nativeName),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) AppLanguage.select(v);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('close')),
        ),
      ],
    );
  }
}
