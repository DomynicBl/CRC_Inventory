import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BarcodeScannerReturnPage extends StatefulWidget {
  const BarcodeScannerReturnPage({super.key});

  @override
  State<BarcodeScannerReturnPage> createState() => _BarcodeScannerReturnPageState();
}

class _BarcodeScannerReturnPageState extends State<BarcodeScannerReturnPage> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessing = false; // Para evitar múltiplos pops

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (_isProcessing) return; // Ignora se já está processando

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? barcodeValue = barcodes.first.rawValue;

      if (barcodeValue != null && barcodeValue.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });
        // Retorna o valor lido para a tela anterior (MachineForm)
        Navigator.pop(context, barcodeValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scanner Indisponível')),
        body: const Center(
          child: Text('Leitura de código de barras não disponível.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Aponte para o Código')),
      body: MobileScanner(
        controller: _cameraController,
        onDetect: _onBarcodeDetect,
      ),
    );
  }
}