import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/auth/auth_repository.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/core/widgets/async_state_view.dart';
import 'package:dairycare_mobile/features/authentication/presentation/auth_page_scaffold.dart';
import 'package:dairycare_mobile/features/authentication/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, this.familyInvitationToken});

  final String? familyInvitationToken;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

final class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _farmName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  late final Future<FamilyInvitePreview>? _invitePreview;
  bool _showPassword = false;

  bool get _isFamily => widget.familyInvitationToken?.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    _invitePreview = _isFamily
        ? ref
              .read(authRepositoryProvider)
              .inspectFamilyInvite(widget.familyInvitationToken!)
        : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _farmName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthPageScaffold(
    child: _isFamily
        ? FutureBuilder<FamilyInvitePreview>(
            future: _invitePreview,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _InvalidInviteCard(
                  message: safeErrorMessage(
                    snapshot.error?.toString() ??
                        'This family invitation is unavailable.',
                  ),
                );
              }
              return _signupCard(snapshot.data);
            },
          )
        : _signupCard(null),
  );

  Widget _signupCard(FamilyInvitePreview? preview) {
    final auth = ref.watch(authControllerProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    AppMark(size: 48),
                    SizedBox(width: 14),
                    Text(
                      'DairyCare',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  _isFamily ? 'Join ${preview?.farmName}' : 'Create your farm',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _isFamily
                      ? 'Create your private family login. You will join this farm with full management access.'
                      : 'Set up one private dairy workspace using your own farm name.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_isFamily) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.family_restroom_rounded),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Invitation verified for ${preview?.farmName}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('signup_name'),
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'Your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => validateRequiredName(value, 'Name'),
                ),
                if (!_isFamily) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('signup_farm_name'),
                    controller: _farmName,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Farm name',
                      hintText: 'For example: Saleem Dairy Farm',
                      prefixIcon: Icon(Icons.agriculture_rounded),
                    ),
                    validator: (value) =>
                        validateRequiredName(value, 'Farm name'),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('signup_email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('signup_phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: const InputDecoration(
                    labelText: 'Phone number (optional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('signup_password'),
                  controller: _password,
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText:
                        'At least 10 characters with letters and numbers',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _showPassword
                          ? 'Hide password'
                          : 'Show password',
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: validateSignupPassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('signup_confirmation'),
                  controller: _confirmation,
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: Icon(Icons.lock_reset_rounded),
                  ),
                  validator: (value) => value != _password.text
                      ? 'Passwords do not match.'
                      : validatePassword(value),
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (auth.hasError) ...[
                  const SizedBox(height: 16),
                  Container(
                    key: const Key('signup_error'),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      safeErrorMessage(auth.error.toString()),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('signup_submit'),
                  onPressed: auth.isLoading ? null : _submit,
                  icon: auth.isLoading
                      ? const SizedBox.square(
                          dimension: 19,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isFamily
                              ? Icons.family_restroom_rounded
                              : Icons.add_business_rounded,
                        ),
                  label: Text(
                    auth.isLoading
                        ? 'Creating account…'
                        : _isFamily
                        ? 'Join family farm'
                        : 'Create farm account',
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: auth.isLoading ? null : () => context.go('/login'),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authControllerProvider.notifier);
    if (_isFamily) {
      await notifier.signupFamily(
        invitationToken: widget.familyInvitationToken!,
        name: _name.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        password: _password.text,
      );
      return;
    }
    await notifier.signupOwner(
      name: _name.text.trim(),
      farmName: _farmName.text.trim(),
      email: _email.text.trim(),
      phoneNumber: _phone.text.trim(),
      password: _password.text,
    );
  }
}

final class _InvalidInviteCard extends StatelessWidget {
  const _InvalidInviteCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link_off_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 18),
          Text(
            'Invitation unavailable',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to sign in'),
          ),
        ],
      ),
    ),
  );
}

String? validateRequiredName(String? value, String label) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$label is required.';
  if (text.length < 2) return '$label is too short.';
  return null;
}

String? validatePhone(String? value) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) return null;
  if (!RegExp(r'^[0-9+(). -]{7,40}$').hasMatch(phone)) {
    return 'Enter a valid phone number.';
  }
  return null;
}

String? validateSignupPassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Password is required.';
  if (password.length < 10) return 'Use at least 10 characters.';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'[0-9]').hasMatch(password)) {
    return 'Include both letters and numbers.';
  }
  return null;
}
