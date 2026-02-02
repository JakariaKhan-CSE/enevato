import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/earning/earning_controller.dart';
import 'package:myenvato/controller/statement/statement_controller.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/controller/user/user_badge_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/screens/home/bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreloadScreen extends StatefulWidget {
  const PreloadScreen({super.key});

  @override
  State<PreloadScreen> createState() => _PreloadScreenState();
}

class _PreloadScreenState extends State<PreloadScreen> {
  static const String _appName = 'Evacado Tracker';
  static const String _fallbackUsername = 'Apptionary';
  static const String _prefsPreloadKey = 'preload_completed';

  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());
  final BadgeController _badgeController = Get.isRegistered<BadgeController>()
      ? Get.find<BadgeController>()
      : Get.put(BadgeController());
  final EarningsController _earningsController =
      Get.isRegistered<EarningsController>()
          ? Get.find<EarningsController>()
          : Get.put(EarningsController());
  final StatementController _statementController =
      Get.isRegistered<StatementController>()
          ? Get.find<StatementController>()
          : Get.put(StatementController());

  final RxBool _isDone = false.obs;
  late final List<_LoadStep> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      _LoadStep(title: 'Account Information'),
      _LoadStep(title: 'Portfolio Items'),
      _LoadStep(title: 'Statements'),
      _LoadStep(title: 'Sales'),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runLoad();
    });
  }

  Future<void> _runLoad() async {
    await _authController.waitForReady();
    if (!mounted) {
      return;
    }
    if (_authController.isDemo.value) {
      for (final step in _steps) {
        step.setDone();
      }
      _isDone.value = true;
      return;
    }
    await _loadAccount();
    if (!mounted) {
      return;
    }
    await _loadPortfolio();
    if (!mounted) {
      return;
    }
    await _loadStatements();
    if (!mounted) {
      return;
    }
    await _loadSales();
    if (!mounted) {
      return;
    }
    _isDone.value = true;
  }

  String _username() {
    return _userController.userAccount['username']?.toString() ??
        _fallbackUsername;
  }

  Future<void> _loadAccount() async {
    final step = _steps[0];
    step.setLoading();
    await _userController.fetchUserAccount();
    final username = _username();
    await _userController.fetchUserDetails(username);
    await _badgeController.fetchUserBadges(username);
    if (_userController.accountError.isNotEmpty) {
      step.setError(_userController.accountError.value);
      return;
    }
    step.setDone(detail: username);
  }

  Future<void> _loadPortfolio() async {
    final step = _steps[1];
    step.setLoading();
    await _userController.fetchUserItemsBySite(_username());
    if (_userController.userItemsError.isNotEmpty) {
      step.setError(_userController.userItemsError.value);
      return;
    }
    final totalItems = _userController.userItems.fold<int>(
      0,
      (sum, item) =>
          sum + (int.tryParse(item['items']?.toString() ?? '') ?? 0),
    );
    step.setDone(detail: '$totalItems items');
  }

  Future<void> _loadStatements() async {
    final step = _steps[2];
    step.setLoading();
    await _statementController.fetchAllStatements();
    if (_statementController.allStatementsError.isNotEmpty) {
      step.setError(_statementController.allStatementsError.value);
      return;
    }
    step.setDone(detail: '${_statementController.allStatements.length}');
  }

  Future<void> _loadSales() async {
    final step = _steps[3];
    step.setLoading();
    await _earningsController.fetchEarningsAndSalesByMonth();
    if (_earningsController.errorMessage.isNotEmpty) {
      step.setError(_earningsController.errorMessage.value);
      return;
    }
    final totalSales = _earningsController.earningsList.fold<int>(
      0,
      (sum, item) => sum + (item['sales'] as int? ?? 0),
    );
    step.setDone(detail: '$totalSales sales');
  }

  void _continue() {
    if (!_isDone.value) {
      return;
    }
    _markPreloadComplete().then((_) {
      Get.offAll(() => BottomNavScreen());
    });
  }

  Future<void> _markPreloadComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsPreloadKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.eco, color: colorScheme.primary, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                _appName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while your data is fetched.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: Column(
                    children: _steps
                        .map((step) => _LoadRow(step: step))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isDone.value ? _continue : null,
                    child: Text(_isDone.value ? 'Continue' : 'Loading...'),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'This only happens when you sign in.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadRow extends StatelessWidget {
  final _LoadStep step;

  const _LoadRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final status = step.status.value;
      IconData icon;
      Color iconColor;
      if (status == _LoadStatus.done) {
        icon = Icons.check_circle;
        iconColor = colorScheme.primary;
      } else if (status == _LoadStatus.error) {
        icon = Icons.error;
        iconColor = colorScheme.error;
      } else {
        icon = Icons.radio_button_unchecked;
        iconColor = colorScheme.onSurface.withOpacity(0.4);
      }
      return Column(
        children: [
          ListTile(
            leading: Icon(icon, color: iconColor),
            title: Text(
              step.title,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: step.detail.value.isEmpty
                ? null
                : Text(
                    step.detail.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
          ),
          Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.08)),
        ],
      );
    });
  }
}

enum _LoadStatus { idle, loading, done, error }

class _LoadStep {
  final String title;
  final Rx<_LoadStatus> status = _LoadStatus.idle.obs;
  final RxString detail = ''.obs;

  _LoadStep({required this.title});

  void setLoading() {
    status.value = _LoadStatus.loading;
    detail.value = '';
  }

  void setDone({String? detail}) {
    status.value = _LoadStatus.done;
    if (detail != null) {
      this.detail.value = detail;
    }
  }

  void setError(String message) {
    status.value = _LoadStatus.error;
    detail.value = 'Error';
  }
}
