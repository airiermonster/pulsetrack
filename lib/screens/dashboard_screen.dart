import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trends & Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Blood Pressure Trend Chart
          _buildBPTrendChart(provider),

          const SizedBox(height: 20),

          // Morning vs Evening Comparison
          _buildTimeComparisonChart(provider),

          const SizedBox(height: 20),

          // Medication Effect Analysis
          _buildMedicationAnalysisChart(provider),
        ],
      ),
    );
  }

  Widget _buildBPTrendChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Blood Pressure Trend', 'No data available');
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
              Text(
                'Blood Pressure Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
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
                                fontSize: 11,
                                color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      interval: (sortedReadings.length / 5).ceil().toDouble(),
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
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedReadings.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.systolic.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFFFF6B6B),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFFFF6B6B),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: sortedReadings.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.diastolic.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4ECDC4),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4ECDC4),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                minX: 0,
                maxX: sortedReadings.length.toDouble() - 1,
                minY: 60,
                maxY: 180,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Systolic', const Color(0xFFFF6B6B)),
              const SizedBox(width: 32),
              _buildLegendItem('Diastolic', const Color(0xFF4ECDC4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeComparisonChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Morning vs Evening', 'No data available');
    }

    final morningReadings = readings.where((r) => r.dayTime == DayTime.morning).toList();
    final eveningReadings = readings.where((r) => r.dayTime == DayTime.evening).toList();

    final morningSystolic = morningReadings.isEmpty ? 0 : morningReadings.map((r) => r.systolic).reduce((a, b) => a + b) / morningReadings.length;
    final morningDiastolic = morningReadings.isEmpty ? 0 : morningReadings.map((r) => r.diastolic).reduce((a, b) => a + b) / morningReadings.length;
    final eveningSystolic = eveningReadings.isEmpty ? 0 : eveningReadings.map((r) => r.systolic).reduce((a, b) => a + b) / eveningReadings.length;
    final eveningDiastolic = eveningReadings.isEmpty ? 0 : eveningReadings.map((r) => r.diastolic).reduce((a, b) => a + b) / eveningReadings.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Morning vs Evening Average',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt() == 0 ? 'Morning' : 'Evening',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: morningSystolic.toDouble(),
                          color: Colors.orange,
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: morningDiastolic.toDouble(),
                          color: Colors.orange.withValues(alpha: 0.5),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: eveningSystolic.toDouble(),
                          color: Colors.purple,
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: eveningDiastolic.toDouble(),
                          color: Colors.purple.withValues(alpha: 0.5),
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final time = groupIndex == 0 ? 'Morning' : 'Evening';
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
      ),
    );
  }

  Widget _buildMedicationAnalysisChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Medication Analysis', 'No data available');
    }

    final beforeReadings = readings.where((r) => r.medicationStatus == MedicationStatus.before).toList();
    final afterReadings = readings.where((r) => r.medicationStatus == MedicationStatus.after).toList();

    final beforeSystolic = beforeReadings.isEmpty ? 0 : beforeReadings.map((r) => r.systolic).reduce((a, b) => a + b) / beforeReadings.length;
    final beforeDiastolic = beforeReadings.isEmpty ? 0 : beforeReadings.map((r) => r.diastolic).reduce((a, b) => a + b) / beforeReadings.length;
    final afterSystolic = afterReadings.isEmpty ? 0 : afterReadings.map((r) => r.systolic).reduce((a, b) => a + b) / afterReadings.length;
    final afterDiastolic = afterReadings.isEmpty ? 0 : afterReadings.map((r) => r.diastolic).reduce((a, b) => a + b) / afterReadings.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Before vs After Medication',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt() == 0 ? 'Before' : 'After',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: beforeSystolic.toDouble(),
                          color: Colors.red,
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: beforeDiastolic.toDouble(),
                          color: Colors.red.withValues(alpha: 0.5),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: afterSystolic.toDouble(),
                          color: Colors.green,
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: afterDiastolic.toDouble(),
                          color: Colors.green.withValues(alpha: 0.5),
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
      ),
    );
  }

  Widget _buildEmptyChartCard(String title, String message) {
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

  double _getAverageSystolic(AppProvider provider) {
    if (provider.readings.isEmpty) return 0;
    return provider.readings.map((r) => r.systolic).reduce((a, b) => a + b) /
        provider.readings.length;
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
