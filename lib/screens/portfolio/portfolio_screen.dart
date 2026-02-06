import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/screens/portfolio/portfolio_site_screen.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  static const String _fallbackUsername = 'Apptionary';
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  late final Worker _authWorker;
  late final Worker _accountWorker;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    _authController.waitForReady().then((_) {
      if (_authController.accessToken.isNotEmpty) {
        _maybeLoadPortfolio();
      }
    });
    _authWorker = ever<String>(_authController.accessToken, (token) {
      if (token.isEmpty) {
        return;
      }
      _requested = false;
      _maybeLoadPortfolio();
    });
    _accountWorker =
        ever<Map<String, dynamic>?>(_authController.userAccount, (_) {
      _maybeLoadPortfolio();
    });
  }

  @override
  void dispose() {
    _authWorker.dispose();
    _accountWorker.dispose();
    super.dispose();
  }

  void _maybeLoadPortfolio() {
    if (_requested) {
      return;
    }
    if (_authController.isDemo.value) {
      _requested = true;
      _userController.fetchUserItemsBySite(_fallbackUsername);
      return;
    }
    if (_authController.userAccount.value == null) {
      _authController.fetchUserAccount();
      return;
    }
    final username = _authController.userAccount.value?['username']?.toString() ??
        _fallbackUsername;
    if (username.isEmpty) {
      return;
    }
    _requested = true;
    _userController.fetchUserItemsBySite(username);
  }

  String _formatCount(int value) => value == 1 ? '1 item' : '$value items';

  List<Map<String, dynamic>> _siteItems(List<dynamic> items) {
    return items.whereType<Map<String, dynamic>>().toList();
  }

  String _siteParam(String site) {
    return site.toLowerCase().replaceAll(RegExp(r'\\s+'), '');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() {
                if (_userController.userItemsLoading.value) {
                  return const LoadingShimmer();
                }

                if (_userController.userItemsError.isNotEmpty) {
                  return Center(
                    child: Text(
                      _userController.userItemsError.value,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final sites = _siteItems(_userController.userItems);
                if (sites.isEmpty) {
                  return Center(
                    child: Text(
                      'No portfolio sites found.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: sites.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colorScheme.onSurface.withOpacity(0.08),
                  ),
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    final label = site['site']?.toString() ?? 'Unknown';
                    final count =
                        int.tryParse(site['items']?.toString() ?? '') ?? 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.15),
                        child: Text(
                          label.isNotEmpty ? label.substring(0, 1) : '?',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        label,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _formatCount(count),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onTap: () {
                        Get.to(
                          () => PortfolioSiteScreen(
                            siteLabel: label,
                            siteParam: _siteParam(label),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
