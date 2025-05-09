// Flutter
import 'package:flutter/material.dart';

// Screen
import 'pages/Login/login_screen.dart';

// Database
import 'database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
  runApp(const SGLApp());
}

class SGLApp extends StatelessWidget {
  const SGLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGI - Sistema de Gestão de Inventário',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}