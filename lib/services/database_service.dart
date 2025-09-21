import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/index.dart';

class DatabaseService {
  static const String _databaseName = 'pulsetrack.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender INTEGER,
        age INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE blood_pressure_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        pulse INTEGER NOT NULL,
        time_of_day INTEGER NOT NULL,
        medication_status INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_blood_pressure_timestamp ON blood_pressure_readings(timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_blood_pressure_time_of_day ON blood_pressure_readings(time_of_day)
    ''');

    await db.execute('''
      CREATE INDEX idx_blood_pressure_medication_status ON blood_pressure_readings(medication_status)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
  }

  // User Profile operations
  Future<int> insertUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert('user_profile', profile.toMap());
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.update(
      'user_profile',
      profile.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // Blood Pressure Reading operations
  Future<int> insertBloodPressureReading(BloodPressureReading reading) async {
    final db = await database;
    return await db.insert('blood_pressure_readings', reading.toMap());
  }

  Future<List<BloodPressureReading>> getBloodPressureReadings({
    DateTime? startDate,
    DateTime? endDate,
    DayTime? dayTime,
    MedicationStatus? medicationStatus,
    int? limit,
  }) async {
    final db = await database;

    String whereClause = '';
    List<String> whereArgs = [];

    if (startDate != null) {
      whereClause += 'timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    if (dayTime != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'time_of_day = ?';
      whereArgs.add(dayTime.index.toString());
    }

    if (medicationStatus != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'medication_status = ?';
      whereArgs.add(medicationStatus.index.toString());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure_readings',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => BloodPressureReading.fromMap(map)).toList();
  }

  Future<BloodPressureReading?> getBloodPressureReading(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure_readings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return BloodPressureReading.fromMap(maps.first);
  }

  Future<int> updateBloodPressureReading(BloodPressureReading reading) async {
    final db = await database;
    return await db.update(
      'blood_pressure_readings',
      reading.toMap(),
      where: 'id = ?',
      whereArgs: [reading.id],
    );
  }

  Future<int> deleteBloodPressureReading(int id) async {
    final db = await database;
    return await db.delete(
      'blood_pressure_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics operations
  Future<Map<String, dynamic>> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Get all readings within date range
    final readings = await getBloodPressureReadings(
      startDate: startDate,
      endDate: endDate,
    );

    if (readings.isEmpty) {
      return {
        'totalReadings': 0,
        'averageSystolic': 0,
        'averageDiastolic': 0,
        'averagePulse': 0,
        'minSystolic': 0,
        'maxSystolic': 0,
        'minDiastolic': 0,
        'maxDiastolic': 0,
        'readingsByTimeOfDay': {},
        'readingsByMedicationStatus': {},
      };
    }

    final systolicValues = readings.map((r) => r.systolic).toList();
    final diastolicValues = readings.map((r) => r.diastolic).toList();
    final pulseValues = readings.map((r) => r.pulse).toList();

    // Group by time of day
    final byDayTime = <String, List<BloodPressureReading>>{};
    for (final reading in readings) {
      final key = reading.dayTime.toString().split('.').last;
      byDayTime[key] = [...(byDayTime[key] ?? []), reading];
    }

    // Group by medication status
    final byMedicationStatus = <String, List<BloodPressureReading>>{};
    for (final reading in readings) {
      final key = reading.medicationStatus.toString().split('.').last;
      byMedicationStatus[key] = [...(byMedicationStatus[key] ?? []), reading];
    }

    return {
      'totalReadings': readings.length,
      'averageSystolic': systolicValues.reduce((a, b) => a + b) / systolicValues.length,
      'averageDiastolic': diastolicValues.reduce((a, b) => a + b) / diastolicValues.length,
      'averagePulse': pulseValues.reduce((a, b) => a + b) / pulseValues.length,
      'minSystolic': systolicValues.reduce((a, b) => a < b ? a : b),
      'maxSystolic': systolicValues.reduce((a, b) => a > b ? a : b),
      'minDiastolic': diastolicValues.reduce((a, b) => a < b ? a : b),
      'maxDiastolic': diastolicValues.reduce((a, b) => a > b ? a : b),
      'readingsByDayTime': byDayTime.map((key, value) => MapEntry(key, {
        'count': value.length,
        'averageSystolic': value.map((r) => r.systolic).reduce((a, b) => a + b) / value.length,
        'averageDiastolic': value.map((r) => r.diastolic).reduce((a, b) => a + b) / value.length,
        'averagePulse': value.map((r) => r.pulse).reduce((a, b) => a + b) / value.length,
      })),
      'readingsByMedicationStatus': byMedicationStatus.map((key, value) => MapEntry(key, {
        'count': value.length,
        'averageSystolic': value.map((r) => r.systolic).reduce((a, b) => a + b) / value.length,
        'averageDiastolic': value.map((r) => r.diastolic).reduce((a, b) => a + b) / value.length,
        'averagePulse': value.map((r) => r.pulse).reduce((a, b) => a + b) / value.length,
      })),
    };
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('blood_pressure_readings');
    await db.delete('user_profile');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
