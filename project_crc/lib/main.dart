import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_screen.dart';

void main(){
  runApp(const SGLApp());
}

class SGLApp extends StatelessWidget {
  const SGLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGI - Sistema de Gestão de Inventário',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}