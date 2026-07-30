import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/account/application/account_providers.dart';
import 'package:dairycare_mobile/features/account/data/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class FamilyManagementScreen extends ConsumerStatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  ConsumerState<FamilyManagementScreen> createState() =>
      _FamilyManagementScreenState();
}

final class _FamilyManagementScreenState
    extends ConsumerState<FamilyManagementScreen> {
  String? _busyAction;

  @override
  Widget build(BuildContext context) {
    final invite = ref.watch(familyInviteProvider);
    final members = ref.watch(familyMembersProvider);
    return SingleChildScrollView(
      child: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              eyebrow: 'Farm access',
              title: 'Family accounts',
              subtitle:
                  'Share one reusable link with trusted family and remove access whenever you need to.',
            ),
            const SizedBox(height: 24),
            invite.when(
              loading: () =>
                  const LoadingStateView(label: 'Loading your invitation…'),
              error: (error, _) => ErrorStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(familyInviteProvider),
              ),
              data: _inviteCard,
            ),
            const SizedBox(height: 18),
            members.when(
              loading: () =>
                  const LoadingStateView(label: 'Loading family accounts…'),
              error: (error, _) => ErrorStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(familyMembersProvider),
              ),
              data: _memberCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inviteCard(FamilyInvite? invite) {
    final enabled = invite?.isEnabled ?? false;
    final link = invite == null ? null : _invitationUrl(invite.token);
    return SectionCard(
      title: 'Family invitation link',
      subtitle: enabled
          ? 'Anyone you trust with this link can create a family account for this farm.'
          : invite == null
          ? 'Create a reusable link for your family.'
          : 'This link is disabled. Generate a new link when you are ready.',
      trailing: Chip(
        avatar: Icon(
          enabled ? Icons.link_rounded : Icons.link_off_rounded,
          size: 18,
        ),
        label: Text(enabled ? 'Active' : 'Disabled'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (enabled && link != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                link,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          if (enabled) const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (enabled && link != null)
                FilledButton.tonalIcon(
                  onPressed: _busyAction == null
                      ? () async {
                          await Clipboard.setData(ClipboardData(text: link));
                          _message('Invitation link copied.');
                        }
                      : null,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy link'),
                ),
              FilledButton.icon(
                onPressed: _busyAction == null ? _rotateInvite : null,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  invite == null ? 'Create link' : 'Generate new link',
                ),
              ),
              if (enabled)
                TextButton.icon(
                  onPressed: _busyAction == null ? _disableInvite : null,
                  icon: const Icon(Icons.link_off_rounded),
                  label: const Text('Disable link'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Generating a new link immediately invalidates the old one. '
            'Existing family accounts stay active until you remove them below.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberCard(List<FamilyMember> members) => SectionCard(
    title: 'Family members',
    subtitle: '${members.where((member) => member.isActive).length} active',
    child: members.isEmpty
        ? const EmptyStateView(
            icon: Icons.family_restroom_rounded,
            title: 'No family accounts yet',
            message:
                'Copy the invitation link above and send it to a trusted family member.',
          )
        : Column(
            children: [
              for (var index = 0; index < members.length; index++) ...[
                _memberTile(members[index]),
                if (index != members.length - 1) const Divider(height: 24),
              ],
            ],
          ),
  );

  Widget _memberTile(FamilyMember member) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      child: Text(
        member.name.isEmpty ? '?' : member.name.characters.first.toUpperCase(),
      ),
    ),
    title: Text(member.name),
    subtitle: Text(
      [
        member.email,
        if (member.phoneNumber?.isNotEmpty ?? false) member.phoneNumber!,
      ].join(' • '),
    ),
    trailing: member.isActive
        ? OutlinedButton.icon(
            onPressed: _busyAction == null ? () => _removeMember(member) : null,
            icon: const Icon(Icons.person_remove_outlined),
            label: const Text('Remove'),
          )
        : FilledButton.tonalIcon(
            onPressed: _busyAction == null
                ? () => _restoreMember(member)
                : null,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Restore'),
          ),
  );

  Future<void> _rotateInvite() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Generate a new invitation link?'),
            content: const Text(
              'The previous link will stop working immediately. Existing family accounts will not be affected.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Generate link'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await _run('invite', () async {
      await ref.read(accountRepositoryProvider).rotateFamilyInvite();
      ref.invalidate(familyInviteProvider);
      _message('New invitation link created.');
    });
  }

  Future<void> _disableInvite() async {
    await _run('invite', () async {
      await ref.read(accountRepositoryProvider).disableFamilyInvite();
      ref.invalidate(familyInviteProvider);
      _message('Invitation link disabled.');
    });
  }

  Future<void> _removeMember(FamilyMember member) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove ${member.name}?'),
            content: const Text(
              'Their current sessions will end immediately and they will lose access to this farm. You can restore the account later.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove access'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await _run(member.id, () async {
      await ref.read(accountRepositoryProvider).removeFamilyMember(member.id);
      ref.invalidate(familyMembersProvider);
      _message('${member.name} was removed.');
    });
  }

  Future<void> _restoreMember(FamilyMember member) async {
    await _run(member.id, () async {
      await ref.read(accountRepositoryProvider).restoreFamilyMember(member.id);
      ref.invalidate(familyMembersProvider);
      _message('${member.name} can access the farm again.');
    });
  }

  Future<void> _run(String action, Future<void> Function() task) async {
    setState(() => _busyAction = action);
    try {
      await task();
    } catch (error) {
      _message(safeErrorMessage(error.toString()), error: true);
    } finally {
      if (mounted) setState(() => _busyAction = null);
    }
  }

  String _invitationUrl(String token) {
    final encoded = Uri.encodeQueryComponent(token);
    final base = Uri.base;
    if (base.scheme == 'http' || base.scheme == 'https') {
      return '${base.origin}${base.path}#/signup?family_invite=$encoded';
    }
    return token;
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
