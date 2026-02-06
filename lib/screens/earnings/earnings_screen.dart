import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/earning/earning_controller.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class EarningsScreen extends StatelessWidget {
  final EarningsController earningsController = Get.put(EarningsController());

   EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: Obx(() {
        if (earningsController.isLoading.value) {
          return const LoadingShimmer();
        }

        if (earningsController.errorMessage.isNotEmpty) {
          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: () => earningsController.fetchEarningsAndSalesByMonth(
              forceRefresh: true,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 44,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      earningsController.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pull down to load again.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Group earnings by year/month and flatten for charting
        Map<int, Map<String, List<Map<String, dynamic>>>> groupedEarnings = {};
        final List<_MonthlyPoint> monthlyPoints = [];

        for (var item in earningsController.earningsList) {
          final String dateString = item['month'];
          final String cleanedDateString =
              dateString.replaceFirst(RegExp(r' [+-]\d{4}'), '');

          DateTime parsedDate;

          try {
            final DateFormat dateFormat =
                DateFormat('EEE MMM dd HH:mm:ss yyyy');
            parsedDate = dateFormat.parse(cleanedDateString);
          } catch (e) {
            continue; // Skip invalid dates
          }

          final int salesValue = (item['sales'] as num?)?.toInt() ?? 0;
          final double earningsValue =
              (item['earnings'] as num?)?.toDouble() ?? 0.0;
          final String monthLabel = DateFormat('MMMM').format(parsedDate);

          monthlyPoints.add(
            _MonthlyPoint(
              date: parsedDate,
              sales: salesValue,
              earnings: earningsValue,
              monthLabel: monthLabel,
            ),
          );

          if (!groupedEarnings.containsKey(parsedDate.year)) {
            groupedEarnings[parsedDate.year] = {};
          }
          groupedEarnings[parsedDate.year]!.putIfAbsent(monthLabel, () => []);
          groupedEarnings[parsedDate.year]![monthLabel]!.add({
            'sales': salesValue,
            'earnings': earningsValue,
          });
        }

        if (monthlyPoints.isEmpty) {
          return Center(
            child: Text(
              'No earnings data yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        }

        // Create a list of years sorted
        List<int> years = groupedEarnings.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        // Calculate total and average earnings per year
        Map<int, double> totalEarningsByYear = {};
        double overallTotalEarnings = 0; // To hold overall total earnings
        int totalEntries =
            0; // To hold the count of entries for average calculation

        for (var year in years) {
          double totalEarnings = 0;

          for (var month in groupedEarnings[year]!.values) {
            totalEntries +=
                month.length; // Count entries for average calculation
            for (var entry in month) {
              totalEarnings += entry['earnings'];
            }
          }
          totalEarningsByYear[year] = totalEarnings;

          overallTotalEarnings +=
              totalEarnings; // Sum total earnings for overall calculation
        }

        // Prepare data for the bar chart
        List<BarChartGroupData> barGroups = [];
        for (var year in years) {
          barGroups.add(
            BarChartGroupData(
              x: year,
              barRods: [
                BarChartRodData(
                  toY: totalEarningsByYear[year]!,
                  color: colorScheme.primary,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          );
        }

        // Calculate overall average earnings
        double overallAverageEarnings =
            totalEntries > 0 ? overallTotalEarnings / totalEntries : 0;

        monthlyPoints.sort((a, b) => a.date.compareTo(b.date));
        final _MonthlyPoint highestEarningMonth = monthlyPoints.reduce(
          (prev, next) => next.earnings > prev.earnings ? next : prev,
        );
        final _MonthlyPoint busiestMonth = monthlyPoints.reduce(
          (prev, next) => next.sales > prev.sales ? next : prev,
        );
        final double latestYearEarnings = totalEarningsByYear[years.first]!;
        final double priorYearEarnings =
            years.length > 1 ? totalEarningsByYear[years[1]]! : 0;
        final double yoyGrowth = priorYearEarnings > 0
            ? (latestYearEarnings - priorYearEarnings) / priorYearEarnings * 100
            : 0;

        final List<FlSpot> trendSpots = monthlyPoints
            .asMap()
            .entries
            .map((entry) => FlSpot(
                  entry.key.toDouble(),
                  entry.value.earnings,
                ))
            .toList();
        final List<String> trendLabels = monthlyPoints
            .map((item) => DateFormat('MMM yy').format(item.date))
            .toList();

        Widget content;
        if (monthlyPoints.isEmpty) {
          content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
            child: Text(
              'No earnings data yet.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        } else {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total',
                        value: '\$${overallTotalEarnings.toStringAsFixed(2)}',
                        accent: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Average',
                        value: '\$${overallAverageEarnings.toStringAsFixed(2)}',
                        accent: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 150,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _HighlightCard(
                        title: 'Best Month',
                        value:
                            '${highestEarningMonth.monthLabel} • \$${highestEarningMonth.earnings.toStringAsFixed(2)}',
                        trail: '${highestEarningMonth.sales} sales',
                        icon: Icons.trending_up,
                        highlight: true,
                      ),
                      _HighlightCard(
                        title: 'Most Sales',
                        value:
                            '${busiestMonth.monthLabel} • ${busiestMonth.sales} sales',
                        trail:
                            '\$${busiestMonth.earnings.toStringAsFixed(2)}',
                        icon: Icons.bar_chart,
                        highlight: false,
                      ),
                      _HighlightCard(
                        title: 'Year over Year',
                        value: '${yoyGrowth.toStringAsFixed(1)}%',
                        trail: years.length > 1
                            ? '${years[0]} vs ${years[1]}'
                            : 'First year recorded',
                        icon: Icons.timeline,
                        highlight: yoyGrowth >= 0,
                      ),
                    ]
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: card,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Monthly overview',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              titlesData: FlTitlesData(
                                topTitles:
                                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles:
                                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= trendLabels.length) {
                                        return const SizedBox();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          trendLabels[index],
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                drawHorizontalLine: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: colorScheme.onSurface.withOpacity(0.08),
                                  strokeWidth: 1,
                                  dashArray: [4, 4],
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: trendSpots,
                                  color: colorScheme.primary,
                                  barWidth: 3,
                                  isCurved: true,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: colorScheme.primary.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Trend across last ${trendLabels.length} months',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: years.map((year) {
                  final months = groupedEarnings[year]!;
                  final yearTotal = totalEarningsByYear[year]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$year',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '\$${yearTotal.toStringAsFixed(2)}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          iconColor: colorScheme.primary,
                          collapsedIconColor: colorScheme.onSurface.withOpacity(0.6),
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          children: months.entries.map((entry) {
                            final earningsSum = entry.value.fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + (element['earnings'] as double),
                            );
                            final salesSum = entry.value.fold<int>(
                              0,
                              (previousValue, element) =>
                                  previousValue + (element['sales'] as int),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MonthChip(
                                month: entry.key,
                                sales: salesSum,
                                earnings: earningsSum,
                                maxEarnings:
                                    months.values.expand((items) => items).fold<double>(
                                          0,
                                          (prev, element) =>
                                              prev + (element['earnings'] as double),
                                        ),
                                primaryColor: colorScheme.primary,
                                onSurfaceColor:
                                    colorScheme.onSurface.withOpacity(0.6),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          );
        }

        return RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: () => earningsController.fetchEarningsAndSalesByMonth(
            forceRefresh: true,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: content,
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String value;
  final String trail;
  final IconData icon;
  final bool highlight;

  const _HighlightCard({
    required this.title,
    required this.value,
    required this.trail,
    required this.icon,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      elevation: highlight ? 4 : 0,
      borderRadius: BorderRadius.circular(16),
      color: highlight ? colorScheme.primary.withOpacity(0.1) : null,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: highlight
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.onSurface.withOpacity(0.12),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: highlight
                  ? colorScheme.primary.withOpacity(0.2)
                  : colorScheme.onSurface.withOpacity(0.08),
              child: Icon(
                icon,
                color: highlight
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trail,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _MonthChip extends StatelessWidget {
  final String month;
  final int sales;
  final double earnings;
  final double maxEarnings;
  final Color primaryColor;
  final Color onSurfaceColor;

  const _MonthChip({
    required this.month,
    required this.sales,
    required this.earnings,
    required this.maxEarnings,
    required this.primaryColor,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = maxEarnings == 0 ? 0.0 : (earnings / maxEarnings).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurfaceColor),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              month.substring(0, 3),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$sales sales • \$${earnings.toStringAsFixed(2)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  color: primaryColor,
                  backgroundColor: primaryColor.withOpacity(0.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyPoint {
  final DateTime date;
  final int sales;
  final double earnings;
  final String monthLabel;

  _MonthlyPoint({
    required this.date,
    required this.sales,
    required this.earnings,
    required this.monthLabel,
  });
}
