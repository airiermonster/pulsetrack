import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/index.dart';
import '../services/export_service.dart';

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
            icon: const Icon(Icons.download),
            onPressed: () => _exportData(context, 'excel'),
            tooltip: 'Export to Excel',
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data to display',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some blood pressure readings to see your analytics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-reading');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Reading'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildAnalyticsSummary(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Average Systolic',
                value: _getAverageSystolic(provider).toStringAsFixed(1),
                unit: 'mmHg',
                icon: Icons.favorite,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'Average Diastolic',
                value: _getAverageDiastolic(provider).toStringAsFixed(1),
                unit: 'mmHg',
                icon: Icons.favorite_border,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Average Pulse',
                value: _getAveragePulse(provider).toStringAsFixed(1),
                unit: 'bpm',
                icon: Icons.accessibility,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Readings',
                value: provider.readings.length.toString(),
                unit: '',
                icon: Icons.analytics,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              '$value $unit',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charts & Trends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Blood Pressure Trend Chart
        _buildBPTrendChart(provider),

        const SizedBox(height: 16),

        // Morning vs Evening Comparison
        _buildTimeComparisonChart(provider),

        const SizedBox(height: 16),

        // Medication Effect Analysis
        _buildMedicationAnalysisChart(provider),
      ],
    );
  }

  Widget _buildBPTrendChart(AppProvider provider) {
    final readings = provider.readings;
    if (readings.isEmpty) {
      return _buildEmptyChartCard('Blood Pressure Trend', 'No data available');
    }

    // Sort readings by date
    final sortedReadings = [...readings]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Pressure Trend (Last 30 Days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedReadings.length) {
                            final date = sortedReadings[value.toInt()].timestamp;
                            return Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedReadings.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.systolic.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: sortedReadings.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.diastolic.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minX: 0,
                  maxX: sortedReadings.length.toDouble() - 1,
                  minY: 60,
                  maxY: 180,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Systolic', Colors.red),
                const SizedBox(width: 24),
                _buildLegendItem('Diastolic', Colors.blue),
              ],
            ),
          ],
        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
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
