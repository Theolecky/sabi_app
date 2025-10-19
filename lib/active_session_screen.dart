import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart'; // Import to navigate back to HomeDashboard

class ActiveSessionScreen extends StatefulWidget {
  final String deskId;
  final String roomName;

  const ActiveSessionScreen({
    super.key,
    required this.deskId,
    required this.roomName,
  });

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late Timer _sessionTimer;
  Timer? _holdTimer;

  Duration _sessionDuration = const Duration(hours: 2);
  Duration _holdDuration = const Duration(minutes: 60);
  bool _isOnHold = false;

  @override
  void initState() {
    super.initState();
    startSessionTimer();
  }

  void startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _sessionDuration.inSeconds > 0) {
        setState(() {
          _sessionDuration = _sessionDuration - const Duration(seconds: 1);
        });
      } else {
        _sessionTimer.cancel();
        if (mounted) {
           _autoCheckOut();
        }
      }
    });
  }
  
  void startHoldTimer() {
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _holdDuration.inSeconds > 0) {
        setState(() {
          _holdDuration = _holdDuration - const Duration(seconds: 1);
        });
      } else {
        _holdTimer?.cancel();
        if(mounted){
          setState(() {
            _isOnHold = false;
          });
          startSessionTimer(); // Resume session timer
        }
      }
    });
  }


  @override
  void dispose() {
    _sessionTimer.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _toggleHold() {
    setState(() {
      _isOnHold = !_isOnHold;
      if (_isOnHold) {
        _sessionTimer.cancel();
        _holdDuration = const Duration(minutes: 60); // Reset hold timer
        startHoldTimer();
      } else {
        _holdTimer?.cancel();
        startSessionTimer();
      }
    });
  }
  
  void _checkOut() {
    final newStatus = 'You checked out from ${widget.roomName}, Desk ${widget.deskId}.';
    if (mounted) {
       Navigator.of(context).popUntil((route) => route.isFirst);
       Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => const HomeDashboard(),
          settings: RouteSettings(arguments: newStatus)
        )
      );
    }
  }

  void _autoCheckOut() {
    final newStatus = 'Your session at ${widget.roomName}, Desk ${widget.deskId} expired.';
     if (mounted) {
       Navigator.of(context).popUntil((route) => route.isFirst);
       Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => const HomeDashboard(),
          settings: RouteSettings(arguments: newStatus)
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerDuration = _isOnHold ? _holdDuration : _sessionDuration;
    final timerTitle = _isOnHold ? 'Spot on Hold for' : 'Session Ends in';
    final mainButton = _isOnHold
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Resume Session'),
            onPressed: _toggleHold,
          )
        : ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            icon: const Icon(Icons.pause_circle_outline),
            label: const Text('Hold My Spot (60 Mins)'),
            onPressed: _toggleHold,
          );


    return WillPopScope(
      onWillPop: () async {
        // Prevent the user from accidentally swiping back.
        // They must use the Check Out button.
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("You're Checked In! ✅"),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your Spot: ${widget.roomName}, Desk ${widget.deskId}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Text(
                timerTitle,
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              Text(
                _formatDuration(timerDuration),
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              mainButton,
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.logout),
                label: const Text('Check Out Now'),
                onPressed: _checkOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

