// lib/main.dart

import 'package:flutter/material.dart';
import 'pages/Login/login_screen.dart';

void main() {
  runApp(const SGLApp());
}

class SGLApp extends StatelessWidget {
  const SGLApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AGORA ESTE É O ÚNICO MATERIALAPP COM O TEMA CORRETO
    return MaterialApp(
      title: 'SGI - Sistema de Gestão de Inventário',
      debugShowCheckedModeBanner: false,
      
      // === COLE O SEU TEMA PERSONALIZADO AQUI ===
      theme: ThemeData(
        primaryColor: const Color(0xFF002238),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Cor dos ícones e texto no AppBar
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF002238),
          unselectedItemColor: Colors.grey,
          elevation: 8,
          // Garante que a cor do ícone e label seja a mesma
          type: BottomNavigationBarType.fixed, 
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF002238),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black, fontSize: 18),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // Adicione isso para que os ícones usem a cor primária por padrão
        iconTheme: const IconThemeData(
          color: Color(0xFF002238)
        ),
        // Adicione isso para o FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 199, 232, 255),
          foregroundColor: Color(0xFF002238),
        ),
      ),
      // A tela inicial continua sendo a de Login
      home: const LoginScreen(),
    );
  }
}