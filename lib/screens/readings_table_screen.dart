import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/index.dart';
import 'ui_components.dart';

class ReadingsTableScreen extends StatefulWidget {
  const ReadingsTableScreen({super.key});

  @override
  State<ReadingsTableScreen> createState() => _ReadingsTableScreenState();
}

class _ReadingsTableScreenState extends State<ReadingsTableScreen> {
  Map<String, List<BloodPressureReading>>? _groupedReadings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.initialize();

    // Group readings by date
    final grouped = <String, List<BloodPressureReading>>{};
    for (final reading in appProvider.readings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(reading.timestamp);
      grouped[dateKey] = [...(grouped[dateKey] ?? []), reading];
    }

    // Sort each day's readings by time
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    // Sort dates in descending order (most recent first)
    final sortedGrouped = Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key))
    );

    setState(() {
      _groupedReadings = sortedGrouped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Readings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _groupedReadings == null
          ? const Center(child: CircularProgressIndicator())
          : _groupedReadings!.isEmpty
              ? _buildEmptyState()
              : _buildReadingsTable(),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.assignment_outlined,
                size: 64,
                color: themeProvider.subtleTextColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Readings Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your blood pressure to see\nyour complete history here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeProvider.subtleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingsTable() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groupedReadings!.length,
      itemBuilder: (context, index) {
        final dateKey = _groupedReadings!.keys.elementAt(index);
        final readings = _groupedReadings![dateKey]!;
        final date = DateTime.parse(dateKey);

        return ModernCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Provider.of<ThemeProvider>(context).textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeProvider>(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${readings.length} reading${readings.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Horizontal Scrollable Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context).surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              'Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context).textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              'Systolic',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context).textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              'Diastolic',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context).textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Pulse',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context).textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context).textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              'Medication',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context).textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Reading Rows
                    ...readings.map((reading) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context).surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              DateFormat('HH:mm').format(reading.timestamp),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Provider.of<ThemeProvider>(context).textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '${reading.systolic}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(reading.category),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '${reading.diastolic}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(reading.category),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${reading.pulse}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(reading.category),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(reading.category).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getCategoryColor(reading.category).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                reading.category,
                                style: TextStyle(
                                  color: _getCategoryColor(reading.category),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              reading.medicationStatus.toString().split('.').last,
                              style: TextStyle(
                                fontSize: 11,
                                color: Provider.of<ThemeProvider>(context).subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Low':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      case 'Elevated':
        return Colors.orange;
      case 'Stage 1':
        return Colors.red;
      case 'Stage 2':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }
}

