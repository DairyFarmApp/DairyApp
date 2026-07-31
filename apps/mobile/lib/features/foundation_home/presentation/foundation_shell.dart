import 'package:dairycare_mobile/app/theme_controller.dart';
import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/status_indicators.dart';
import 'package:dairycare_mobile/features/account/application/account_providers.dart';
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
      const _Destination(
        'Dashboard',
        Icons.dashboard_outlined,
        Icons.dashboard_rounded,
        '/home',
      ),
      if (session?.can('farms.view') ?? false)
        const _Destination(
          'Farms',
          Icons.agriculture_outlined,
          Icons.agriculture_rounded,
          '/farms',
        ),
      if (session?.can('sheds.view') ?? false)
        const _Destination(
          'Sheds',
          Icons.warehouse_outlined,
          Icons.warehouse_rounded,
          '/sheds',
        ),
      if (session?.can('animals.view') ?? false)
        const _Destination(
          'Animals',
          Icons.pets_outlined,
          Icons.pets_rounded,
          '/animals',
        ),
      if (session?.can('inventory.view') ?? false)
        const _Destination(
          'Inventory',
          Icons.inventory_2_outlined,
          Icons.inventory_2_rounded,
          '/inventory',
        ),
      const _Destination(
        'Milk Production',
        Icons.water_drop_outlined,
        Icons.water_drop_rounded,
        '/milk',
      ),
      const _Destination(
        'Employees',
        Icons.groups_2_outlined,
        Icons.groups_2_rounded,
        '/employees',
      ),
      const _Destination(
        'Salary',
        Icons.payments_outlined,
        Icons.payments_rounded,
        '/payroll',
      ),
      const _Destination(
        'Loans',
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded,
        '/employee-loans',
      ),
      const _Destination(
        'Finance',
        Icons.query_stats_outlined,
        Icons.query_stats_rounded,
        '/finance',
      ),
      const _Destination(
        'Sync',
        Icons.sync_outlined,
        Icons.sync_rounded,
        '/sync',
      ),
    ];
    final selected = destinations.indexWhere(
      (item) => location == item.path || location.startsWith('${item.path}/'),
    );
    final index = selected < 0 ? 0 : selected;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 760;
    final profilePhoto = session?.user.hasProfilePhoto ?? false
        ? ref.watch(profilePhotoProvider).asData?.value
        : null;
    final selectedTheme =
        ref.watch(themeModeProvider).value ?? ThemeMode.system;

    final content = Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: wide ? 24 : 16,
        title: Row(
          children: [
            if (!wide) ...[const AppMark(size: 38), const SizedBox(width: 12)],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session?.activeFarm?.name ?? 'DairyCare',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (session?.activeOrganization != null)
                    Text(
                      session!.activeOrganization!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (wide) const OfflineStatusIndicator(),
          if (wide)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SyncStatusIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              tooltip: 'Account and farm options',
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: profilePhoto == null
                    ? null
                    : MemoryImage(profilePhoto),
                child: profilePhoto == null
                    ? Text(
                        _initials(session?.user.name),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              onSelected: (value) async {
                if (value == 'profile' && context.mounted) {
                  context.go('/profile');
                }
                if (value == 'family' && context.mounted) {
                  context.go('/family');
                }
                if (value == 'farm' && context.mounted) {
                  context.go('/farms/select');
                }
                if (value == 'organization' && context.mounted) {
                  context.go('/organizations/select');
                }
                if (value.startsWith('theme:')) {
                  final mode = switch (value) {
                    'theme:light' => ThemeMode.light,
                    'theme:dark' => ThemeMode.dark,
                    _ => ThemeMode.system,
                  };
                  await ref.read(themeModeProvider.notifier).setMode(mode);
                }
                if (value == 'logout') {
                  await ref.read(authControllerProvider.notifier).logout();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session?.user.name ?? 'DairyCare user',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        session?.user.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline_rounded),
                    title: Text('My profile'),
                  ),
                ),
                if (session?.isPrimaryOwner ?? false)
                  const PopupMenuItem(
                    value: 'family',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.family_restroom_rounded),
                      title: Text('Family accounts'),
                    ),
                  ),
                if ((session?.farms.length ?? 0) > 1)
                  const PopupMenuItem(
                    value: 'farm',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.agriculture_outlined),
                      title: Text('Switch farm'),
                    ),
                  ),
                if ((session?.organizations.length ?? 0) > 1)
                  const PopupMenuItem(
                    value: 'organization',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.business_outlined),
                      title: Text('Switch organization'),
                    ),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'theme:system',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      selectedTheme == ThemeMode.system
                          ? Icons.check_circle_rounded
                          : Icons.brightness_auto_outlined,
                    ),
                    title: const Text('System theme'),
                  ),
                ),
                PopupMenuItem(
                  value: 'theme:light',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      selectedTheme == ThemeMode.light
                          ? Icons.check_circle_rounded
                          : Icons.light_mode_outlined,
                    ),
                    title: const Text('White theme'),
                  ),
                ),
                PopupMenuItem(
                  value: 'theme:dark',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      selectedTheme == ThemeMode.dark
                          ? Icons.check_circle_rounded
                          : Icons.dark_mode_outlined,
                    ),
                    title: const Text('Dark theme'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout_rounded),
                    title: Text('Sign out'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: wide
          ? null
          : _CompactNavigation(
              destinations: destinations,
              selectedIndex: index,
              onSelected: (value) => context.go(destinations[value].path),
            ),
    );

    if (!wide) return GlassBackground(child: content);
    return GlassBackground(
      child: Row(
        children: [
          Container(
            width: width >= 1080 ? 224 : 96,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    width >= 1080 ? 20 : 12,
                    18,
                    width >= 1080 ? 20 : 12,
                    14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppMark(size: 42),
                      if (width >= 1080) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'DairyCare',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: NavigationRail(
                    selectedIndex: index,
                    extended: width >= 1080,
                    groupAlignment: -0.82,
                    onDestinationSelected: (value) =>
                        context.go(destinations[value].path),
                    destinations: [
                      for (final item in destinations)
                        NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
    );
  }
}

final class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_Destination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
    elevation: 8,
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 72,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                SizedBox(
                  width: 92,
                  child: InkWell(
                    onTap: () => onSelected(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index == selectedIndex
                              ? destinations[index].selectedIcon
                              : destinations[index].icon,
                          color: index == selectedIndex
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          destinations[index].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: index == selectedIndex
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontWeight: index == selectedIndex
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

final class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon, this.path);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

String _initials(String? name) {
  final words = name
      ?.trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words == null || words.isEmpty) return 'DC';
  return words.take(2).map((word) => word[0].toUpperCase()).join();
}
