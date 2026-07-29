import 'package:dairycare_mobile/app/router.dart';
import 'package:dairycare_mobile/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class DairyCareApp extends ConsumerWidget {
  const DairyCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'DairyCare',
    debugShowCheckedModeBanner: false,
    theme: DairyCareTheme.light,
    darkTheme: DairyCareTheme.dark,
    themeMode: ThemeMode.system,
    routerConfig: ref.watch(routerProvider),
  );
}
