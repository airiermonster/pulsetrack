import 'package:flutter/foundation.dart';
import '../models/index.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  UserProfile? _userProfile;
  List<BloodPressureReading> _readings = [];
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  List<BloodPressureReading> get readings => _readings;
  bool get isLoading => _isLoading;

  // Initialize the app
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUserProfile();
      await _loadReadings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // User Profile methods
  Future<void> _loadUserProfile() async {
    _userProfile = await _databaseService.getUserProfile();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_userProfile == null) {
        await _databaseService.insertUserProfile(profile);
      } else {
        await _databaseService.updateUserProfile(profile);
      }
      _userProfile = profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Blood Pressure Readings methods
  Future<void> _loadReadings() async {
    _readings = await _databaseService.getBloodPressureReadings();
  }

  Future<void> addReading(BloodPressureReading reading) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.insertBloodPressureReading(reading);
      await _loadReadings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReading(BloodPressureReading reading) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateBloodPressureReading(reading);
      await _loadReadings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReading(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteBloodPressureReading(id);
      await _loadReadings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.clearAllData();
      _userProfile = null;
      _readings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Analytics methods
  Future<Map<String, dynamic>> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.getAnalyticsData(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Get readings for specific date
  List<BloodPressureReading> getReadingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _readings.where((reading) {
      return reading.timestamp.isAfter(startOfDay) &&
          reading.timestamp.isBefore(endOfDay);
    }).toList();
  }

  // Get latest reading
  BloodPressureReading? getLatestReading() {
    if (_readings.isEmpty) return null;
    return _readings.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  // Get readings by time of day
  List<BloodPressureReading> getReadingsByDayTime(DayTime dayTime) {
    return _readings.where((reading) => reading.dayTime == dayTime).toList();
  }

  // Get readings by medication status
  List<BloodPressureReading> getReadingsByMedicationStatus(MedicationStatus status) {
    return _readings.where((reading) => reading.medicationStatus == status).toList();
  }
}
