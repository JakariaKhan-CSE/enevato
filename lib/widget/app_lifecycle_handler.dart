import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/earning/earning_controller.dart';
import 'package:myenvato/controller/statement/statement_controller.dart';
import 'package:myenvato/controller/user/user_badge_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';

class AppLifecycleHandler extends StatefulWidget {
  const AppLifecycleHandler({super.key, required this.child});

  final Widget child;

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  bool _wasPaused = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    try {
      final userController = Get.find<UserController>();
      final earningsController = Get.find<EarningsController>();
      final statementController = Get.find<StatementController>();
      final badgeController = Get.find<BadgeController>();

      await userController.fetchUserAccount(forceRefresh: true);
      final username =
          userController.userAccount['username']?.toString().trim() ?? '';

      final refreshTasks = <Future>[
        earningsController.fetchEarningsAndSalesByMonth(forceRefresh: true),
        statementController.fetchUserStatement(forceRefresh: true),
        statementController.fetchAllStatements(forceRefresh: true),
      ];

      if (username.isNotEmpty) {
        refreshTasks.add(userController.fetchUserDetails(
          username,
          forceRefresh: true,
        ));
        refreshTasks.add(badgeController.fetchUserBadges(
          username,
          forceRefresh: true,
        ));
      }

      await Future.wait(refreshTasks);
    } catch (error) {
      // Swallow errors so lifecycle handler never crashes the app.
      debugPrint('Lifecycle refresh error: $error');
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
