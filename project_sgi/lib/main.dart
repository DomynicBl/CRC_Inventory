import 'package:flutter/material.dart';
import 'pages/Login/login_screen.dart';

// Banco de imagens
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'SUA_SUPABASE_URL',
    anonKey: 'SUA_SUPABASE_ANON_KEY',
  );
  runApp(const SGLApp());
}

class SGLApp extends StatelessWidget {
  const SGLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGI - Sistema de Gestão de Inventário',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
