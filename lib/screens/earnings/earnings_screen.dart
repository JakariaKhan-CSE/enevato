import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/earning/earning_controller.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class EarningsScreen extends StatelessWidget {
  final EarningsController earningsController = Get.put(EarningsController());

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
          return Center(child: Text(earningsController.errorMessage.value));
        }

        // Group earnings by year and month
        Map<int, Map<String, List<Map<String, dynamic>>>> groupedEarnings = {};

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

          int year = parsedDate.year;
          String month = DateFormat('MMMM').format(parsedDate);

          // Initialize the map if it doesn't exist
          if (!groupedEarnings.containsKey(year)) {
            groupedEarnings[year] = {};
          }

          if (!groupedEarnings[year]!.containsKey(month)) {
            groupedEarnings[year]![month] = [];
          }

          // Add the earnings item to the respective month
          groupedEarnings[year]![month]!.add({
            'sales': item['sales'],
            'earnings': item['earnings'],
          });
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
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          );
        }

        // Calculate overall average earnings
        double overallAverageEarnings =
            totalEntries > 0 ? overallTotalEarnings / totalEntries : 0;

        return SingleChildScrollView(
          child: Column(
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

              // Bar chart widget
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 2.6,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: colorScheme.onSurface.withOpacity(0.12),
                              strokeWidth: 1,
                              dashArray: [6, 6],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 34,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Earnings grouped by year and month
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: years.length,
                itemBuilder: (context, yearIndex) {
                  int year = years[yearIndex];
                  Map<String, List<Map<String, dynamic>>> months =
                      groupedEarnings[year]!;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      title: Text(
                        '$year',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      iconColor: colorScheme.primary,
                      collapsedIconColor: colorScheme.onSurface.withOpacity(0.6),
                      children: months.entries.map((entry) {
                        String month = entry.key;
                        List<Map<String, dynamic>> items = entry.value;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              month,
                              style: textTheme.titleSmall,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: items.map((item) {
                                return Text(
                                  'Sales: ${item['sales']}, Earnings: \$${item['earnings']}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
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
