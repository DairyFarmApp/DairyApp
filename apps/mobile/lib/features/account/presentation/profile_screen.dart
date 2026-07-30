import 'dart:typed_data';

import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/account/application/account_providers.dart';
import 'package:dairycare_mobile/features/account/data/account_repository.dart';
import 'package:dairycare_mobile/features/authentication/presentation/login_screen.dart';
import 'package:dairycare_mobile/features/authentication/presentation/signup_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return SingleChildScrollView(
      child: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              eyebrow: 'Account',
              title: 'My profile',
              subtitle:
                  'Keep your personal details and profile picture up to date.',
            ),
            const SizedBox(height: 24),
            profile.when(
              loading: () =>
                  const LoadingStateView(label: 'Loading your profile…'),
              error: (error, _) => ErrorStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(profileProvider),
              ),
              data: (value) =>
                  _ProfileForm(key: ValueKey(value.updatedAt), profile: value),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

final class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final _currentPassword = TextEditingController();
  bool _busy = false;

  bool get _emailChanged =>
      _email.text.trim().toLowerCase() != widget.profile.email.toLowerCase();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _email = TextEditingController(text: widget.profile.email);
    _phone = TextEditingController(text: widget.profile.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _currentPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 840;
      final photo = SectionCard(
        title: 'Profile picture',
        subtitle: 'JPG, PNG, or WebP up to 5 MB.',
        child: Column(
          children: [
            _ProfileAvatar(
              name: widget.profile.name,
              hasPhoto: widget.profile.hasProfilePhoto,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _choosePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(
                    widget.profile.hasProfilePhoto
                        ? 'Replace picture'
                        : 'Add picture',
                  ),
                ),
                if (widget.profile.hasProfilePhoto)
                  TextButton.icon(
                    onPressed: _busy ? null : _removePhoto,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove'),
                  ),
              ],
            ),
          ],
        ),
      );
      final details = SectionCard(
        title: 'Personal details',
        subtitle:
            'Changing your email requires your current password for security.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('profile_name'),
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => validateRequiredName(value, 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('profile_email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: validateEmail,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('profile_phone'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: _emailChanged
                    ? TextInputAction.next
                    : TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: validatePhone,
              ),
              if (_emailChanged) ...[
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('profile_current_password'),
                  controller: _currentPassword,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: validatePassword,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('profile_save'),
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save profile'),
              ),
            ],
          ),
        ),
      );

      if (!wide) {
        return Column(children: [photo, const SizedBox(height: 18), details]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 320, child: photo),
          const SizedBox(width: 18),
          Expanded(child: details),
        ],
      );
    },
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() async {
      await ref
          .read(accountRepositoryProvider)
          .updateProfile(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phoneNumber: _phone.text.trim(),
            currentPassword: _emailChanged ? _currentPassword.text : null,
          );
      await ref.read(authControllerProvider.notifier).reload();
      ref.invalidate(profileProvider);
      _showMessage('Profile updated.');
    });
  }

  Future<void> _choosePhoto() async {
    const group = XTypeGroup(
      label: 'Profile pictures',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      _showMessage('Choose an image smaller than 5 MB.', error: true);
      return;
    }
    await _run(() async {
      await ref
          .read(accountRepositoryProvider)
          .uploadPhoto(bytes: bytes, filename: file.name);
      await ref.read(authControllerProvider.notifier).reload();
      ref.invalidate(profileProvider);
      ref.invalidate(profilePhotoProvider);
      _showMessage('Profile picture updated.');
    });
  }

  Future<void> _removePhoto() async {
    await _run(() async {
      await ref.read(accountRepositoryProvider).deletePhoto();
      await ref.read(authControllerProvider.notifier).reload();
      ref.invalidate(profileProvider);
      ref.invalidate(profilePhotoProvider);
      _showMessage('Profile picture removed.');
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      _showMessage(safeErrorMessage(error.toString()), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}

final class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar({required this.name, required this.hasPhoto});

  final String name;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = hasPhoto ? ref.watch(profilePhotoProvider) : null;
    final imageBytes = bytes?.asData?.value;
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
        image: imageBytes is Uint8List
            ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageBytes == null
          ? Text(
              _initials(name),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

String _initials(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((part) => part.isNotEmpty)
    .take(2)
    .map((part) => part[0].toUpperCase())
    .join();
