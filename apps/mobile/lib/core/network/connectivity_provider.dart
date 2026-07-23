import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) => Connectivity().onConnectivityChanged,
);

final isOfflineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityProvider).value;
  return results != null &&
      (results.isEmpty ||
          results.every((value) => value == ConnectivityResult.none));
});
