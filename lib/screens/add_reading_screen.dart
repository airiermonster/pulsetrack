import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/index.dart';
import 'number_picker.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key});

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final _notesController = TextEditingController();

  // Default values for normal blood pressure
  int _systolicValue = 120;
  int _diastolicValue = 80;
  int _pulseValue = 72;

  DayTime _selectedDayTime = DayTime.morning;
  MedicationStatus _selectedMedicationStatus = MedicationStatus.before;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blood Pressure Reading'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reading Values Section
            _buildReadingValuesSection(),

            const SizedBox(height: 24),

            // Time and Medication Section
            _buildTimeMedicationSection(),

            const SizedBox(height: 24),

            // Notes Section
            _buildNotesSection(),

            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
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
              'Blood Pressure Values',
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
              'Additional Notes (Optional)',
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitReading,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_isSubmitting ? 'Saving...' : 'Save Reading'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }


  Future<void> _submitReading() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<AppProvider>();
      final reading = BloodPressureReading(
        systolic: _systolicValue,
        diastolic: _diastolicValue,
        pulse: _pulseValue,
        dayTime: _selectedDayTime,
        medicationStatus: _selectedMedicationStatus,
        timestamp: DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await provider.addReading(reading);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving reading: $e'),
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
