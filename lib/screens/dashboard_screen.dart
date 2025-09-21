import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/index.dart';
import '../services/export_service.dart';
import 'ui_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _exportData(context, 'excel'),
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.readings.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Analytics Summary Cards
                _buildAnalyticsSummary(provider),

                const SizedBox(height: 24),

                // Charts Section
                _buildChartsSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

            return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeProvider.subtleTextColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: themeProvider.subtleTextColor,
              ),
            ),
            const SizedBox(height: 24),
                  Text(
              'No Data Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
                  ),
                  const SizedBox(height: 8),
                  Text(
              'Start tracking your blood pressure to see\nyour analytics and insights here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeProvider.subtleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ModernButton(
              text: 'Add First Reading',
              icon: Icons.add,
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-reading');
                    },
                  ),
                ],
        ),
              ),
            );
          }

  Widget _buildAnalyticsSummary(AppProvider provider) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Health Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
          const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: AnalyticsCard(
                  title: 'Avg Systolic',
                  value: _getAverageSystolic(provider).toStringAsFixed(0),
                unit: 'mmHg',
                icon: Icons.favorite,
                  color: const Color(0xFFFF6B6B), // Soft red
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: AnalyticsCard(
                  title: 'Avg Diastolic',
                  value: _getAverageDiastolic(provider).toStringAsFixed(0),
                unit: 'mmHg',
                icon: Icons.favorite_border,
                  color: const Color(0xFF4ECDC4), // Soft teal
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: AnalyticsCard(
                  title: 'Avg Pulse',
                  value: _getAveragePulse(provider).toStringAsFixed(0),
                unit: 'bpm',
                  icon: Icons.monitor_heart,
                  color: const Color(0xFF45B7D1), // Soft blue
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: AnalyticsCard(
                title: 'Total Readings',
                value: provider.readings.length.toString(),
                unit: '',
                  icon: Icons.analytics_outlined,
                  color: themeProvider.primaryColor,
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }


  Widget _buildChartsSection(AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Health Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
          const SizedBox(height: 20),

          // Blood Pressure Trend Line Chart
          _buildBPTrendLineChart(provider),

          const SizedBox(height: 24),

          // Daily/Weekly Averages Bar Chart
          _buildAveragesBarChart(provider),

          const SizedBox(height: 24),

          // Blood Pressure Category Distribution
          _buildCategoryDistributionChart(provider),

          const SizedBox(height: 24),

          // Individual Readings Scatter Plot
          _buildScatterPlotChart(provider),
        ],
      ),
    );
  }

  Widget _buildBPTrendLineChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Blood Pressure Trends', 'No data available', context);
    }

    // Sort readings by date
    final sortedReadings = [...readings]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ModernCard(
      padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Provider.of<ThemeProvider>(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Blood Pressure Trends Over Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Responsive chart container
          Container(
            height: 300,
              child: LineChart(
                LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedReadings.length) {
                            final date = sortedReadings[value.toInt()].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            );
                          }
                          return const Text('');
                        },
                      interval: (sortedReadings.length / 6).ceil().toDouble(),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Provider.of<ThemeProvider>(context).subtleTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),

                // Add reference lines for blood pressure categories
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 90,
                      color: const Color(0xFF66BB6A).withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF66BB6A),
                          fontWeight: FontWeight.w500,
                        ),
                        labelResolver: (line) => 'Normal < 120/80',
                      ),
                    ),
                    HorizontalLine(
                      y: 120,
                      color: const Color(0xFFFFB74D).withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFFFFB74D),
                          fontWeight: FontWeight.w500,
                        ),
                        labelResolver: (line) => 'Elevated < 140/90',
                      ),
                    ),
                    HorizontalLine(
                      y: 140,
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w500,
                        ),
                        labelResolver: (line) => 'High > 180/120',
                      ),
                    ),
                  ],
                ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedReadings.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.systolic.toDouble());
                      }).toList(),
                      isCurved: true,
                    color: const Color(0xFFFF6B6B), // Systolic - soft red
                      barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFFFF6B6B),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                    ),
                    ),
                    LineChartBarData(
                      spots: sortedReadings.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.diastolic.toDouble());
                      }).toList(),
                      isCurved: true,
                    color: const Color(0xFF4ECDC4), // Diastolic - soft teal
                      barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4ECDC4),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                    ),
                    ),
                  ],
                  minX: 0,
                maxX: (sortedReadings.length - 1).toDouble(),
                  minY: 60,
                maxY: 200,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Legend with reference information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context).surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legend & Reference',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<ThemeProvider>(context).textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
              children: [
                    _buildLegendItem('Systolic', const Color(0xFFFF6B6B)),
                const SizedBox(width: 24),
                    _buildLegendItem('Diastolic', const Color(0xFF4ECDC4)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildReferenceLine('Normal', const Color(0xFF66BB6A)),
                    const SizedBox(width: 16),
                    _buildReferenceLine('Elevated', const Color(0xFFFFB74D)),
                    const SizedBox(width: 16),
                    _buildReferenceLine('High', const Color(0xFFFF6B6B)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAveragesBarChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Daily Averages', 'No data available', context);
    }

    // Group readings by day for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    final dailyData = <DateTime, Map<String, double>>{};

    for (final day in last7Days) {
      final dayReadings = readings.where((r) =>
        r.timestamp.year == day.year &&
        r.timestamp.month == day.month &&
        r.timestamp.day == day.day
      ).toList();

      if (dayReadings.isNotEmpty) {
        final avgSystolic = dayReadings.map((r) => r.systolic).reduce((a, b) => a + b) / dayReadings.length;
        final avgDiastolic = dayReadings.map((r) => r.diastolic).reduce((a, b) => a + b) / dayReadings.length;
        dailyData[day] = {
          'systolic': avgSystolic,
          'diastolic': avgDiastolic,
        };
      }
    }

    return ModernCard(
      padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: Provider.of<ThemeProvider>(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Daily Averages (Last 7 Days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                            final day = last7Days[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${day.day}/${day.month}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                            value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  barGroups: dailyData.entries.map((entry) {
                    final index = last7Days.indexOf(entry.key);
                    final systolic = entry.value['systolic'] ?? 0.0;
                    final diastolic = entry.value['diastolic'] ?? 0.0;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: systolic,
                          color: const Color(0xFFFF6B6B), // Systolic
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: diastolic,
                          color: const Color(0xFF4ECDC4), // Diastolic
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }).toList(),
                  barTouchData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = last7Days[group.x.toInt()];
                        final type = rodIndex == 0 ? 'Systolic' : 'Diastolic';
                        final value = rod.toY.toStringAsFixed(0);
                        return BarTooltipItem(
                        '${DateFormat('EEE, MMM dd').format(day)}\n$type: $value',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  groupsSpace: 20,
                  ),
                ),
              ),
          ],

          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Systolic', const Color(0xFFFF6B6B)),
              const SizedBox(width: 24),
              _buildLegendItem('Diastolic', const Color(0xFF4ECDC4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Category Distribution', 'No data available', context);
    }

    // Count readings by category
    final categoryCount = <String, int>{};
    for (final reading in readings) {
      categoryCount[reading.category] = (categoryCount[reading.category] ?? 0) + 1;
    }

    // Calculate percentages
    final totalReadings = readings.length;
    final categoryPercentages = categoryCount.map((key, value) =>
      MapEntry(key, (value / totalReadings * 100).round()));

    return ModernCard(
      padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: Provider.of<ThemeProvider>(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Blood Pressure Category Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: categoryCount.entries.map((entry) {
                  final category = entry.key;
                  final count = entry.value;
                  final percentage = (count / totalReadings * 100);

                  return PieChartSectionData(
                    value: percentage,
                    title: '$count\n${percentage.round()}%',
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    color: _getCategoryColor(category),
                    radius: 80,
                    titlePositionPercentageOffset: 0.5,
                  );
                }).toList(),
                sectionsSpace: 4,
                centerSpaceRadius: 40,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categoryCount.entries.map((entry) {
              final category = entry.key;
              final count = entry.value;
              final percentage = (count / totalReadings * 100).round();

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category, context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
            Text(
                    '$category ($count - $percentage%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Provider.of<ThemeProvider>(context).textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScatterPlotChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Individual Readings', 'No data available', context);
    }

    // Sort readings by date for better visualization
    final sortedReadings = [...readings]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.scatter_plot,
                color: Provider.of<ThemeProvider>(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Individual Readings Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            height: 250,
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: sortedReadings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reading = entry.value;

                  return ScatterSpot(
                    index.toDouble(),
                    reading.systolic.toDouble(),
                    dotPainter: FlDotCirclePainter(
                      radius: 4,
                      color: _getCategoryColor(reading.category, context),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  );
                }).toList(),
                minX: 0,
                maxX: (sortedReadings.length - 1).toDouble(),
                minY: 60,
                maxY: 200,
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < sortedReadings.length) {
                          final reading = sortedReadings[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${reading.timestamp.day}/${reading.timestamp.month}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      interval: (sortedReadings.length / 6).ceil().toDouble(),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Provider.of<ThemeProvider>(context).subtleTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItem: (ScatterSpot touchedSpot) {
                      final reading = sortedReadings[touchedSpot.x.toInt()];
                      return ScatterTooltipItem(
                        'Date: ${DateFormat('MMM dd, yyyy').format(reading.timestamp)}\n'
                        'Systolic: ${reading.systolic}\n'
                        'Diastolic: ${reading.diastolic}\n'
                        'Category: ${reading.category}',
                        textStyle: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Systolic BP', const Color(0xFF4ECDC4)),
              const SizedBox(width: 24),
              Text(
                'Each point represents one reading',
                style: TextStyle(
                  fontSize: 12,
                  color: Provider.of<ThemeProvider>(context).subtleTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                            value.toInt() == 0 ? 'Before' : 'After',
                              style: TextStyle(
                                fontSize: 11,
                                color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                            value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        reservedSize: 35,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: beforeSystolic.toDouble(),
                          color: const Color(0xFFFF6B6B), // Soft red
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: beforeDiastolic.toDouble(),
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.6),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: afterSystolic.toDouble(),
                          color: const Color(0xFF66BB6A), // Fresh green
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: afterDiastolic.toDouble(),
                          color: const Color(0xFF66BB6A).withValues(alpha: 0.6),
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final time = groupIndex == 0 ? 'Before' : 'After';
                        final type = rodIndex == 0 ? 'Systolic' : 'Diastolic';
                        final value = rod.toY.toStringAsFixed(0);
                        return BarTooltipItem(
                          '$time\n$type: $value',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildEmptyChartCard(String title, String message, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ModernCard(
      padding: const EdgeInsets.all(24),
        child: Column(
          children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_outlined,
                color: themeProvider.subtleTextColor,
                size: 20,
              ),
              const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
              ),
            ),
            ],
          ),
          const SizedBox(height: 20),
            Icon(
            Icons.show_chart_outlined,
              size: 48,
            color: themeProvider.subtleTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: themeProvider.subtleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
      ),
    );
  }





  double _getAverageSystolic(AppProvider provider) {
    if (provider.readings.isEmpty) return 0;
    return provider.readings.map((r) => r.systolic).reduce((a, b) => a + b) /
        provider.readings.length;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Provider.of<ThemeProvider>(context).textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceLine(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category, BuildContext context) {
    switch (category.toLowerCase()) {
      case 'normal':
        return const Color(0xFF66BB6A); // Green
      case 'elevated':
        return const Color(0xFFFFB74D); // Orange
      case 'high blood pressure stage 1':
      case 'high blood pressure stage 2':
      case 'hypertensive crisis':
        return const Color(0xFFFF6B6B); // Red
      default:
        return Provider.of<ThemeProvider>(context).primaryColor;
    }
  }

  double _getAverageDiastolic(AppProvider provider) {
    if (provider.readings.isEmpty) return 0;
    return provider.readings.map((r) => r.diastolic).reduce((a, b) => a + b) /
        provider.readings.length;
  }

  double _getAveragePulse(AppProvider provider) {
    if (provider.readings.isEmpty) return 0;
    return provider.readings.map((r) => r.pulse).reduce((a, b) => a + b) /
        provider.readings.length;
  }

  Future<void> _exportData(BuildContext context, String format) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final exportService = ExportService();

    if (provider.readings.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (!context.mounted) return;

      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exporting to Excel...'),
          backgroundColor: Colors.blue,
        ),
      );

      final filePath = await exportService.exportToExcel(provider.readings, provider.userProfile);

      if (!context.mounted) return;

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to Excel successfully! File saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
