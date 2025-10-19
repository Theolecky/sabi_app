import 'package:flutter/material.dart';
import 'desk_view_screen.dart'; // Import the new Desk View screen

class FindASpotScreen extends StatefulWidget {
  const FindASpotScreen({super.key});

  @override
  State<FindASpotScreen> createState() => _FindASpotScreenState();
}

class _FindASpotScreenState extends State<FindASpotScreen> {
  int _selectedIndex = 0;

  // STATE LIFTED: The list of study rooms is now part of the state.
  late List<StudyRoom> _studyRooms;

  @override
  void initState() {
    super.initState();
    // Initialize the list from the static data source.
    _studyRooms = StudyRoomsTab.studyRoomsData;
  }

  // STATE LIFTED: This function will be passed down to update the list.
  void _updateDeskCount(String roomName) {
    setState(() {
      final roomIndex = _studyRooms.indexWhere((room) => room.name == roomName);
      if (roomIndex != -1) {
        final room = _studyRooms[roomIndex];
        if (room.availableDesks > 0) {
          _studyRooms[roomIndex] = StudyRoom(
            name: room.name,
            location: room.location,
            totalDesks: room.totalDesks,
            availableDesks: room.availableDesks - 1, // Decrement the count
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pass the state down to the widget tabs.
    final List<Widget> widgetOptions = <Widget>[
      StudyRoomsTab(
        studyRooms: _studyRooms,
        onSpotBooked: _updateDeskCount, // Pass the callback
      ),
      const LectureHallsTab(),
      const OtherSpotsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Spot'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chair_outlined),
            label: 'Study Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            label: 'Lecture Halls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.deck_outlined),
            label: 'Other Spots',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// --- Data Models ---
class StudyRoom {
  final String name;
  final String location;
  final int totalDesks;
  final int availableDesks;

  const StudyRoom({
    required this.name,
    required this.location,
    required this.totalDesks,
    required this.availableDesks,
  });
}

class Classroom {
  final String name;
  final String location;
  final bool isAvailable;
  final String details;

  const Classroom({
    required this.name,
    required this.location,
    required this.isAvailable,
    required this.details,
  });
}

// --- Study Rooms Tab ---
class StudyRoomsTab extends StatelessWidget {
  // It now receives the list and callback function from its parent.
  final List<StudyRoom> studyRooms;
  final Function(String) onSpotBooked;

  const StudyRoomsTab({super.key, required this.studyRooms, required this.onSpotBooked});

  // The static data is still here to be used for initialization.
  static final List<StudyRoom> studyRoomsData = [
    const StudyRoom(name: 'The Quiet Pod', location: 'Innovation Hub', totalDesks: 7, availableDesks: 7),
    const StudyRoom(name: 'Study Room A', location: 'Central Building, Floor 1', totalDesks: 8, availableDesks: 5),
    const StudyRoom(name: 'Study Room B', location: 'Central Building, Floor 2', totalDesks: 10, availableDesks: 2),
    const StudyRoom(name: 'Study Room C', location: 'Central Building, Floor 2', totalDesks: 6, availableDesks: 0),
    const StudyRoom(name: 'Study Room D', location: 'Central Building, Floor 2', totalDesks: 4, availableDesks: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final availableRooms = studyRooms.where((room) => room.availableDesks > 0).toList();
    final fullRooms = studyRooms.where((room) => room.availableDesks == 0).toList();
    final totalAvailableDesks = availableRooms.fold(0, (sum, room) => sum + room.availableDesks);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          '🟢 $totalAvailableDesks Desks Available Across ${availableRooms.length} Rooms',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        ...availableRooms.map((room) => _buildStudyRoomCard(context, room)),
        if (fullRooms.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            '--- Full Rooms ---',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...fullRooms.map((room) => _buildStudyRoomCard(context, room)),
        ],
      ],
    );
  }

  Widget _buildStudyRoomCard(BuildContext context, StudyRoom room) {
    final bool isAvailable = room.availableDesks > 0;
    final String availabilityText = '${room.availableDesks} of ${room.totalDesks} desks available';
    final Color statusColor = room.availableDesks > 4 ? Colors.green : (room.availableDesks > 0 ? Colors.orange : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(room.location),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(availabilityText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            if (isAvailable) const SizedBox(width: 8),
            if (isAvailable) const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: isAvailable
            ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeskViewScreen(studyRoom: room, onSpotBooked: onSpotBooked)),
                );
                if (result != null && result is String) {
                  Navigator.pop(context, result);
                }
              }
            : null,
      ),
    );
  }
}

// --- Lecture Halls Tab ---
class LectureHallsTab extends StatelessWidget {
  const LectureHallsTab({super.key});

  // RESTORED: Dummy data for classrooms
  static final List<Classroom> classrooms = [
    const Classroom(name: 'A-203', location: 'Main Lecture Hall 1', isAvailable: true, details: 'Available until 5:00 PM'),
    const Classroom(name: 'F-307', location: 'Small Classroom', isAvailable: true, details: 'Available until 6:00 PM'),
    const Classroom(name: 'Robotics Lab', location: 'Robotics Lab', isAvailable: true, details: 'Available all day'),
    const Classroom(name: 'F-309', location: 'Small Classroom', isAvailable: true, details: 'Available until 5:30 PM'),
    const Classroom(name: 'F-203', location: 'Main Lecture Hall 2', isAvailable: false, details: 'In Use (Foundations of Enterpreneurship) - Free at 4:30 PM'),
    const Classroom(name: 'F-205', location: 'Main Lecture Hall 3', isAvailable: false, details: 'In Use (Introduction to Infosec) - Free at 5:00 PM'),
    const Classroom(name: 'Distance Learning', location: 'Distance Learning', isAvailable: false, details: 'In Use (DIAML) - Free at 6:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    final availableRooms = classrooms.where((c) => c.isAvailable).toList();
    final inUseRooms = classrooms.where((c) => !c.isAvailable).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          '🟢 ${availableRooms.length} Rooms Available Now',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        ...availableRooms.map((room) => _buildClassroomCard(context, room)),
        if (inUseRooms.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('--- In Use ---', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          ...inUseRooms.map((room) => _buildClassroomCard(context, room)),
        ],
      ],
    );
  }

  Widget _buildClassroomCard(BuildContext context, Classroom room) {
    final Color statusColor = room.isAvailable ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text('${room.name} (${room.location})', style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          room.details,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// --- Other Spots Tab ---
class OtherSpotsTab extends StatelessWidget {
  const OtherSpotsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // RESTORED: UI for other spots
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildOtherSpotCard(context, 'Library Commons', 'First Floor', '🟢 Several spots available', Colors.green),
        _buildOtherSpotCard(context, 'Cafeteria Corner', 'Near window', '🟡 Limited spots available', Colors.orange),
      ],
    );
  }

  Widget _buildOtherSpotCard(BuildContext context, String name, String location, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

