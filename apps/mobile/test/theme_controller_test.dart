import 'package:dairycare_mobile/app/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme mode loads and persists system white and dark choices', () async {
    final store = _MemoryThemeStore('light');
    final container = ProviderContainer(
      overrides: [themePreferenceStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(await container.read(themeModeProvider.future), ThemeMode.light);
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    expect(container.read(themeModeProvider).value, ThemeMode.dark);
    expect(store.value, 'dark');
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.system);
    expect(store.value, 'system');
  });
}

final class _MemoryThemeStore implements ThemePreferenceStore {
  _MemoryThemeStore(this.value);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}
