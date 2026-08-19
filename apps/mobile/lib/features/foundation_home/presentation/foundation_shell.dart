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
  final GlobalKey<ScaffoldState> _mobileScaffoldKey =
      GlobalKey<ScaffoldState>();
  bool _settingsExpanded = false;

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
      if (session?.can('alerts.view') ?? false)
        const _Destination(
          'Alerts & Reminders',
          Icons.notifications_active_outlined,
          Icons.notifications_active_rounded,
          '/alerts',
        ),
      if (session?.can('milk.view') ?? false)
        const _Destination(
          'Milk Production',
          Icons.water_drop_outlined,
          Icons.water_drop_rounded,
          '/milk',
        ),
      if (session?.can('milk_sales.view') ?? false)
        const _Destination(
          'Milk Sales',
          Icons.point_of_sale_outlined,
          Icons.point_of_sale_rounded,
          '/milk-sales',
          navigationKey: Key('main_milk_sales_menu_action'),
        ),
      if (session?.can('health.view') ?? false)
        const _Destination(
          'Animal Health Guide',
          Icons.health_and_safety_outlined,
          Icons.health_and_safety_rounded,
          '/health-guide',
        ),
      if (session?.can('milk.view') ?? false)
        const _Destination(
          'Milking & Daily Feed',
          Icons.bar_chart_outlined,
          Icons.bar_chart_rounded,
          '/reports/daily-production',
        ),
      if (session?.can('inventory.view') ?? false)
        const _Destination(
          'Stock Usage',
          Icons.assignment_outlined,
          Icons.assignment_rounded,
          '/inventory/indents',
        ),
      if (session?.can('inventory.view') ?? false)
        const _Destination(
          'Feed Analysis',
          Icons.analytics_outlined,
          Icons.analytics_rounded,
          '/feed/analysis',
        ),
      if (session?.can('inventory.view') ?? false)
        const _Destination(
          'Manage Inventory',
          Icons.inventory_2_outlined,
          Icons.inventory_2_rounded,
          '/inventory',
        ),
      if (session?.can('animals.view') ?? false)
        const _Destination(
          'Cattle Management',
          Icons.pets_outlined,
          Icons.pets_rounded,
          '/animals',
        ),
      if (session?.can('visitors.view') ?? false)
        const _Destination(
          'Visitors',
          Icons.badge_outlined,
          Icons.badge_rounded,
          '/visitors',
        ),
      if (session?.can('sheds.view') ?? false)
        const _Destination(
          'Animal Housing',
          Icons.warehouse_outlined,
          Icons.warehouse_rounded,
          '/sheds',
        ),
      if (session?.can('animals.view') ?? false)
        const _Destination(
          'Cattles Sale/Purchase',
          Icons.storefront_outlined,
          Icons.storefront_rounded,
          '/animals/sales-dashboard',
          relatedPaths: ['/animals/purchases/new', '/animals/sales/new'],
        ),
      if (session?.can('customers.view') ?? false)
        const _Destination(
          'Customers',
          Icons.people_alt_outlined,
          Icons.people_alt_rounded,
          '/customers',
          navigationKey: Key('main_customers_menu_action'),
        ),
      if (session?.can('suppliers.view') ?? false)
        const _Destination(
          'Suppliers',
          Icons.local_shipping_outlined,
          Icons.local_shipping_rounded,
          '/suppliers',
          navigationKey: Key('main_suppliers_menu_action'),
        ),
      if (session?.can('purchases.view') ?? false)
        const _Destination(
          'Purchase Orders',
          Icons.shopping_cart_checkout_outlined,
          Icons.shopping_cart_checkout_rounded,
          '/purchases',
          navigationKey: Key('main_purchase_orders_menu_action'),
        ),
      if (session?.can('supplier_invoices.view') ?? false)
        const _Destination(
          'Supplier Invoices',
          Icons.request_quote_outlined,
          Icons.request_quote_rounded,
          '/supplier-invoices',
          navigationKey: Key('main_supplier_invoices_menu_action'),
        ),
      const _Destination(
        'Manage Users',
        Icons.groups_2_outlined,
        Icons.groups_2_rounded,
        '/employees',
        relatedPaths: ['/payroll', '/employee-loans'],
      ),
      if (session?.can('finance.view') ?? false)
        const _Destination(
          'Finance',
          Icons.account_balance_wallet_outlined,
          Icons.account_balance_wallet_rounded,
          '/finance',
          navigationKey: Key('main_finance_menu_action'),
        ),
      const _Destination(
        'Settings',
        Icons.settings_outlined,
        Icons.settings_rounded,
        '/settings', // Dummy path, used to toggle submenu
        togglesSettingsSubmenu: true,
      ),
    ];
    final settingsSubdestinations = [
      if (session?.can('farms.view') ?? false)
        const _Destination(
          'Farm',
          Icons.agriculture_outlined,
          Icons.agriculture_rounded,
          '/farms',
          isSubdestination: true,
          navigationKey: Key('settings_farm_menu_action'),
        ),
      if (session?.can('animal_breeds.view') ?? false)
        const _Destination(
          'Breeds',
          Icons.category_outlined,
          Icons.category_rounded,
          '/animal-breeds',
          isSubdestination: true,
          navigationKey: Key('settings_breeds_menu_action'),
        ),
      const _Destination(
        'Sync Diagnostics',
        Icons.sync_outlined,
        Icons.sync_rounded,
        '/sync',
        isSubdestination: true,
        navigationKey: Key('settings_sync_menu_action'),
      ),
    ];
    final onSettingsRoute = settingsSubdestinations.any(
      (item) => item.matchesPrimary(location),
    );
    final showSettingsSubmenu = _settingsExpanded || onSettingsRoute;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 760;
    final profilePhoto = session?.user.hasProfilePhoto ?? false
        ? ref.watch(profilePhotoProvider).asData?.value
        : null;
    final selectedTheme =
        ref.watch(themeModeProvider).value ?? ThemeMode.system;

    final content = Scaffold(
      key: wide ? null : _mobileScaffoldKey,
      drawer: wide
          ? null
          : Drawer(
              width: 300,
              backgroundColor: Theme.of(
                context,
              ).navigationRailTheme.backgroundColor,
              child: SafeArea(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
                      child: Row(
                        children: [
                          AppMark(size: 42, inverted: true),
                          SizedBox(width: 12),
                          Text(
                            'DairyCare',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    Expanded(
                      child: _WideNavigation(
                        destinations: destinations,
                        settingsSubdestinations: settingsSubdestinations,
                        settingsSubmenuExpanded: showSettingsSubmenu,
                        selectedPath: location,
                        extended: true,
                        onSelected: (destination) {
                          if (destination.togglesSettingsSubmenu) {
                            _selectDestination(context, destination);
                            return;
                          }
                          Navigator.of(context).pop();
                          _selectDestination(context, destination);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        toolbarHeight: 64,
        titleSpacing: wide ? 24 : 16,
        leadingWidth: wide ? null : 64,
        leading: wide
            ? null
            : IconButton(
                key: const Key('mobile_menu_button'),
                tooltip: 'Open sections menu',
                onPressed: () => _mobileScaffoldKey.currentState?.openDrawer(),
                icon: const AppMark(size: 38),
              ),
        title: Row(
          children: [
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
    );

    if (!wide) return content;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: width >= 1080 ? 250 : 80,
            color: Theme.of(context).navigationRailTheme.backgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    width >= 1080 ? 20 : 12,
                    24,
                    width >= 1080 ? 20 : 12,
                    24,
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
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                    settingsSubdestinations: settingsSubdestinations,
                    settingsSubmenuExpanded: showSettingsSubmenu,
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
    if (destination.togglesSettingsSubmenu) {
      setState(() => _settingsExpanded = !_settingsExpanded);
      return;
    }
    context.go(destination.path);
  }
}

final class _WideNavigation extends StatelessWidget {
  const _WideNavigation({
    required this.destinations,
    required this.settingsSubdestinations,
    required this.settingsSubmenuExpanded,
    required this.selectedPath,
    required this.extended,
    required this.onSelected,
  });

  final List<_Destination> destinations;
  final List<_Destination> settingsSubdestinations;
  final bool settingsSubmenuExpanded;
  final String selectedPath;
  final bool extended;
  final ValueChanged<_Destination> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListView(
      key: const Key('wide_sidebar_navigation'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      children: [
        for (final destination in destinations) ...[
          _SidebarDestinationTile(
            destination: destination,
            selected: destination.matches(selectedPath),
            extended: extended,
            settingsSubmenuExpanded: settingsSubmenuExpanded,
            onTap: () => onSelected(destination),
          ),
          if (destination.togglesSettingsSubmenu)
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
              child: settingsSubmenuExpanded
                  ? Column(
                      key: const Key('settings_slide_down_menu'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final subdestination in settingsSubdestinations)
                          _SidebarDestinationTile(
                            destination: subdestination,
                            selected: subdestination.matchesPrimary(
                              selectedPath,
                            ),
                            extended: extended,
                            settingsSubmenuExpanded: settingsSubmenuExpanded,
                            onTap: () => onSelected(subdestination),
                          ),
                      ],
                    )
                  : const SizedBox(key: Key('settings_slide_down_menu_closed')),
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
    required this.settingsSubmenuExpanded,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final bool extended;
  final bool settingsSubmenuExpanded;
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
                  ? Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70)
                  : Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.white70,
                    ),
            )
          : null,
      trailing: extended && destination.togglesSettingsSubmenu
          ? AnimatedRotation(
              turns: settingsSubmenuExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: selected ? Colors.white : Colors.white70,
              ),
            )
          : null,
      selected: selected,
      iconColor: Colors.white70,
      selectedColor: Colors.white,
      selectedTileColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: destination.isSubdestination ? 2 : 4),
      child: extended ? tile : Tooltip(message: destination.label, child: tile),
    );
  }
}

final class _Destination {
  const _Destination(
    this.label,
    this.icon,
    this.selectedIcon,
    this.path, {
    this.relatedPaths = const [],
    this.togglesSettingsSubmenu = false,
    this.isSubdestination = false,
    this.navigationKey,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
  final List<String> relatedPaths;
  final bool togglesSettingsSubmenu;
  final bool isSubdestination;
  final Key? navigationKey;

  bool matchesPrimary(String location) =>
      location == path || location.startsWith('$path/');

  bool matches(String location) => [
    path,
    ...relatedPaths,
  ].any((item) => location == item || location.startsWith('$item/'));
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
