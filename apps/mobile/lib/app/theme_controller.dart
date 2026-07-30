import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class ThemePreferenceStore {
  Future<String?> read();
  Future<void> write(String value);
}

final class SecureThemePreferenceStore implements ThemePreferenceStore {
  SecureThemePreferenceStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'appearance.theme_mode';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}

final themePreferenceStoreProvider = Provider<ThemePreferenceStore>(
  (_) => SecureThemePreferenceStore(),
);

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

final class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final stored = await ref.watch(themePreferenceStoreProvider).read();
    return _decode(stored);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref.read(themePreferenceStoreProvider).write(mode.name);
  }

  ThemeMode _decode(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
