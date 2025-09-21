# 🩺 PulseTrack

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-green.svg)]()
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)]()

**Personal blood pressure monitoring app with analytics and insights.**

PulseTrack is a comprehensive Flutter application designed to help users track, monitor, and analyze their blood pressure readings over time. With an intuitive interface and powerful analytics, users can maintain better control over their cardiovascular health.

## ✨ Features

### 📊 Core Functionality
- **Blood Pressure Tracking** - Log systolic, diastolic, and pulse readings with timestamps
- **Historical Data** - View comprehensive history of all readings
- **Analytics Dashboard** - Visual charts and trends analysis
- **Data Export** - Export data to PDF and Excel formats
- **User Profiles** - Support for multiple user profiles
- **Settings & Customization** - Theme preferences and app configuration

### 📈 Analytics & Insights
- **Trend Analysis** - Visual representation of blood pressure trends over time
- **Statistics** - Average, minimum, maximum values with date ranges
- **Charts & Graphs** - Interactive charts using FL Chart library
- **Health Categories** - Automatic categorization (Normal, Elevated, Hypertension)

### 🎨 User Experience
- **Modern UI** - Clean, intuitive Material Design interface
- **Multi-Platform** - Works on Android, iOS, Web, Windows, macOS, and Linux
- **Responsive Design** - Optimized for different screen sizes
- **Dark/Light Theme** - Automatic theme switching with manual override
- **Icon Integration** - Beautiful icons using HugeIcons library

### 💾 Data Management
- **Local Storage** - SQLite database for offline functionality
- **Data Export** - Generate PDF reports and Excel spreadsheets
- **Data Import** - Easy data backup and restore functionality
- **Privacy First** - All data stored locally, no cloud dependency

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio or VS Code with Flutter extensions

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/airiermonster/pulsetrack.git
   cd pulsetrack
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run

   # For Web
   flutter run -d chrome

   # For Desktop (Windows/macOS/Linux)
   flutter run -d windows  # or macos/linux
   ```

## 📱 Usage

### Getting Started
1. **Launch the app** - Open PulseTrack on your device
2. **Add Your First Reading** - Tap the "+" button to log your first blood pressure reading
3. **View Dashboard** - Check the main dashboard for trends and analytics
4. **Explore Features** - Navigate through different sections to explore all capabilities

### Main Screens
- **Home Screen** - Quick access to recent readings and daily summary
- **Add Reading** - Form to input new blood pressure measurements
- **Dashboard** - Comprehensive analytics and trend visualization
- **Readings Table** - Complete history in tabular format
- **Profile** - User profile management
- **Settings** - App configuration and preferences

### Data Entry
- **Systolic Pressure** - Upper number in blood pressure reading
- **Diastolic Pressure** - Lower number in blood pressure reading
- **Pulse Rate** - Heart rate in beats per minute
- **Notes** - Optional additional information
- **Timestamp** - Automatic or manual time selection

## 🛠️ Technical Stack

### Core Technologies
- **Framework**: Flutter 3.8.1
- **Language**: Dart
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **UI Framework**: Material Design

### Dependencies
- **Charts**: `fl_chart: ^0.68.0` - Data visualization
- **Database**: `sqflite: ^2.3.0` - Local database
- **Icons**: `hugeicons: ^0.0.2` - Icon library
- **Export**: `syncfusion_flutter_pdf: ^25.1.42` - PDF generation
- **Export**: `syncfusion_flutter_xlsio: ^25.1.42` - Excel generation
- **Storage**: `shared_preferences: ^2.2.3` - Settings storage
- **Date/Time**: `flutter_datetime_picker_plus: ^2.2.0` - Date/time selection
- **File System**: `path_provider: ^2.1.3` - File system access

### Architecture
- **MVVM Pattern** - Model-View-ViewModel architecture
- **Provider Pattern** - State management with ChangeNotifier
- **Repository Pattern** - Data access layer abstraction
- **Service Layer** - Business logic separation

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── blood_pressure_reading.dart
│   ├── user_profile.dart
│   └── index.dart
├── providers/                   # State management
│   ├── app_provider.dart
│   └── theme_provider.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_reading_screen.dart
│   ├── readings_table_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   └── ...
├── services/                    # Business logic
│   ├── database_service.dart
│   └── export_service.dart
└── ...
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines
- Follow the existing code style and architecture
- Write clear commit messages
- Add tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📊 Screenshots

*Add screenshots of your app here*

### Home Screen
<img src="screenshots/home_screen.png" width="300" alt="Home Screen">

### Dashboard
<img src="screenshots/dashboard.png" width="300" alt="Dashboard">

### Add Reading
<img src="screenshots/add_reading.png" width="300" alt="Add Reading">

## 🔄 Version History

### Version 1.0.0
- Initial release
- Core blood pressure tracking functionality
- Basic analytics and dashboard
- Multi-platform support
- Data export capabilities

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Check the existing documentation
- Review the code comments

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Icons provided by [HugeIcons](https://hugeicons.com/)
- Charts powered by [FL Chart](https://pub.dev/packages/fl_chart)
- Export functionality by [Syncfusion](https://www.syncfusion.com/)

---

**Made with ❤️ for better health monitoring**

*For educational and personal use. Always consult with healthcare professionals for medical advice.*
