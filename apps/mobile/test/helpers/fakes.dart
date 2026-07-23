import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/auth/session_models.dart';
import 'package:dairycare_mobile/core/storage/secure_session_store.dart';
import 'package:dairycare_mobile/core/sync/sync_controller.dart';
import 'package:dairycare_mobile/core/sync/sync_models.dart';

AuthSession foundationSession({Set<String> permissions = const {}}) =>
    AuthSession(
      user: const FoundationUser(
        id: '018f0000-0000-7000-8000-000000000001',
        name: 'Ayesha Khan',
        email: 'owner@example.test',
      ),
      organizations: const [
        OrganizationSummary(
          id: '018f0000-0000-7000-8000-000000000010',
          name: 'Green Valley Dairy',
        ),
      ],
      farms: const [
        FarmSummary(
          id: '018f0000-0000-7000-8000-000000000020',
          organizationId: '018f0000-0000-7000-8000-000000000010',
          name: 'North Farm',
        ),
      ],
      permissions: permissions,
      activeOrganizationId: '018f0000-0000-7000-8000-000000000010',
      activeFarmId: '018f0000-0000-7000-8000-000000000020',
    );

class FakeAuthController extends AuthController {
  static AuthSession? session;

  @override
  Future<AuthSession?> build() async => session;
}

class FakeSyncController extends SyncController {
  static SyncStatus status = const SyncStatus();

  @override
  SyncStatus build() => status;
}

final class MemorySessionStore implements SessionStore {
  String? accessToken;
  String? renewalCredential;

  @override
  Future<void> clear() async {
    accessToken = null;
    renewalCredential = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRenewalCredential() async => renewalCredential;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String renewalCredential,
  }) async {
    this.accessToken = accessToken;
    this.renewalCredential = renewalCredential;
  }
}
