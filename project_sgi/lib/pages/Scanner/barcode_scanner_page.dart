/* IMPORTS FLUTTER */
import 'package:flutter/material.dart';
// Scanner
import 'package:mobile_scanner/mobile_scanner.dart';
// verificar se esta rodando WEB
import 'package:flutter/foundation.dart' show kIsWeb;

/* IMPORTS APP */
// BD online
import '../../api/machine_service.dart';
// Resultados de Pesquisa
import '../search/search_result.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true; // Começa no modo de escaneamento
  String? _scannedBarcodeValue;
  List<Map<String, dynamic>> _foundMachines = [];
  String _searchMessage = ''; // Para feedback da busca: "Buscando...", "Nenhum resultado", "Erro"

  @override
  void initState() {
    super.initState();
    // O cameraController é inicializado na declaração do campo.
    // Se precisar de lógica de inicialização mais complexa, mova para cá.
  }

  @override
  void dispose() {
    cameraController.dispose(); // Importante para liberar a câmera
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (!_isScanning) return; // Se não está escaneando, ignora novas detecções

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? barcodeValue = barcodes.first.rawValue;
      if (barcodeValue != null && barcodeValue.isNotEmpty) {
        // Para de escanear (logicamente) e inicia a busca
        setState(() {
          _isScanning = false;
          _scannedBarcodeValue = barcodeValue;
        });
        _performSearchWithBarcode(barcodeValue);
      }
    }
  }

  Future<void> _performSearchWithBarcode(String patrimonio) async {
    // Esconde o teclado se estiver aberto
    FocusScope.of(context).unfocus();

    setState(() {
      _searchMessage = 'Buscando patrimônio: $patrimonio...';
      _foundMachines = []; // Limpa resultados anteriores
    });

    try {
      final machineService = MachineService();
      final machines = await machineService.getByPatrimonioParcial(patrimonio);
      setState(() {
        _foundMachines = machines;
        if (machines.isEmpty) {
          _searchMessage = 'Nenhum resultado encontrado para o patrimônio lido';
        } else {
          _searchMessage = ''; // Limpa a mensagem se encontrou resultados
        }
      });
    } catch (e) {
      setState(() {
        _searchMessage = 'Erro ao buscar: ${e.toString()}';
        _foundMachines = [];
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _scannedBarcodeValue = null;
      _foundMachines = [];
      _searchMessage = '';
      // O MobileScanner será reconstruído quando _isScanning mudar para true,
      // o que deve reiniciar a detecção.
      // Se a câmera não reiniciar automaticamente, você pode tentar:
      // if (!cameraController.isStarting) {
      //   cameraController.start();
      // }
      // Ou recriar o controller (menos ideal se não for necessário):
      // cameraController.dispose();
      // cameraController = MobileScannerController();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scanner Indisponível')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Leitura de código de barras não disponível no navegador.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isScanning
            ? 'Escaneando Código...'
            : 'Escaneado com Sucesso!'),
      ),
      body: Column(
        children: [
          if (_isScanning)
            Expanded(
              child: MobileScanner(
                controller: cameraController,
                onDetect: _onBarcodeDetect,
                // allowDuplicates: false, // Para detectar cada código apenas uma vez até resetar
              ),
            )
          else
            Expanded(child: _buildResultView()), // Área de resultados ocupa o espaço
        ],
      ),
    );
  }

  Widget _buildResultView() {
    Widget resultDisplayArea;

    // 1. Mostra indicador de carregamento durante a busca
    if (_searchMessage.startsWith('Buscando patrimônio:')) {
      resultDisplayArea = const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // 2. Mostra mensagem de erro
    else if (_searchMessage.startsWith('Erro:')) {
      resultDisplayArea = Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _searchMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    // 3. Mostra mensagem de "Nenhum resultado"
    // (Verifica _foundMachines.isEmpty e se uma busca foi feita _scannedBarcodeValue != null)
    else if (_foundMachines.isEmpty && _scannedBarcodeValue != null) {
      resultDisplayArea = Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              // Usa _searchMessage se já estiver formatada (ex: "Nenhum resultado para: X")
              // Senão, cria uma mensagem padrão.
              _searchMessage.isNotEmpty && _searchMessage.contains(_scannedBarcodeValue!)
                  ? _searchMessage
                  : 'Nenhum resultado para: $_scannedBarcodeValue',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    // 4. Mostra a lista de máquinas encontradas
    else if (_foundMachines.isNotEmpty) {
      // SearchResultWidget já tem um Expanded interno, então ele preencherá o espaço.
      resultDisplayArea = SearchResultWidget(
        machines: _foundMachines,
        searchTerm: _scannedBarcodeValue ?? '',
        onUpdate: () {
          // Callback para o MachineCard: se algo for atualizado, refaz a busca atual.
          if (_scannedBarcodeValue != null) {
            _performSearchWithBarcode(_scannedBarcodeValue!);
          }
        },
      );
    }
    // 5. Estado inicial ou inesperado (antes da primeira busca bem-sucedida ou erro)
    else {
      resultDisplayArea = const Expanded(child: SizedBox.shrink());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear Novamente'),
            onPressed: _resetScanner,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48), // Botão mais alto
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        if (_scannedBarcodeValue != null && !_isScanning) // Mostra o código lido apenas se não estiver escaneando
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Código Lido: $_scannedBarcodeValue',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        resultDisplayArea,
      ],
    );
  }
}