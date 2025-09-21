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
import 'package:pulsetrack/screens/ui_components.dart';

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
              useMaterial3: themeProvider.useMaterial3,
              // Modern color scheme with soft, minimalist colors
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeProvider.primaryColor,
                brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
                primary: themeProvider.primaryColor,
                secondary: themeProvider.secondaryColor,
                surface: themeProvider.surfaceColor,
                background: themeProvider.surfaceColor,
                onPrimary: Colors.white,
                onSecondary: themeProvider.textColor,
                onSurface: themeProvider.textColor,
                onBackground: themeProvider.textColor,
              ),
              // Modern typography
              textTheme: TextTheme(
                headlineLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                  letterSpacing: -0.5,
                ),
                headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
                headlineSmall: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textColor,
                ),
                titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textColor,
                ),
                titleMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textColor,
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  color: themeProvider.textColor,
                  height: 1.5,
                ),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  color: themeProvider.textColor,
                  height: 1.4,
                ),
                bodySmall: TextStyle(
                  fontSize: 12,
                  color: themeProvider.subtleTextColor,
                ),
              ),
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: themeProvider.textColor,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              // Modern card theme
              cardTheme: CardTheme(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: themeProvider.cardColor,
                surfaceTintColor: Colors.transparent,
              ),
              // Clean elevated button theme
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: themeProvider.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              // Modern input decoration
              inputDecorationTheme: InputDecorationTheme(
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: themeProvider.subtleTextColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: themeProvider.primaryColor,
                    width: 2,
                  ),
                ),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                labelStyle: TextStyle(
                  color: themeProvider.subtleTextColor,
                  fontSize: 16,
                ),
                hintStyle: TextStyle(
                  color: themeProvider.subtleTextColor,
                  fontSize: 16,
                ),
              ),
              // Modern FAB theme
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? AddReadingFAB(
              onPressed: () {
                Navigator.pushNamed(context, '/add-reading');
              },
            )
          : null,
    );
  }
}
