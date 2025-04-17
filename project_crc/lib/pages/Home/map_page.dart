import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<MapMarker> markers = [
    MapMarker(
      number: 1,
      x: 0.3, // 30% da largura da imagem
      y: 0.4, // 40% da altura da imagem
    ),
    MapMarker(
      number: 2,
      x: 0.7, // 70% da largura da imagem
      y: 0.6, // 60% da altura da imagem
    ),
  ];

  late Future<Size> imageSize;

  @override
  void initState() {
    super.initState();
    imageSize = _getImageSize();
  }

  Future<Size> _getImageSize() async {
    final data = await rootBundle.load('assets/images/mapaPuc.jpeg');
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Size>(
        future: imageSize,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final size = snapshot.data!;
          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              child: LayoutBuilder(
  builder: (context, constraints) {
    final renderedWidth = constraints.maxWidth;
    final renderedHeight = constraints.maxHeight;

    return Stack(
      children: [
        Image.asset(
          'assets/images/mapaPuc.jpeg',
          width: renderedWidth,
          height: renderedHeight,
          fit: BoxFit.contain,
        ),
        ...markers.map((marker) => _buildMarker(marker, size, constraints)),
      ],
    );
  },
)


            ),
          );
        },
      ),
    );
  }

 Widget _buildMarker(MapMarker marker, Size originalImageSize, BoxConstraints constraints) {
  final renderedAspectRatio = constraints.maxWidth / constraints.maxHeight;
  final imageAspectRatio = originalImageSize.width / originalImageSize.height;

  double displayedWidth, displayedHeight;
  double offsetX = 0, offsetY = 0;

  if (renderedAspectRatio > imageAspectRatio) {
    // Imagem está limitada pela altura → sobra espaço nas laterais
    displayedHeight = constraints.maxHeight;
    displayedWidth = imageAspectRatio * displayedHeight;
    offsetX = (constraints.maxWidth - displayedWidth) / 2;
  } else {
    // Imagem está limitada pela largura → sobra espaço em cima/baixo
    displayedWidth = constraints.maxWidth;
    displayedHeight = displayedWidth / imageAspectRatio;
    offsetY = (constraints.maxHeight - displayedHeight) / 2;
  }

  final left = offsetX + displayedWidth * marker.x;
  final top = offsetY + displayedHeight * marker.y;

  return Positioned(
    left: left,
    top: top,
    child: GestureDetector(
      onTap: () => _showMarkerInfo(marker.number),
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          marker.number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    ),
  );
}


  void _showMarkerInfo(int number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Localização $number'),
        content: Text('Informações detalhadas sobre o ponto $number'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class MapMarker {
  final int number;
  final double x; // Posição horizontal (0.0 a 1.0)
  final double y; // Posição vertical (0.0 a 1.0)

  MapMarker({
    required this.number,
    required this.x,
    required this.y,
  });
}