import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/index.dart';
import 'number_picker.dart';

class EditReadingScreen extends StatefulWidget {
  final BloodPressureReading reading;

  const EditReadingScreen({super.key, required this.reading});

  @override
  State<EditReadingScreen> createState() => _EditReadingScreenState();
}

class _EditReadingScreenState extends State<EditReadingScreen> {
  late int _systolicValue;
  late int _diastolicValue;
  late int _pulseValue;
  late DayTime _selectedDayTime;
  late MedicationStatus _selectedMedicationStatus;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _systolicValue = widget.reading.systolic;
    _diastolicValue = widget.reading.diastolic;
    _pulseValue = widget.reading.pulse;
    _selectedDayTime = widget.reading.dayTime;
    _selectedMedicationStatus = widget.reading.medicationStatus;
    _notesController = TextEditingController(text: widget.reading.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blood Pressure Reading'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Delete Reading',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original Reading Info
            _buildOriginalReadingInfo(),

            const SizedBox(height: 24),

            // Reading Values Section
            _buildReadingValuesSection(),

            const SizedBox(height: 24),

            // Time and Medication Section
            _buildTimeMedicationSection(),

            const SizedBox(height: 24),

            // Notes Section
            _buildNotesSection(),

            const SizedBox(height: 32),

            // Update Button
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalReadingInfo() {
    return Card(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Original Reading',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.reading.formattedDate} at ${widget.reading.formattedTime}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOriginalValue(
                  label: 'Systolic',
                  value: '${widget.reading.systolic} mmHg',
                ),
                _buildOriginalValue(
                  label: 'Diastolic',
                  value: '${widget.reading.diastolic} mmHg',
                ),
                _buildOriginalValue(
                  label: 'Pulse',
                  value: '${widget.reading.pulse} bpm',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalValue({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReadingValuesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Updated Values',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NumberPicker(
                    initialValue: _systolicValue,
                    minValue: 50,
                    maxValue: 300,
                    label: 'Systolic',
                    unit: 'mmHg',
                    onChanged: (value) {
                      setState(() {
                        _systolicValue = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '/',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NumberPicker(
                    initialValue: _diastolicValue,
                    minValue: 30,
                    maxValue: 200,
                    label: 'Diastolic',
                    unit: 'mmHg',
                    onChanged: (value) {
                      setState(() {
                        _diastolicValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            NumberPicker(
              initialValue: _pulseValue,
              minValue: 30,
              maxValue: 200,
              label: 'Pulse Rate',
              unit: 'bpm',
              onChanged: (value) {
                setState(() {
                  _pulseValue = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMedicationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time & Medication',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Time of Day
            _buildSegmentedControl<DayTime>(
              title: 'Time of Day',
              value: _selectedDayTime,
              items: const [
                {'label': 'Morning', 'value': DayTime.morning},
                {'label': 'Evening', 'value': DayTime.evening},
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDayTime = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Medication Status
            _buildSegmentedControl<MedicationStatus>(
              title: 'Medication Status',
              value: _selectedMedicationStatus,
              items: const [
                {'label': 'Before', 'value': MedicationStatus.before},
                {'label': 'After', 'value': MedicationStatus.after},
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMedicationStatus = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl<T>({
    required String title,
    required T value,
    required List<Map<String, dynamic>> items,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: items.map((item) {
              final isSelected = value == item['value'];
              final index = items.indexOf(item);
              final isFirst = index == 0;
              final isLast = index == items.length - 1;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(item['value']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: isFirst ? const Radius.circular(8) : Radius.zero,
                        right: isLast ? const Radius.circular(8) : Radius.zero,
                      ),
                    ),
                    child: Text(
                      item['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Any additional notes about this reading...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _updateReading,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_isSubmitting ? 'Updating...' : 'Update Reading'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Future<void> _updateReading() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<AppProvider>();
      final updatedReading = BloodPressureReading(
        id: widget.reading.id,
        systolic: _systolicValue,
        diastolic: _diastolicValue,
        pulse: _pulseValue,
        dayTime: _selectedDayTime,
        medicationStatus: _selectedMedicationStatus,
        timestamp: widget.reading.timestamp, // Keep original timestamp
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await provider.updateReading(updatedReading);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating reading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Reading'),
          content: Text(
            'Are you sure you want to delete this blood pressure reading from ${widget.reading.formattedDate}?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _deleteReading,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReading() async {
    Navigator.pop(context); // Close dialog

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<AppProvider>();
      await provider.deleteReading(widget.reading.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting reading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

