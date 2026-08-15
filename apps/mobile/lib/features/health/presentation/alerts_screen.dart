import 'package:dairycare_mobile/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final alertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final body = await ref.watch(apiClientProvider).getJson('/alerts');
  return (body['data'] as List).cast<Map<String, dynamic>>();
});

final class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts & reminders / Yaad dehani')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(alertsProvider.future),
        child: alerts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(children: [ListTile(title: Text('$e'))]),
          data: (items) => items.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No active alerts / Koi active yaad dehani nahi',
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    final high = item['severity'] == 'high';
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          high
                              ? Icons.error_outline
                              : Icons.notifications_active_outlined,
                          color: high ? Colors.red : null,
                        ),
                        title: Text(
                          '${item['title']} / ${item['title_roman_urdu'] ?? ''}',
                        ),
                        subtitle: Text(
                          '${item['description']}\n${item['description_roman_urdu'] ?? ''}\nDue: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(item['due_at'] as String).toLocal())}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            await ref
                                .read(apiClientProvider)
                                .patchJson(
                                  '/alerts/${item['id']}',
                                  data: {'action': action},
                                );
                            ref.invalidate(alertsProvider);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'read',
                              child: Text('Mark read'),
                            ),
                            PopupMenuItem(
                              value: 'resolve',
                              child: Text('Resolve / Mukammal'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
