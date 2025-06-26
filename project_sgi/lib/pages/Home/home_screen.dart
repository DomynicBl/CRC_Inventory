import 'package:flutter/material.dart';
import '../Machines/machine_form.dart'; // Import do formulário de cadastro de máquinas

/* IMPORTAÇÃO DE TELAS DA HOME */
import '../Map/map_page.dart'; // Importa tela do mapa
import '../Scanner/barcode_scanner_page.dart'; // Import da tela de leitor de código de barras
import 'profile_page.dart'; // Importa tela de usuário
import 'last_machines_list.dart'; // Import da tela das últimas máquinas adicionadas

// O widget 'MyApp' que continha um MaterialApp foi removido.
// A navegação agora deve ir diretamente para a HomePage a partir do LoginScreen.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Títulos para cada aba da BottomNavigationBar
  final List<String> _titles = [
    'Painel de Inventário',
    'Mapa do Campus', // Título mais descritivo para a tela do mapa
    'Leitor de Código', // Título mais descritivo para o scanner
    'Perfil do Usuário', // Título mais descritivo
  ];

  // Função para atualizar o índice da aba selecionada
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função para abrir o formulário de cadastro de máquina
  // Ao fechar o formulário, força a reconstrução da lista se a aba "Início" estiver selecionada.
  void _abrirFormulario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MachineForm()),
    ).then((result) {
      // Verifica se a tela inicial está ativa e se houve um resultado (opcional)
      // para recarregar a lista.
      if (_selectedIndex == 0) {
        setState(() {
          // A reconstrução do HomeContent (que contém LastMachineList)
          // buscará os dados mais recentes.
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista de páginas para a navegação
    // É importante que não sejam 'const' se precisarem ser reconstruídas
    final pages = <Widget>[
      HomeContent(),
      const MapScreen(),
      const BarcodeScannerPage(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        // O título muda dinamicamente com base na aba selecionada
        title: Text(
          _titles[_selectedIndex],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
        ),
        centerTitle: false,
        // Mostra o ícone de notificações apenas na tela inicial
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28),
                  onPressed: () {
                    // TODO: Implementar lógica de notificações
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      // Mostra o botão flutuante apenas na tela inicial
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _abrirFormulario,
              tooltip: 'Adicionar Máquina',
              // As cores agora são herdadas do FloatingActionButtonTheme em main.dart
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        // O tipo 'fixed' garante que o fundo não mude de cor e os itens fiquem alinhados
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// O conteúdo principal da aba 'Início'.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Este widget agora é reconstruído quando setState é chamado na HomePage,
    // o que por sua vez reconstrói LastMachineList, atualizando os dados.
    return const LastMachineList();
  }
}