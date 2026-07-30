final class OrganizationSummary {
  const OrganizationSummary({required this.id, required this.name});

  factory OrganizationSummary.fromJson(Map<String, dynamic> json) =>
      OrganizationSummary(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  final String id;
  final String name;
}

final class FarmSummary {
  const FarmSummary({
    required this.id,
    required this.organizationId,
    required this.name,
  });

  factory FarmSummary.fromJson(Map<String, dynamic> json) => FarmSummary(
    id: json['id'] as String,
    organizationId: json['organization_id'] as String,
    name: json['name'] as String,
  );

  final String id;
  final String organizationId;
  final String name;
}

final class FoundationUser {
  const FoundationUser({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.hasProfilePhoto = false,
  });

  factory FoundationUser.fromJson(Map<String, dynamic> json) => FoundationUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phone_number'] as String?,
    hasProfilePhoto: json['has_profile_photo'] as bool? ?? false,
  );

  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool hasProfilePhoto;
}

final class AuthSession {
  const AuthSession({
    required this.user,
    required this.organizations,
    required this.farms,
    required this.permissions,
    this.activeOrganizationId,
    this.activeFarmId,
    this.activeMembershipType,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> maps(String key) =>
        (json[key] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    return AuthSession(
      user: FoundationUser.fromJson(json['user'] as Map<String, dynamic>),
      organizations: maps(
        'organizations',
      ).map(OrganizationSummary.fromJson).toList(growable: false),
      farms: maps('farms').map(FarmSummary.fromJson).toList(growable: false),
      permissions: Set<String>.unmodifiable(
        (json['permissions'] as List<dynamic>? ?? const []).cast<String>(),
      ),
      activeOrganizationId: json['active_organization_id'] as String?,
      activeFarmId: json['active_farm_id'] as String?,
      activeMembershipType: json['active_membership_type'] as String?,
    );
  }

  final FoundationUser user;
  final List<OrganizationSummary> organizations;
  final List<FarmSummary> farms;
  final Set<String> permissions;
  final String? activeOrganizationId;
  final String? activeFarmId;
  final String? activeMembershipType;

  OrganizationSummary? get activeOrganization => organizations
      .where((item) => item.id == activeOrganizationId)
      .firstOrNull;
  FarmSummary? get activeFarm =>
      farms.where((item) => item.id == activeFarmId).firstOrNull;

  bool can(String permission) => permissions.contains(permission);
  bool get isPrimaryOwner => activeMembershipType == 'primary_owner';
}
