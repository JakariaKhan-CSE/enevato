import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/screens/auth/preload_screen.dart';
import 'package:myenvato/screens/home/bottom_nav_screen.dart';
import 'package:myenvato/widget/loading_shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Obx(() {
        if (authController.isBusy.value) {
          return const LoadingShimmer();
        }

        if (authController.accessToken.isEmpty) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.background,
                  colorScheme.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.eco,
                      color: colorScheme.secondary,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Evacado Tracker',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Track your Envato earnings, sales, and account details in one place.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _FeatureRow(
                            label: 'Account Information',
                            color: colorScheme.primary,
                          ),
                          const Divider(),
                          _FeatureRow(
                            label: 'Portfolio Items',
                            color: colorScheme.primary,
                          ),
                          const Divider(),
                          _FeatureRow(
                            label: 'Statements',
                            color: colorScheme.primary,
                          ),
                          const Divider(),
                          _FeatureRow(
                            label: 'Sales Insights',
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await authController.enableDemo();
                      if (context.mounted) {
                        Get.offAll(() => const BottomNavScreen());
                      }
                    },
                    child: const Text('Try demo account'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: authController.initiateLogin,
                      child: const Text('Log in with Envato'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'This app is powered by the Envato API and does not store your login details.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          _routeAfterLogin();
        });

        final account = authController.userAccount.value;
        if (account == null) {
          return const LoadingShimmer();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.secondary.withOpacity(0.2),
                  child: Icon(Icons.person, color: colorScheme.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    account['username'] ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: authController.signOut,
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign out',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${account['email'] ?? 'Unknown'}'),
                    const SizedBox(height: 8),
                    Text('Balance: ${account['balance'] ?? 'Unknown'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Raw account data',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(account),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }),
    );
  }
}

Future<void> _routeAfterLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final preloadDone = prefs.getBool('preload_completed') ?? false;
  if (preloadDone) {
    if (Get.currentRoute != '/BottomNavScreen') {
      Get.offAll(() => BottomNavScreen());
    }
  } else {
    if (Get.currentRoute != '/PreloadScreen') {
      Get.offAll(() => const PreloadScreen());
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final Color color;

  const _FeatureRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
