import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'music_player.dart';

class SettingsState {
  const SettingsState({this.musicOn = true, this.sfxOn = true});

  final bool musicOn;
  final bool sfxOn;

  SettingsState copyWith({bool? musicOn, bool? sfxOn}) => SettingsState(
        musicOn: musicOn ?? this.musicOn,
        sfxOn: sfxOn ?? this.sfxOn,
      );
}

/// Music and sound-effect switches. Saved on the device and applied at once.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const _musicKey = 'music_on';
  static const _sfxKey = 'sfx_on';

  /// Read the saved values and start the music if it is on. Call once at start-up.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final next = SettingsState(
      musicOn: prefs.getBool(_musicKey) ?? true,
      sfxOn: prefs.getBool(_sfxKey) ?? true,
    );
    emit(next);
    await MusicPlayer.instance.setEnabled(next.musicOn);
  }

  Future<void> setMusic(bool on) async {
    emit(state.copyWith(musicOn: on));
    await MusicPlayer.instance.setEnabled(on);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, on);
  }

  Future<void> setSfx(bool on) async {
    emit(state.copyWith(sfxOn: on));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxKey, on);
  }
}
