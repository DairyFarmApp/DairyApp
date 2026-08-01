import 'package:dairycare_mobile/app/theme_controller.dart';
import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/status_indicators.dart';
import 'package:dairycare_mobile/features/account/application/account_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class FoundationShell extends ConsumerStatefulWidget {
  const FoundationShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<FoundationShell> createState() => _FoundationShellState();
}

final class _FoundationShellState extends ConsumerState<FoundationShell> {
  bool _employeesExpanded = false;

  @override
  Widget build(BuildContext context) {
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
          'Farm',
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
      if (session?.can('animal_breeds.view') ?? false)
        const _Destination(
          'Breeds',
          Icons.category_outlined,
          Icons.category_rounded,
          '/animal-breeds',
        ),
      if (session?.can('inventory.view') ?? false)
        const _Destination(
          'Inventory',
          Icons.inventory_2_outlined,
          Icons.inventory_2_rounded,
          '/inventory',
        ),
      if (session?.can('milk.view') ?? false)
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
        relatedPaths: ['/payroll', '/employee-loans'],
        togglesEmployeeSubmenu: true,
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
    const employeeSubdestinations = [
      _Destination(
        'Employee list',
        Icons.badge_outlined,
        Icons.badge_rounded,
        '/employees',
        isSubdestination: true,
        navigationKey: Key('employee_list_menu_action'),
      ),
      _Destination(
        'Salary',
        Icons.payments_outlined,
        Icons.payments_rounded,
        '/payroll',
        isSubdestination: true,
        navigationKey: Key('employee_salary_menu_action'),
      ),
      _Destination(
        'Loans',
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded,
        '/employee-loans',
        isSubdestination: true,
        navigationKey: Key('employee_loans_menu_action'),
      ),
    ];
    final onEmployeeRoute = employeeSubdestinations.any(
      (item) => item.matchesPrimary(location),
    );
    final showEmployeeSubmenu = _employeesExpanded || onEmployeeRoute;
    final compactIndex = _selectedIndex(destinations, location);
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
      body: widget.child,
      bottomNavigationBar: wide
          ? null
          : _CompactNavigation(
              destinations: destinations,
              selectedIndex: compactIndex,
              employeeSubmenuExpanded: showEmployeeSubmenu,
              employeeSubdestinations: employeeSubdestinations,
              selectedPath: location,
              onSelected: (value) =>
                  _selectDestination(context, destinations[value]),
              onEmployeeSubdestinationSelected: (destination) =>
                  context.go(destination.path),
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
                  child: _WideNavigation(
                    destinations: destinations,
                    employeeSubdestinations: employeeSubdestinations,
                    employeeSubmenuExpanded: showEmployeeSubmenu,
                    selectedPath: location,
                    extended: width >= 1080,
                    onSelected: (destination) =>
                        _selectDestination(context, destination),
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

  void _selectDestination(BuildContext context, _Destination destination) {
    if (destination.togglesEmployeeSubmenu) {
      setState(() => _employeesExpanded = !_employeesExpanded);
      return;
    }
    context.go(destination.path);
  }
}

final class _WideNavigation extends StatelessWidget {
  const _WideNavigation({
    required this.destinations,
    required this.employeeSubdestinations,
    required this.employeeSubmenuExpanded,
    required this.selectedPath,
    required this.extended,
    required this.onSelected,
  });

  final List<_Destination> destinations;
  final List<_Destination> employeeSubdestinations;
  final bool employeeSubmenuExpanded;
  final String selectedPath;
  final bool extended;
  final ValueChanged<_Destination> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListView(
      key: const Key('wide_sidebar_navigation'),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
      children: [
        for (final destination in destinations) ...[
          _SidebarDestinationTile(
            destination: destination,
            selected: destination.matches(selectedPath),
            extended: extended,
            employeeSubmenuExpanded: employeeSubmenuExpanded,
            onTap: () => onSelected(destination),
          ),
          if (destination.togglesEmployeeSubmenu)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              reverseDuration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: employeeSubmenuExpanded
                  ? Column(
                      key: const Key('employee_slide_down_menu'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final subdestination in employeeSubdestinations)
                          _SidebarDestinationTile(
                            destination: subdestination,
                            selected: subdestination.matchesPrimary(
                              selectedPath,
                            ),
                            extended: extended,
                            employeeSubmenuExpanded: employeeSubmenuExpanded,
                            onTap: () => onSelected(subdestination),
                          ),
                      ],
                    )
                  : const SizedBox(key: Key('employee_slide_down_menu_closed')),
            ),
        ],
      ],
    ),
  );
}

