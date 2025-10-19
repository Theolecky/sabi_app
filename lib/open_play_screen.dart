import 'package:flutter/material.dart';

// --- Data Models ---
enum GameSport { basketball, volleyball, soccer }
enum SessionStatus { open, proposed, confirmed }

class GameSession {
  final String timeSlot;
  SessionStatus status;
  GameSport? sport;
  int currentPlayers;
  int requiredPlayers;

  GameSession({
    required this.timeSlot,
    this.status = SessionStatus.open,
    this.sport,
    this.currentPlayers = 0,
    this.requiredPlayers = 0,
  });
}

// --- Main Court Schedule Screen ---
class CourtScheduleScreen extends StatefulWidget {
  const CourtScheduleScreen({super.key});

  @override
  State<CourtScheduleScreen> createState() => _CourtScheduleScreenState();
}

class _CourtScheduleScreenState extends State<CourtScheduleScreen> {
  final List<GameSession> _sessions = [
    GameSession(timeSlot: '2:00 PM - 3:00 PM', status: SessionStatus.open),
    GameSession(timeSlot: '3:00 PM - 4:00 PM', status: SessionStatus.proposed, sport: GameSport.basketball, currentPlayers: 2, requiredPlayers: 6),
    GameSession(timeSlot: '4:00 PM - 5:00 PM', status: SessionStatus.confirmed, sport: GameSport.soccer, currentPlayers: 10, requiredPlayers: 10),
    GameSession(timeSlot: '5:00 PM - 6:00 PM', status: SessionStatus.open),
  ];

  void _updateSession(int index, GameSession updatedSession) {
    setState(() {
      _sessions[index] = updatedSession;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Schedule'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return _buildSessionCard(context, session, index);
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, GameSession session, int index) {
    IconData icon;
    String title;
    Color color;
    Widget trailing;

    switch (session.status) {
      case SessionStatus.open:
        icon = Icons.add_circle_outline;
        title = 'Open Slot';
        color = Colors.green;
        trailing = const Icon(Icons.arrow_forward_ios, size: 16);
        break;
      case SessionStatus.proposed:
        icon = _getSportIcon(session.sport!);
        title = 'Proposed: ${_getSportName(session.sport!)}';
        color = Colors.orange;
        trailing = Text(
          '${session.currentPlayers}/${session.requiredPlayers} Joined',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        );
        break;
      case SessionStatus.confirmed:
        icon = _getSportIcon(session.sport!);
        title = 'Confirmed: ${_getSportName(session.sport!)}';
        color = Colors.blue;
        trailing = const Text('Game On!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue));
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(session.timeSlot),
        trailing: trailing,
        onTap: () async {
          if (session.status == SessionStatus.open) {
            final GameSport? selectedSport = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProposeGameScreen(timeSlot: session.timeSlot)),
            );
            if (selectedSport != null) {
              session.sport = selectedSport;
              session.status = SessionStatus.proposed;
              session.currentPlayers = 1;
              session.requiredPlayers = selectedSport == GameSport.basketball ? 6 : (selectedSport == GameSport.soccer ? 10 : 4);
              _updateSession(index, session);
            }
          } else if (session.status == SessionStatus.proposed) {
            final bool? joined = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JoinGameScreen(session: session)),
            );
            if (joined == true && session.currentPlayers < session.requiredPlayers) {
              session.currentPlayers++;
              if (session.currentPlayers == session.requiredPlayers) {
                session.status = SessionStatus.confirmed;
              }
              _updateSession(index, session);
            }
          }
        },
      ),
    );
  }

  IconData _getSportIcon(GameSport sport) {
    switch (sport) {
      case GameSport.basketball:
        return Icons.sports_basketball;
      case GameSport.volleyball:
        return Icons.sports_volleyball;
      case GameSport.soccer:
        return Icons.sports_soccer;
    }
  }

    String _getSportName(GameSport sport) {
    switch (sport) {
      case GameSport.basketball:
        return 'Basketball';
      case GameSport.volleyball:
        return 'Volleyball';
      case GameSport.soccer:
        return 'Soccer';
    }
  }
}

// --- Propose a Game Screen ---
class ProposeGameScreen extends StatelessWidget {
  final String timeSlot;
  const ProposeGameScreen({super.key, required this.timeSlot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propose a Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Time: $timeSlot',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              'Select a Sport:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildSportButton(context, 'Basketball', GameSport.basketball, Icons.sports_basketball),
            const SizedBox(height: 16),
            _buildSportButton(context, 'Volleyball', GameSport.volleyball, Icons.sports_volleyball),
            const SizedBox(height: 16),
            _buildSportButton(context, 'Soccer', GameSport.soccer, Icons.sports_soccer),
          ],
        ),
      ),
    );
  }

  Widget _buildSportButton(BuildContext context, String label, GameSport sport, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        Navigator.pop(context, sport);
      },
    );
  }
}

// --- Join a Game Screen ---
class JoinGameScreen extends StatelessWidget {
  final GameSession session;
  const JoinGameScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sport: ${session.sport.toString().split('.').last}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Time: ${session.timeSlot}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            Text(
              'Players Joined: ${session.currentPlayers} / ${session.requiredPlayers}',
              style: const TextStyle(fontSize: 24, color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Needs ${session.requiredPlayers - session.currentPlayers} more player(s) to be confirmed.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("I'm In! 👍"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

