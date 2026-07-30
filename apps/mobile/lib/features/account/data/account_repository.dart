import 'dart:typed_data';

import 'package:dairycare_mobile/core/api/api_client.dart';

final class AccountRepository {
  const AccountRepository(this._api);

  final ApiClient _api;

  Future<UserProfile> profile() async {
    final body = await _api.getJson('/auth/profile');
    return UserProfile.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? currentPassword,
  }) async {
    final body = await _api.patchJson(
      '/auth/profile',
      data: {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        if (currentPassword != null && currentPassword.isNotEmpty)
          'current_password': currentPassword,
      },
    );
    return UserProfile.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<UserProfile> uploadPhoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final body = await _api.postMultipart(
      '/auth/profile/photo',
      fields: const {},
      fileField: 'photo',
      bytes: bytes,
      filename: filename,
    );
    return UserProfile.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<UserProfile> deletePhoto() async {
    final body = await _api.deleteJson('/auth/profile/photo');
    return UserProfile.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Uint8List> profilePhoto() => _api.getBytes('/auth/profile/photo');

  Future<List<FamilyMember>> familyMembers() async {
    final body = await _api.getJson('/family-members');
    return (body['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(FamilyMember.fromJson)
        .toList(growable: false);
  }

  Future<FamilyInvite?> familyInvite() async {
    final body = await _api.getJson('/family-invite');
    final raw = body['data'];
    return raw is Map<String, dynamic> ? FamilyInvite.fromJson(raw) : null;
  }

  Future<FamilyInvite> rotateFamilyInvite() async {
    final body = await _api.postJson('/family-invite');
    return FamilyInvite.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> disableFamilyInvite() => _api.delete('/family-invite');

  Future<void> removeFamilyMember(String membershipId) =>
      _api.delete('/family-members/$membershipId');

  Future<void> restoreFamilyMember(String membershipId) async {
    await _api.postJson('/family-members/$membershipId/restore');
  }
}

final class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.hasProfilePhoto,
    this.phoneNumber,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phone_number'] as String?,
    hasProfilePhoto: json['has_profile_photo'] as bool? ?? false,
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );

  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool hasProfilePhoto;
  final DateTime? updatedAt;
}

final class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.hasProfilePhoto,
    this.phoneNumber,
    this.joinedAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phone_number'] as String?,
    status: json['status'] as String,
    hasProfilePhoto: json['has_profile_photo'] as bool? ?? false,
    joinedAt: DateTime.tryParse(json['joined_at'] as String? ?? ''),
  );

  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String status;
  final bool hasProfilePhoto;
  final DateTime? joinedAt;

  bool get isActive => status == 'active';
}

final class FamilyInvite {
  const FamilyInvite({
    required this.id,
    required this.farmId,
    required this.token,
    required this.isEnabled,
    required this.generation,
    this.updatedAt,
  });

  factory FamilyInvite.fromJson(Map<String, dynamic> json) => FamilyInvite(
    id: json['id'] as String,
    farmId: json['farm_id'] as String,
    token: json['invitation_token'] as String,
    isEnabled: json['is_enabled'] as bool? ?? false,
    generation: json['generation'] as int,
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );

  final String id;
  final String farmId;
  final String token;
  final bool isEnabled;
  final int generation;
  final DateTime? updatedAt;
}
