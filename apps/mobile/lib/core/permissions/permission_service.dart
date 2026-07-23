import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final canProvider = Provider.family<bool, String>((ref, permission) {
  final session = ref.watch(authControllerProvider).asData?.value;
  return session?.can(permission) ?? false;
});
