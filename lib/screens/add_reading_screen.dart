import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/index.dart';
import 'number_picker.dart';
import 'ui_components.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reading'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: themeProvider.textColor,
      ),
      body: SingleChildScrollView(
        child: Column(
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ModernCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Provider.of<ThemeProvider>(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Blood Pressure Values',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '/',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<ThemeProvider>(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
            const SizedBox(height: 24),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ModernCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Provider.of<ThemeProvider>(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Time & Medication',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Time of Day
            ModernSegmentedControl<DayTime>(
              title: 'Time of Day',
              selectedValue: _selectedDayTime,
              items: const [
                {'label': 'Morning', 'value': DayTime.morning},
                {'label': 'Evening', 'value': DayTime.evening},
              ],
              onValueChanged: (value) {
                setState(() {
                  _selectedDayTime = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Medication Status
            ModernSegmentedControl<MedicationStatus>(
              title: 'Medication Status',
              selectedValue: _selectedMedicationStatus,
              items: const [
                {'label': 'Before', 'value': MedicationStatus.before},
                {'label': 'After', 'value': MedicationStatus.after},
              ],
              onValueChanged: (value) {
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


  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ModernCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_add,
                  color: Provider.of<ThemeProvider>(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Additional Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Provider.of<ThemeProvider>(context).subtleTextColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _notesController,
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).textColor,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Any additional notes about this reading...',
                  hintStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context).subtleTextColor,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ModernButton(
        text: _isSubmitting ? 'Saving...' : 'Save Reading',
        icon: _isSubmitting ? null : Icons.save,
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _submitReading,
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
