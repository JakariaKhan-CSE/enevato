import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myenvato/controller/earning/earning_controller.dart';
import 'package:myenvato/controller/statement/statement_controller.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/widget/loading_shimmer.dart';
import 'package:myenvato/widget/userdetails/user_badge_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _fallbackUsername = 'Apptionary';
  final UserController _controller = Get.put(UserController());
  final EarningsController _earningsController = Get.find<EarningsController>();
  final StatementController _statementController = Get.find<StatementController>();
  final AuthController _authController = Get.find<AuthController>();
  late final Worker _authWorker;
  late final Worker _accountWorker;

  @override
  void initState() {
    super.initState();
    _authController.waitForReady().then((_) {
      if (_authController.isDemo.value ||
          _authController.accessToken.isNotEmpty) {
        _controller.fetchUserAccount();
      }
    });
    _authWorker = ever<String>(_authController.accessToken, (token) {
      if (token.isEmpty) {
        if (_authController.isDemo.value) {
          _controller.fetchUserAccount();
        }
        return;
      }
      _controller.fetchUserAccount();
    });
    _accountWorker = ever<Map<String, dynamic>>(_controller.userAccount, (account) {
      final username = account['username']?.toString() ?? _fallbackUsername;
      if (username.isEmpty) {
        return;
      }
      _controller.fetchUserDetails(username);
    });
  }

  @override
  void dispose() {
    _authWorker.dispose();
    _accountWorker.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    await _controller.fetchUserAccount(forceRefresh: true);
    final username = _controller.userAccount['username']?.toString();
    final futures = <Future<void>>[
      if (username?.isNotEmpty ?? false)
        _controller.fetchUserDetails(username!, forceRefresh: true),
      _earningsController.fetchEarningsAndSalesByMonth(forceRefresh: true),
      _statementController.fetchUserStatement(forceRefresh: true),
    ];
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Evacado Tracker'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final accountLoading = _controller.accountLoading.value;
          final detailsLoading = _controller.detailsLoading.value;
          if (accountLoading || detailsLoading) {
            return const LoadingShimmer();
          }

          if (_controller.accountError.isNotEmpty) {
            final message = _controller.accountError.value;
            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: _refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - 64,
                  child: Center(
                    child: Text(
                      message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }

          final account = _controller.userAccount;
          final details = _controller.userDetails;
          final username = details['username']?.toString() ??
              account['username']?.toString() ??
              _fallbackUsername;
          final avatarUrl = details['image']?.toString() ?? '';
          final balance = _formatCurrency(account['balance']);
          final sales = details.isEmpty
              ? '—'
              : _formatNumber(details['sales']);
          final followers = details.isEmpty
              ? '—'
              : _formatNumber(details['followers']);
          final summary = _buildMonthlySummary(_earningsController.earningsList);
          final statementSource = _statementController.allStatements.isNotEmpty
              ? _statementController.allStatements
              : _statementController.userStatement;
          final latestSale = _latestSale(statementSource);
          final topCountries =
              _topCountries(statementSource, 5);

          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: colorScheme.primary.withOpacity(0.15),
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl.isEmpty
                          ? Text(
                              username.isNotEmpty
                                  ? username.substring(0, 1)
                                  : '?',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        username,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: colorScheme.onSurface.withOpacity(0.12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Balance',
                        value: balance,
                      ),
                    ),
                    Expanded(
                      child: _StatTile(
                        label: 'Sales',
                        value: sales,
                      ),
                    ),
                    Expanded(
                      child: _StatTile(
                        label: 'Followers',
                        value: followers,
                      ),
                    ),
                  ],
                ),
                if (_controller.detailsError.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'User details unavailable right now.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Summary',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_earningsController.isLoading.value)
                  const LoadingShimmer()
                else if (_earningsController.errorMessage.isNotEmpty)
                  Text(
                    _earningsController.errorMessage.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: summary.currentLabel,
                          amount: summary.currentEarnings,
                          sales: summary.currentSales,
                          accent: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: summary.previousLabel,
                          amount: summary.previousEarnings,
                          sales: summary.previousSales,
                          accent: colorScheme.primary.withOpacity(0.2),
                          muted: true,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Text(
                  'Latest Sale',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_statementController.isLoading.value ||
                    _statementController.allStatementsLoading.value)
                  const LoadingShimmer()
                else if (_statementController.allStatementsError.isNotEmpty)
                  Text(
                    _statementController.allStatementsError.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  )
                else if (latestSale == null)
                  Text(
                    'No sales found yet.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                else
                  _LatestSaleCard(
                    title: latestSale['detail']?.toString() ?? 'Sale',
                    amount: _formatCurrency(latestSale['amount']),
                    date: _formatSaleDate(latestSale['date']?.toString()),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Top Countries',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_statementController.isLoading.value ||
                    _statementController.allStatementsLoading.value)
                  const LoadingShimmer()
                else if (_statementController.allStatementsError.isNotEmpty)
                  Text(
                    _statementController.allStatementsError.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  )
                else if (topCountries.isEmpty)
                  Text(
                    'No country data yet.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                else
                  _TopCountriesCard(countries: topCountries),
                const SizedBox(height: 20),
                Text(
                  'Badges',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                UserBadgesWidget(username: username),
              ],
            ),
          ));
        }),
      ),
    );
  }

  _MonthlySummary _buildMonthlySummary(List<dynamic> rawItems) {
    final items = rawItems.whereType<Map<String, dynamic>>().toList();
    if (items.isEmpty) {
      return _MonthlySummary.empty();
    }
    final parsed = items.map((item) {
      final month = item['month']?.toString() ?? '';
      final earnings = double.tryParse(item['earnings']?.toString() ?? '') ?? 0;
      final sales = int.tryParse(item['sales']?.toString() ?? '') ?? 0;
      final date = _parseMonth(month);
      return _MonthlyRecord(date: date, earnings: earnings, sales: sales);
    }).where((record) => record.date != null).toList();
    parsed.sort((a, b) => b.date!.compareTo(a.date!));
    final current = parsed.isNotEmpty ? parsed.first : null;
    final previous = parsed.length > 1 ? parsed[1] : null;
    final currentLabel = current?.date != null
        ? DateFormat('MMMM yyyy').format(current!.date!)
        : 'This month';
    final previousLabel = previous?.date != null
        ? DateFormat('MMMM yyyy').format(previous!.date!)
        : 'Last month';
    return _MonthlySummary(
      currentLabel: currentLabel,
      currentEarnings: current?.earnings ?? 0,
      currentSales: current?.sales ?? 0,
      previousLabel: previousLabel,
      previousEarnings: previous?.earnings ?? 0,
      previousSales: previous?.sales ?? 0,
    );
  }

  DateTime? _parseMonth(String value) {
    if (value.isEmpty) {
      return null;
    }
    final cleaned = value.replaceFirst(RegExp(r' [+-]\\d{4}'), '');
    try {
      return DateFormat('EEE MMM dd HH:mm:ss yyyy').parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _latestSale(List<dynamic> lines) {
    for (final entry in lines) {
      if (entry is Map<String, dynamic>) {
        final type = entry['type']?.toString() ?? '';
        if (type.toLowerCase() == 'sale') {
          return entry;
        }
      }
    }
    return null;
  }

  List<_CountryTotal> _topCountries(List<dynamic> lines, int limit) {
    const excluded = {
      '3docean',
      'activeden',
      'audiojungle',
      'codecanyon',
      'graphicriver',
      'photodune',
      'themeforest',
      'videohive',
    };
    final totals = <String, double>{};
    for (final entry in lines) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      final type = entry['type']?.toString() ?? '';
      final lowerType = type.toLowerCase();
      if (!lowerType.contains('sale') || lowerType.contains('reversal')) {
        continue;
      }
      final country = entry['other_party_country']?.toString().trim();
      if (country == null || country.isEmpty) {
        continue;
      }
      if (excluded.contains(country.toLowerCase())) {
        continue;
      }
      final amount =
          double.tryParse(entry['amount']?.toString() ?? '') ?? 0.0;
      if (amount <= 0) {
        continue;
      }
      totals[country] = (totals[country] ?? 0.0) + amount;
    }
    final list = totals.entries
        .map((entry) => _CountryTotal(country: entry.key, total: entry.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    if (list.length <= limit) {
      return list;
    }
    return list.take(limit).toList();
  }

  String _formatSaleDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return '';
    }
    try {
      final parsed = DateTime.parse(raw).toLocal();
      return DateFormat('d MMM, yyyy • h:mm a').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  String _formatCurrency(dynamic value) {
    final parsed = double.tryParse(value?.toString() ?? '') ?? 0.0;
    return '\$${parsed.toStringAsFixed(2)}';
  }

  String _formatNumber(dynamic value) {
    if (value == null) {
      return '0';
    }
    return value.toString();
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final int sales;
  final Color accent;
  final bool muted;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.sales,
    required this.accent,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: muted ? colorScheme.surface : accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              color: muted
                  ? colorScheme.onSurface.withOpacity(0.6)
                  : colorScheme.onSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: textTheme.titleLarge?.copyWith(
              color: muted ? colorScheme.onSurface : colorScheme.onSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$sales sales',
            style: textTheme.labelMedium?.copyWith(
              color: muted
                  ? colorScheme.onSurface.withOpacity(0.6)
                  : colorScheme.onSecondary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestSaleCard extends StatelessWidget {
  final String title;
  final String amount;
  final String date;

  const _LatestSaleCard({
    required this.title,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sell, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyRecord {
  final DateTime? date;
  final double earnings;
  final int sales;

  const _MonthlyRecord({
    required this.date,
    required this.earnings,
    required this.sales,
  });
}

class _MonthlySummary {
  final String currentLabel;
  final double currentEarnings;
  final int currentSales;
  final String previousLabel;
  final double previousEarnings;
  final int previousSales;

  const _MonthlySummary({
    required this.currentLabel,
    required this.currentEarnings,
    required this.currentSales,
    required this.previousLabel,
    required this.previousEarnings,
    required this.previousSales,
  });

  factory _MonthlySummary.empty() => const _MonthlySummary(
        currentLabel: 'This month',
        currentEarnings: 0,
        currentSales: 0,
        previousLabel: 'Last month',
        previousEarnings: 0,
        previousSales: 0,
      );
}

class _CountryTotal {
  final String country;
  final double total;

  const _CountryTotal({required this.country, required this.total});
}

class _TopCountriesCard extends StatelessWidget {
  final List<_CountryTotal> countries;

  const _TopCountriesCard({required this.countries});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        children: List.generate(countries.length, (index) {
          final item = countries[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    item.country.substring(0, 1),
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  item.country,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  '\$${item.total.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              if (index < countries.length - 1)
                Divider(
                  height: 1,
                  color: colorScheme.onSurface.withOpacity(0.08),
                ),
            ],
          );
        }),
      ),
    );
  }
}