final class _SidebarDestinationTile extends StatelessWidget {
  const _SidebarDestinationTile({
    required this.destination,
    required this.selected,
    required this.extended,
    required this.employeeSubmenuExpanded,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final bool extended;
  final bool employeeSubmenuExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      key: destination.navigationKey,
      dense: true,
      minTileHeight: destination.isSubdestination ? 46 : 52,
      contentPadding: EdgeInsets.only(
        left: extended ? (destination.isSubdestination ? 34 : 14) : 22,
        right: extended ? 10 : 22,
      ),
      leading: Icon(
        selected ? destination.selectedIcon : destination.icon,
        size: destination.isSubdestination ? 21 : 24,
      ),
      title: extended
          ? Text(
              destination.label,
              style: destination.isSubdestination
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
            )
          : null,
      trailing: extended && destination.togglesEmployeeSubmenu
          ? AnimatedRotation(
              turns: employeeSubmenuExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(Icons.keyboard_arrow_down_rounded),
            )
          : null,
      selected: selected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: onTap,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: destination.isSubdestination ? 2 : 4),
      child: extended ? tile : Tooltip(message: destination.label, child: tile),
    );
  }
}

final class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.employeeSubmenuExpanded,
    required this.employeeSubdestinations,
    required this.selectedPath,
    required this.onSelected,
    required this.onEmployeeSubdestinationSelected,
  });

  final List<_Destination> destinations;
  final int selectedIndex;
  final bool employeeSubmenuExpanded;
  final List<_Destination> employeeSubdestinations;
  final String selectedPath;
  final ValueChanged<int> onSelected;
  final ValueChanged<_Destination> onEmployeeSubdestinationSelected;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
    elevation: 8,
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axisAlignment: 1,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: employeeSubmenuExpanded
                ? DecoratedBox(
                    key: const Key('compact_employee_slide_down_menu'),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLow.withValues(alpha: 0.96),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final destination in employeeSubdestinations)
                          ListTile(
                            key: destination.navigationKey,
                            dense: true,
                            contentPadding: const EdgeInsets.only(
                              left: 34,
                              right: 18,
                            ),
                            leading: Icon(
                              destination.matchesPrimary(selectedPath)
                                  ? destination.selectedIcon
                                  : destination.icon,
                              size: 21,
                            ),
                            title: Text(destination.label),
                            selected: destination.matchesPrimary(selectedPath),
                            onTap: () =>
                                onEmployeeSubdestinationSelected(destination),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(
                    key: Key('compact_employee_slide_down_menu_closed'),
                  ),
          ),
          SizedBox(
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
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
        ],
      ),
    ),
  );
}

final class _Destination {
  const _Destination(
    this.label,
    this.icon,
    this.selectedIcon,
    this.path, {
    this.relatedPaths = const [],
    this.togglesEmployeeSubmenu = false,
    this.isSubdestination = false,
    this.navigationKey,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
  final List<String> relatedPaths;
  final bool togglesEmployeeSubmenu;
  final bool isSubdestination;
  final Key? navigationKey;

  bool matchesPrimary(String location) =>
      location == path || location.startsWith('$path/');

  bool matches(String location) => [
    path,
    ...relatedPaths,
  ].any((item) => location == item || location.startsWith('$item/'));
}

int _selectedIndex(List<_Destination> destinations, String location) {
  final exact = destinations.indexWhere(
    (item) => item.matchesPrimary(location),
  );
  if (exact >= 0) {
    return exact;
  }
  final related = destinations.indexWhere((item) => item.matches(location));
  return related < 0 ? 0 : related;
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
