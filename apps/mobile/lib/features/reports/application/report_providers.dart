import 'package:dairycare_mobile/features/reports/data/reports_repository.dart';
import 'package:dairycare_mobile/features/reports/domain/report_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyProductionReportProvider =
    FutureProvider.family<List<AnimalDailyRecord>, DateTime>((ref, date) {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getDailyProduction(date);
});
