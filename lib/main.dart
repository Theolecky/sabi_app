import 'package:flutter/material.dart';
import 'find_a_spot_screen.dart';
import 'open_play_screen.dart';
import 'active_session_screen.dart'; // Import for passing arguments

// This is the main entry point for the Sabi app.
void main() {
  runApp(const SabiApp());
}

class SabiApp extends StatelessWidget {
  const SabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabi',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
      ),
      home: const HomeDashboard(),
    );
  }
}

// WIREFRAME 1: The Home Dashboard
// This is a StatefulWidget to manage the active session status.
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // This variable holds the status and will be updated.
  String _activeSessionStatus = 'No active session. Find a spot to get started!';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we are returning from the ActiveSessionScreen with a status
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      // Use post-frame callback to avoid calling setState during a build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSessionStatus(args);
      });
    }
  }

  // This function handles the result that comes back from the Find a Spot journey.
  void _updateSessionStatus(String? newStatus) {
    setState(() {
      _activeSessionStatus = newStatus ?? 'No active session. Find a spot to get started!';
    });
  }

  // NEW: Function to get a greeting based on the time of day.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 18) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sabi',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              // UPDATED: The greeting is now dynamic.
              Text(
                '${_getGreeting()}, Student! 👋',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildLargeButton(
                context: context,
                icon: Icons.school_outlined,
                label: 'Find a Study Spot',
                onPressed: () async {
                  // We 'await' the result from the FindASpotScreen.
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FindASpotScreen()),
                  );
                  // If the user checked out, the result will be a string.
                  if (result != null && result is String) {
                    _updateSessionStatus(result);
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildLargeButton(
                context: context,
                icon: Icons.sports_basketball_outlined,
                label: 'Join a Game',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CourtScheduleScreen()),
                  );
                },
              ),
              const Spacer(),
              // The status card now displays the state variable.
              _buildStatusCard(
                status: _activeSessionStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildStatusCard({required String status}) {
    return Container(
       padding: const EdgeInsets.all(16.0),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.grey[200]!)
       ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YOUR STATUS:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
  }
}

