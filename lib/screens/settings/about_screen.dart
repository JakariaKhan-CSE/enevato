import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.eco,
                color: colorScheme.primary,
                size: 46,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Evacado Tracker',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Version 1.0.0 (1)',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  _AboutRow(
                    title: 'Get Support',
                    trailing: 'support@evacado.app',
                  ),
                  _divider(colorScheme),
                  _AboutRow(
                    title: 'Feature Requests',
                    trailing: '🤘',
                  ),
                  _divider(colorScheme),
                  _AboutRow(
                    title: 'Tell a Friend',
                    trailing: '❤️',
                  ),
                  _divider(colorScheme),
                  _AboutRow(
                    title: 'Privacy Policy',
                    trailingIcon: Icons.chevron_right,
                  ),
                  _divider(colorScheme),
                  _AboutRow(
                    title: 'Licenses',
                    trailingIcon: Icons.chevron_right,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'POWERED BY',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'envato • api',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Copyright © 2025 Evacado',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Designed and built with 💚',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme scheme) {
    return Divider(
      height: 1,
      color: scheme.onSurface.withOpacity(0.08),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String title;
  final String? trailing;
  final IconData? trailingIcon;

  const _AboutRow({
    required this.title,
    this.trailing,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : trailingIcon != null
              ? Icon(
                  trailingIcon,
                  color: colorScheme.onSurface.withOpacity(0.6),
                )
              : null,
    );
  }
}
