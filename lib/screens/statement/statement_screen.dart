import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/statement/statement_controller.dart';

import 'package:intl/intl.dart'; // For date formatting
import 'package:myenvato/widget/statement_bottom_sheet.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class StatementScreen extends StatelessWidget {
  final StatementController _controller = Get.put(StatementController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statements'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Date Range Picker at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return Text(
                      _controller.selectedDateRange.value,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _controller.onDateRangeSelected(value);
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'last_30_days',
                          child: Text('Last 30 Days'),
                        ),
                        const PopupMenuItem(
                          value: 'current_month',
                          child: Text('Current Month'),
                        ),
                        const PopupMenuItem(
                          value: 'last_2_months',
                          child: Text('Last 2 Months'),
                        ),
                      ];
                    },
                    child: Icon(Icons.calendar_today, color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Loading indicator or list display
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const LoadingShimmer();
                  }

                  if (_controller.userStatement.isEmpty) {
                    return Center(
                      child: Text(
                        'No statement available.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: _controller.userStatement.length,
                    itemBuilder: (context, index) {
                      final statementLine = _controller.userStatement[index];

                      // Format the date
                      final parsedDate = DateTime.parse(statementLine['date']);
                      final formattedDate =
                          DateFormat('d MMM, yyyy • h:mm a').format(parsedDate.toLocal());

                      // Check if the type is "Sale Reversal" for conditional coloring
                      final isSaleReversal = statementLine['type'] == 'Sale Reversal';

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return StatementBottomSheet(statementLine: statementLine);
                            },
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      statementLine['type'].toString().toUpperCase(),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: isSaleReversal
                                            ? colorScheme.error
                                            : colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: textTheme.bodySmall?.copyWith(
                                        color:
                                            colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  statementLine['detail'],
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      statementLine['site'] ?? 'N/A',
                                      style: textTheme.labelSmall?.copyWith(
                                        color:
                                            colorScheme.onSurface.withOpacity(0.55),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '\$${statementLine['amount'].toStringAsFixed(2)}',
                                        style: textTheme.labelLarge?.copyWith(
                                          color: isSaleReversal
                                              ? colorScheme.error
                                              : colorScheme.secondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
