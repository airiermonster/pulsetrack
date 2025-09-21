import 'package:intl/intl.dart';

enum DayTime { morning, evening }
enum MedicationStatus { before, after }

class BloodPressureReading {
  final int? id;
  final int systolic;
  final int diastolic;
  final int pulse;
  final DayTime dayTime;
  final MedicationStatus medicationStatus;
  final DateTime timestamp;
  final String? notes;

  BloodPressureReading({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.dayTime,
    required this.medicationStatus,
    required this.timestamp,
    this.notes,
  });

  // Factory constructor for creating from database
  factory BloodPressureReading.fromMap(Map<String, dynamic> map) {
    return BloodPressureReading(
      id: map['id'],
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      pulse: map['pulse'],
      dayTime: DayTime.values[map['time_of_day']],
      medicationStatus: MedicationStatus.values[map['medication_status']],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
    );
  }

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'time_of_day': dayTime.index,
      'medication_status': medicationStatus.index,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  // Get formatted date string
  String get formattedDate => DateFormat('MMM dd, yyyy').format(timestamp);

  // Get formatted time string
  String get formattedTime => DateFormat('HH:mm').format(timestamp);

  // Get full formatted timestamp
  String get formattedTimestamp => DateFormat('MMM dd, yyyy HH:mm').format(timestamp);

  // Get reading category based on systolic/diastolic values
  String get category {
    // Low Blood Pressure (Hypotension)
    if (systolic < 90 || diastolic < 60) return 'Low';

    // Normal Blood Pressure (Systolic < 120 AND Diastolic < 80)
    // Note: 120/80 is considered Normal in practice
    if (systolic <= 120 && diastolic <= 80) return 'Normal';

    // Elevated Blood Pressure (Systolic 120-129 AND Diastolic < 80)
    if ((systolic >= 120 && systolic < 130) && diastolic < 80) return 'Elevated';

    // High Blood Pressure (Hypertension) Stage 1 (Systolic 130-139 OR Diastolic 80-89)
    if ((systolic >= 130 && systolic < 140) || (diastolic >= 80 && diastolic < 90)) return 'Stage 1';

    // High Blood Pressure (Hypertension) Stage 2 (Systolic ≥ 140 OR Diastolic ≥ 90)
    if (systolic >= 140 || diastolic >= 90) return 'Stage 2';

    // Default to Normal if nothing matches
    return 'Normal';
  }

  // Get category color
  String get categoryColor {
    switch (category) {
      case 'Low': return '#FFA500'; // Orange
      case 'Normal': return '#4CAF50'; // Green
      case 'Elevated': return '#FF9800'; // Orange
      case 'Stage 1': return '#F44336'; // Red
      case 'Stage 2': return '#9C27B0'; // Purple
      default: return '#4CAF50';
    }
  }

  @override
  String toString() {
    return 'BloodPressureReading(id: $id, systolic: $systolic, diastolic: $diastolic, pulse: $pulse, dayTime: $dayTime, medicationStatus: $medicationStatus, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BloodPressureReading &&
        other.id == id &&
        other.systolic == systolic &&
        other.diastolic == diastolic &&
        other.pulse == pulse &&
        other.dayTime == dayTime &&
        other.medicationStatus == medicationStatus &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        systolic.hashCode ^
        diastolic.hashCode ^
        pulse.hashCode ^
        dayTime.hashCode ^
        medicationStatus.hashCode ^
        timestamp.hashCode;
  }
}
