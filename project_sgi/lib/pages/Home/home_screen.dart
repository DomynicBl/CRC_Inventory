import 'package:flutter/material.dart';
import '../Machines/machine_form.dart'; // import do formulário de cadastro de máquinas

/* IMPORTAÇÃO DE TELAS DA HOME */
import '../Map/map_page.dart'; // importa tela do mapa
import '../Scanner/barcode_scanner_page.dart'; // import da tela de leitor de código de barras
import 'profile_page.dart'; // importa tela de usuário
import 'last_machines_list.dart'; // import da tela das últimas máquinas adicionadas

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventário de Máquinas',
      theme: ThemeData(
        primaryColor: const Color(0xFF002238),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF002238),
          unselectedItemColor: Colors.grey,
          elevation: 8,
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
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Painel de Inventário',
    'Procurar',
    'BarCode',
    'Perfil',
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Abre o formulário e, ao retornar, forçar rebuild
  void _abrirFormulario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MachineForm()),
    ).then((_) {
      if (_selectedIndex == 0) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeContent(), // nova instância sempre
      MapScreen(),
      BarcodeScannerPage(),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions:
            _selectedIndex == 0
                ? [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ]
                : null,
      ),
      body: pages[_selectedIndex],
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: _abrirFormulario,
                tooltip: 'Adicionar Máquina',
                backgroundColor: const Color.fromARGB(255, 199, 232, 255),
                foregroundColor: const Color(0xFF002238),
                child: const Icon(Icons.add, size: 28),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.barcode_reader),
            label: 'Pesquisa',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return LastMachineList();
  }
}

// ignore: unused_element
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF002238).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 32, color: const Color(0xFF0066FF)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
