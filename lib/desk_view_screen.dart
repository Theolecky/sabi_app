import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'find_a_spot_screen.dart'; // We need the StudyRoom model
import 'active_session_screen.dart'; // We need to navigate here

class DeskViewScreen extends StatelessWidget {
  final StudyRoom studyRoom;
  // This callback is passed down to notify the parent when a spot is booked.
  final Function(String) onSpotBooked;

  const DeskViewScreen({
    super.key,
    required this.studyRoom,
    required this.onSpotBooked,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy data for desk statuses
    final List<bool> deskAvailability = List.generate(studyRoom.totalDesks, (index) => index < studyRoom.availableDesks);
    deskAvailability.shuffle(); // Randomize which desks are available

    return Scaffold(
      appBar: AppBar(
        title: Text(studyRoom.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please tap an available (🟢) desk to scan the QR code and claim your spot.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 desks per row
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: studyRoom.totalDesks,
                itemBuilder: (context, index) {
                  final deskId = '${studyRoom.name.substring(0, 1)}-${index + 1}';
                  final isAvailable = deskAvailability[index];
                  return _buildDeskIcon(
                    context: context,
                    deskId: deskId,
                    isAvailable: isAvailable,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeskIcon({
    required BuildContext context,
    required String deskId,
    required bool isAvailable,
  }) {
    return InkWell(
      onTap: !isAvailable
          ? null // Disable tap if desk is not available
          : () async {
              // Trigger the scan
              final bool? scanSuccess = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerScreen()),
              );

              // If scan was successful, book the spot and navigate
              if (scanSuccess == true && context.mounted) {
                // 1. Update the state in the parent widget
                onSpotBooked(studyRoom.name);

                // 2. Navigate to the Active Session screen
                final result = await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveSessionScreen(deskId: deskId, roomName: studyRoom.name),
                  ),
                );
                 if (result != null && result is String && context.mounted) {
                  Navigator.pop(context, result);
                }
              }
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isAvailable ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAvailable ? Colors.green : Colors.red,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(deskId, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Icon(
              Icons.chair,
              color: isAvailable ? Colors.green : Colors.red,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

