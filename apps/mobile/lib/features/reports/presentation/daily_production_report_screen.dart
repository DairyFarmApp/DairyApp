import 'dart:convert';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/reports/application/report_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';

final class DailyProductionReportScreen extends ConsumerStatefulWidget {
  const DailyProductionReportScreen({super.key});

  @override
  ConsumerState<DailyProductionReportScreen> createState() =>
      _DailyProductionReportScreenState();
}

class _DailyProductionReportScreenState
    extends ConsumerState<DailyProductionReportScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _exportCsv(List records) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Animal Number,Name,Date,Total Feed (kg),Total Milk (Liters)',
    );
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final record in records) {
      final name = record.animalName ?? '';
      final date = dateFormat.format(record.date);
      buffer.writeln(
        '${record.animalNumber},$name,$date,${record.totalFeedKg},${record.totalMilkLitres}',
      );
    }

    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    final filename =
        'daily_production_report_${dateFormat.format(_selectedDate)}.csv';

    SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: filename, mimeType: 'text/csv')],
        text: 'Daily Production Report for ${dateFormat.format(_selectedDate)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(dailyProductionReportProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milking & Daily Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export CSV',
            onPressed: reportAsync.asData?.value != null
                ? () => _exportCsv(reportAsync.requireValue)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Records for: ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Change Date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: reportAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const EmptyStateView(
                    message: 'No records found for this date.',
                  );
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(record.animalNumber)),
                        title: Text(
                          record.animalName ?? 'Animal ${record.animalNumber}',
                        ),
                        subtitle: Text(
                          'Feed: ${record.totalFeedKg} kg  |  Milk: ${record.totalMilkLitres} L',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                        ),
                        onTap: () =>
                            context.push('/animals/${record.animalId}'),
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => ErrorStateView(
                message: err.toString(),
                onRetry: () => ref.invalidate(
                  dailyProductionReportProvider(_selectedDate),
                ),
              ),
              loading: () => const LoadingStateView(),
            ),
          ),
        ],
      ),
    );
  }
}
