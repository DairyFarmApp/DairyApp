import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:flutter/material.dart';

final class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GlassBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return SafeArea(
            child: wide
                ? Row(
                    children: [
                      const Expanded(flex: 11, child: _AuthBrandPanel()),
                      Expanded(
                        flex: 9,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(48),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      const Positioned.fill(child: _AuthMobileBackdrop()),
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    ),
  );
}

final class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

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
                  'Your family. Your farm. One clear view.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Create your private dairy workspace, invite trusted family, '
                  'and keep every animal record under your control.',
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
                      label: 'Private farm',
                    ),
                    _BrandFeature(
                      icon: Icons.family_restroom_rounded,
                      label: 'Family access',
                    ),
                    _BrandFeature(
                      icon: Icons.sync_rounded,
                      label: 'Offline-ready',
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

final class _AuthMobileBackdrop extends StatelessWidget {
  const _AuthMobileBackdrop();

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
