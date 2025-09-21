import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulsetrack/providers/app_provider.dart';
import 'package:pulsetrack/providers/theme_provider.dart';
import 'package:pulsetrack/models/index.dart';
import 'package:pulsetrack/screens/home_screen.dart';
import 'package:pulsetrack/screens/dashboard_screen.dart';
import 'package:pulsetrack/screens/profile_screen.dart';
import 'package:pulsetrack/screens/add_reading_screen.dart';
import 'package:pulsetrack/screens/edit_reading_screen.dart';
import 'package:pulsetrack/screens/settings_screen.dart';

void main() {
  runApp(const PulseTrackApp());
}

class PulseTrackApp extends StatelessWidget {
  const PulseTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PulseTrack',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: themeProvider.isDarkMode
                  ? ColorScheme.fromSeed(
                      seedColor: themeProvider.primaryColor,
                      brightness: Brightness.dark,
                      primary: themeProvider.primaryColor,
                      secondary: themeProvider.secondaryColor,
                      tertiary: themeProvider.primaryColor.withValues(alpha: 0.7),
                      surface: const Color(0xFF1E1E1E),
                      background: const Color(0xFF121212),
                      error: const Color(0xFFCF6679),
                      onPrimary: Colors.white,
                      onSecondary: Colors.black,
                      onSurface: Colors.white,
                      onBackground: Colors.white,
                      onError: Colors.black,
                    )
                  : ColorScheme.fromSeed(
                      seedColor: themeProvider.primaryColor,
                      brightness: Brightness.light,
                      primary: themeProvider.primaryColor,
                      secondary: themeProvider.secondaryColor,
                      tertiary: themeProvider.primaryColor.withValues(alpha: 0.7),
                      surface: const Color(0xFFFAFBFF),
                      background: const Color(0xFFFAFBFF),
                      error: const Color(0xFFB00020),
                      onPrimary: Colors.white,
                      onSecondary: Colors.black,
                      onSurface: Colors.black,
                      onBackground: Colors.black,
                      onError: Colors.white,
                    ),
              useMaterial3: themeProvider.useMaterial3,
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 2,
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: themeProvider.isDarkMode
                    ? const Color(0xFF2D2D2D)
                    : Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFF5F5F5),
              ),
            ),
            home: const MainScreen(),
            routes: {
              '/add-reading': (context) => const AddReadingScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/edit-reading') {
                final reading = settings.arguments as BloodPressureReading;
                return MaterialPageRoute(
                  builder: (context) => EditReadingScreen(reading: reading),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/add-reading');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Reading'),
              backgroundColor: Provider.of<ThemeProvider>(context).primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
        );
  }
}
