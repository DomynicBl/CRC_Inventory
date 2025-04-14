import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click, // 👈 Cursor alterado aqui
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 5.0,
            child: Image.asset(
              'assets/images/mapaPuc.jpeg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
