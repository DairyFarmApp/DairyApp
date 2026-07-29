import 'package:dairycare_mobile/core/auth/auth_controller.dart';
import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final form = _LoginForm(
      formKey: _formKey,
      email: _email,
      password: _password,
      showPassword: _showPassword,
      onTogglePassword: () => setState(() => _showPassword = !_showPassword),
      auth: auth,
      onSubmit: _submit,
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return SafeArea(
            child: wide
                ? Row(
                    children: [
                      const Expanded(flex: 11, child: _LoginBrandPanel()),
                      Expanded(
                        flex: 9,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(48),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: form,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      const Positioned.fill(child: _MobileLoginBackdrop()),
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: form,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(email: _email.text.trim(), password: _password.text);
  }
}

final class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.showPassword,
    required this.onTogglePassword,
    required this.auth,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final AsyncValue<Object?> auth;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  AppMark(size: 48),
                  SizedBox(width: 14),
                  Text(
                    'DairyCare',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your farms, animals, and daily work.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                key: const Key('login_email'),
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('login_password'),
                controller: password,
                obscureText: !showPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: showPassword ? 'Hide password' : 'Show password',
                    onPressed: onTogglePassword,
                    icon: Icon(
                      showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: validatePassword,
              ),
              if (auth.hasError) ...[
                const SizedBox(height: 16),
                Container(
                  key: const Key('login_error'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          auth.error.toString(),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('login_submit'),
                onPressed: auth.isLoading ? null : onSubmit,
                icon: auth.isLoading
                    ? const SizedBox.square(
                        dimension: 19,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(auth.isLoading ? 'Signing in…' : 'Sign in'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

final class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(56),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B3D32), Color(0xFF1E7058), Color(0xFF4B9568)],
      ),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Stack(
      children: [
        const Positioned(
          right: -80,
          top: -80,
          child: _Glow(size: 300, opacity: 0.08),
        ),
        const Positioned(
          left: -120,
          bottom: -140,
          child: _Glow(size: 380, opacity: 0.06),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppMark(size: 64, inverted: true),
                const SizedBox(height: 32),
                Text(
                  'Run your farm with clarity.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Secure animal records, controlled movements, weight '
                  'history, and reliable farm data—available wherever the '
                  'day takes you.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 38),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _BrandFeature(
                      icon: Icons.verified_user_outlined,
                      label: 'Secure access',
                    ),
                    _BrandFeature(
                      icon: Icons.sync_rounded,
                      label: 'Offline-ready',
                    ),
                    _BrandFeature(
                      icon: Icons.devices_outlined,
                      label: 'Responsive',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

final class _MobileLoginBackdrop extends StatelessWidget {
  const _MobileLoginBackdrop();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.primaryContainer,
          Theme.of(context).scaffoldBackgroundColor,
        ],
      ),
    ),
  );
}

final class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      shape: BoxShape.circle,
    ),
  );
}

final class _BrandFeature extends StatelessWidget {
  const _BrandFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required.';
  return null;
}
