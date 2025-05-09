import 'package:flutter/material.dart';
import 'pages/Login/login_screen.dart';
import 'database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SembastService().init();
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