import 'package:dairycare_mobile/core/providers.dart';
import 'package:dairycare_mobile/features/account/data/account_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(apiClientProvider)),
);

final profileProvider = FutureProvider.autoDispose<UserProfile>(
  (ref) => ref.watch(accountRepositoryProvider).profile(),
);

final profilePhotoProvider = FutureProvider.autoDispose((ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (!profile.hasProfilePhoto) return null;
  return ref.watch(accountRepositoryProvider).profilePhoto();
});

final familyMembersProvider = FutureProvider.autoDispose<List<FamilyMember>>(
  (ref) => ref.watch(accountRepositoryProvider).familyMembers(),
);

final familyInviteProvider = FutureProvider.autoDispose<FamilyInvite?>(
  (ref) => ref.watch(accountRepositoryProvider).familyInvite(),
);
