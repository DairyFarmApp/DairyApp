import 'dart:typed_data';

import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/account/data/account_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<RequestOptions> requests;
  late AccountRepository repository;

  setUp(() {
    requests = [];
    repository = AccountRepository(_api(requests));
  });

  test(
    'profile details and photo upload use authenticated account endpoints',
    () async {
      final profile = await repository.profile();
      final updated = await repository.updateProfile(
        name: 'Tayyab Saleem',
        email: 'tayyab@example.test',
        phoneNumber: '+92 300 1234567',
        currentPassword: 'Current-Pass-2026',
      );
      await repository.uploadPhoto(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'owner.png',
      );

      expect(profile.name, 'Tayyab Saleem');
      expect(updated.phoneNumber, '+92 300 1234567');
      expect(
        requests.map((item) => '${item.method} ${item.path}'),
        containsAll([
          'GET /auth/profile',
          'PATCH /auth/profile',
          'POST /auth/profile/photo',
        ]),
      );
      final patch = requests.firstWhere((item) => item.method == 'PATCH');
      expect(
        (patch.data! as Map<String, dynamic>)['current_password'],
        'Current-Pass-2026',
      );
    },
  );

  test(
    'family link and membership actions use bounded owner endpoints',
    () async {
      final invite = await repository.familyInvite();
      final members = await repository.familyMembers();
      await repository.removeFamilyMember('membership-1');
      await repository.restoreFamilyMember('membership-1');

      expect(invite?.generation, 2);
      expect(members.single.name, 'Fatima Saleem');
      expect(
        requests.map((item) => '${item.method} ${item.path}'),
        containsAll([
          'GET /family-invite',
          'GET /family-members',
          'DELETE /family-members/membership-1',
          'POST /family-members/membership-1/restore',
        ]),
      );
    },
  );
}

ApiClient _api(List<RequestOptions> requests) {
  final dio = Dio();
  final api = ApiClient(
    config: EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: Uri.parse('http://example.test/api/v1'),
    ),
    readAccessToken: () async => 'token',
    dio: dio,
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        Object data;
        if (options.path == '/family-members') {
          data = {
            'data': [
              {
                'id': 'membership-1',
                'name': 'Fatima Saleem',
                'email': 'fatima@example.test',
                'phone_number': null,
                'status': 'active',
                'has_profile_photo': false,
                'joined_at': '2026-07-29T12:00:00Z',
              },
            ],
          };
        } else if (options.path == '/family-invite') {
          data = {
            'data': {
              'id': 'invite-1',
              'farm_id': 'farm-1',
              'invitation_token': 'invite.secret',
              'is_enabled': true,
              'generation': 2,
              'updated_at': '2026-07-29T12:00:00Z',
            },
          };
        } else if (options.path.startsWith('/auth/profile')) {
          data = {
            'data': {
              'id': 'user-1',
              'name': 'Tayyab Saleem',
              'email': 'tayyab@example.test',
              'phone_number': '+92 300 1234567',
              'has_profile_photo': options.method == 'POST',
              'updated_at': '2026-07-29T12:00:00Z',
            },
          };
        } else {
          data = {'data': <String, Object>{}};
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: 200,
            data: data,
          ),
        );
      },
    ),
  );
  return api;
}
