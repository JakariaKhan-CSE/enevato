import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/screens/auth/sign_in_screen.dart';
import 'package:myenvato/screens/home/bottom_nav_screen.dart';
import 'package:myenvato/widget/loading_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  static final Uri _deleteAccountUri =
      Uri.parse('https://help.market.envato.com/hc/en-us/requests/new');
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  late final Worker _accountWorker;

  @override
  void initState() {
    super.initState();
    _accountWorker =
        ever<Map<String, dynamic>>(_userController.userAccount, (account) {
      final username = account['username']?.toString() ?? '';
      if (username.isEmpty) {
        return;
      }
      _userController.fetchUserDetails(username);
    });
    final username = _userController.userAccount['username']?.toString() ?? '';
    if (username.isNotEmpty) {
      _userController.fetchUserDetails(username);
    }
  }

  @override
  void dispose() {
    _accountWorker.dispose();
    super.dispose();
  }

  Future<void> _openDeleteAccountPage() async {
    final launched = await launchUrl(
      _deleteAccountUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the account deletion page.'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'Your Envato account is permanently deleted through Envato support. '
            'Continue to the account deletion request page?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true) {
      return;
    }

    await _openDeleteAccountPage();
    await _authController.signOut();
    await _authController.disableDemo();
    if (mounted) {
      Get.offAll(() => SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Obx(() {
                final isDemo = _authController.isDemo.value;
                final loggedIn = _authController.accessToken.isNotEmpty;
                final accountName =
                    _userController.userAccount['username']?.toString() ??
                        'User';
                return Column(
                  children: [
                    if (loggedIn)
                      ListTile(
                        title: Text(
                          accountName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: isDemo
                            ? null
                            : Icon(Icons.check, color: colorScheme.primary),
                      ),
                    ListTile(
                      title: Text(
                        'Demo',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: isDemo
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () async {
                        await _authController.enableDemo();
                        if (context.mounted) {
                          Get.offAll(() => const BottomNavScreen());
                        }
                      },
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final loggedIn = _authController.isDemo.value ||
                  _authController.accessToken.isNotEmpty;
              if (!loggedIn) {
                return const SizedBox.shrink();
              }
              if (_userController.detailsLoading.value) {
                return const LoadingShimmer();
              }
              if (_userController.detailsError.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _userController.detailsError.value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                );
              }
              final details = _userController.userDetails;
              final account = _userController.userAccount;
              final username = details['username']?.toString() ??
                  account['username']?.toString() ??
                  'User';
              final imageUrl = details['image']?.toString() ?? '';
              final country = details['country']?.toString() ??
                  account['country']?.toString() ??
                  'Unknown';
              final location =
                  details['location']?.toString() ?? country;
              final sales = details['sales']?.toString() ?? '0';
              final followers = details['followers']?.toString() ?? '0';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                colorScheme.primary.withOpacity(0.1),
                            backgroundImage:
                                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                            child: imageUrl.isEmpty
                                ? Text(
                                    username.isNotEmpty
                                        ? username.substring(0, 1)
                                        : '?',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  location,
                                  style: textTheme.bodySmall?.copyWith(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'Sales',
                              value: sales,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricTile(
                              label: 'Followers',
                              value: followers,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricTile(
                              label: 'Country',
                              value: country,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                'Use "Delete account" to open Envato\'s account deletion page.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Add account...',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await _authController.disableDemo();
                      if (context.mounted) {
                        Get.offAll(() => SignInScreen());
                      }
                    },
                  ),
                  Divider(
                    height: 1,
                    color: colorScheme.onSurface.withOpacity(0.08),
                  ),
                  ListTile(
                    title: Text(
                      'Delete account',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently delete your Envato account',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    onTap: _confirmDeleteAccount,
                  ),
                  Divider(
                    height: 1,
                    color: colorScheme.onSurface.withOpacity(0.08),
                  ),
                  ListTile(
                    title: Text(
                      'Sign out',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await _authController.signOut();
                      await _authController.disableDemo();
                      if (context.mounted) {
                        Get.offAll(() => SignInScreen());
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
