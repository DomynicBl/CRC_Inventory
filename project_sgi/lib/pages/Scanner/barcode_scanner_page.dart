import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String? barcode;
  bool _alreadyScanned = false;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: const Center(
          child: Text(
            'Leitura de código de barras não disponível no navegador.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Escaneando...')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: MobileScannerController(),
              onDetect: (capture) {
                if (_alreadyScanned) return;

                final barcodeValue = capture.barcodes.first.rawValue;
                if (barcodeValue != null) {
                  _alreadyScanned = true;

                  setState(() {
                    barcode = barcodeValue;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Código: $barcodeValue')),
                  );

                  // Se quiser voltar para outra tela automaticamente:
                  // Future.delayed(Duration(seconds: 1), () {
                  //   Navigator.pop(context, barcodeValue);
                  // });
                }
              },
            ),
          ),
          if (barcode != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Resultado: $barcode'),
            ),
        ],
      ),
    );
  }
}
