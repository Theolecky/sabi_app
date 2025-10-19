import 'package:flutter/material.dart';
import 'dart:async';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  @override
  void initState() {
    super.initState();
    _simulateScan();
  }

  // This function simulates scanning a QR code.
  void _simulateScan() {
    Timer(const Duration(seconds: 2), () {
      // On success, we just pop the screen and return 'true'.
      // The previous screen (DeskViewScreen) will handle the navigation.
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning...'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Simulating QR Code Scan',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

