import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/status_indicators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class FoundationShell extends ConsumerWidget {
  const FoundationShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final location = GoRouterState.of(context).matchedLocation;
    final destinations = <_Destination>[
      const _Destination('Foundation', Icons.home_outlined, '/home'),
      if (session?.can('farms.view') ?? false)
        const _Destination('Farms', Icons.agriculture_outlined, '/farms'),
      if (session?.can('sheds.view') ?? false)
        const _Destination('Sheds', Icons.warehouse_outlined, '/sheds'),
      const _Destination('Sync', Icons.sync_outlined, '/sync'),
    ];
    final selected = destinations.indexWhere((item) => location == item.path);
    final index = selected < 0 ? 0 : selected;
    final wide = MediaQuery.sizeOf(context).width >= 720;

    final content = Scaffold(
      appBar: AppBar(
        title: Text(session?.activeFarm?.name ?? 'DairyCare'),
        actions: [
          if (wide) const OfflineStatusIndicator(),
          if (wide)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SyncStatusIndicator(),
            ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'farm') context.go('/farms/select');
              if (value == 'organization') context.go('/organizations/select');
              if (value == 'logout') {
                await ref.read(authControllerProvider.notifier).logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'farm', child: Text('Switch farm')),
              PopupMenuItem(
                value: 'organization',
                child: Text('Switch organization'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) =>
                  context.go(destinations[value].path),
              destinations: [
                for (final item in destinations)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
    );

    if (!wide) return content;
    return Row(
      children: [
        NavigationRail(
          selectedIndex: index,
          extended: MediaQuery.sizeOf(context).width >= 1050,
          onDestinationSelected: (value) =>
              context.go(destinations[value].path),
          destinations: [
            for (final item in destinations)
              NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.label),
              ),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: content),
      ],
    );
  }
}

final class _Destination {
  const _Destination(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}
