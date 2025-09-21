import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/index.dart';

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No readings found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first blood pressure reading to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
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

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${readings.length} reading${readings.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Systolic',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Diastolic',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Pulse',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Medication',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Reading Rows
                ...readings.map((reading) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('HH:mm').format(reading.timestamp),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${reading.systolic}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(reading.category),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${reading.diastolic}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(reading.category),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${reading.pulse}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(reading.category),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(reading.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getCategoryColor(reading.category),
                            ),
                          ),
                          child: Text(
                            reading.category,
                            style: TextStyle(
                              color: _getCategoryColor(reading.category),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          reading.medicationStatus.toString().split('.').last,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
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

