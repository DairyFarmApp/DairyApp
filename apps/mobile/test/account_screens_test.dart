import 'package:dairycare_mobile/features/account/application/account_providers.dart';
import 'package:dairycare_mobile/features/account/data/account_repository.dart';
import 'package:dairycare_mobile/features/account/presentation/family_management_screen.dart';
import 'package:dairycare_mobile/features/account/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'profile screen exposes editable owner fields and picture action',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(
              (ref) async => const UserProfile(
                id: 'user-1',
                name: 'Tayyab Saleem',
                email: 'owner@example.test',
                phoneNumber: '+92 300 1234567',
                hasProfilePhoto: false,
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_name')), findsOneWidget);
      expect(find.byKey(const Key('profile_email')), findsOneWidget);
      expect(find.byKey(const Key('profile_phone')), findsOneWidget);
      expect(find.text('Add picture'), findsOneWidget);
    },
  );

  testWidgets(
    'family screen distinguishes reusable link and removable access',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyInviteProvider.overrideWith(
              (ref) async => const FamilyInvite(
                id: 'invite-1',
                farmId: 'farm-1',
                token: 'invite.secret',
                isEnabled: true,
                generation: 1,
              ),
            ),
            familyMembersProvider.overrideWith(
              (ref) async => const [
                FamilyMember(
                  id: 'membership-1',
                  name: 'Fatima Saleem',
                  email: 'fatima@example.test',
                  status: 'active',
                  hasProfilePhoto: false,
                ),
                FamilyMember(
                  id: 'membership-2',
                  name: 'Hamza Saleem',
                  email: 'hamza@example.test',
                  status: 'removed',
                  hasProfilePhoto: false,
                ),
              ],
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: FamilyManagementScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Copy link'), findsOneWidget);
      expect(find.text('Generate new link'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
    },
  );
}
