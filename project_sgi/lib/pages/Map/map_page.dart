import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'markers.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<MapMarker>> markerList;

  late Future<Size> imageSize;
  final TransformationController _transformationController =
      TransformationController();

      Future<List<MapMarker>> _loadMarkers() async {
  final jsonString = await rootBundle.loadString('assets/data/markers.json');
  final List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((item) => MapMarker.fromJson(item)).toList();
}


  @override
void initState() {
  super.initState();
  imageSize = _getImageSize();
  markerList = _loadMarkers();

  _transformationController.addListener(() {
    setState(() {});
  });
}


  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
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
              transformationController: _transformationController,
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
                       FutureBuilder<List<MapMarker>>(
  future: markerList,
  builder: (context, markerSnapshot) {
    if (!markerSnapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final markers = markerSnapshot.data!;
    return Stack(
      children: [
        Image.asset(
          'assets/images/mapaPuc.jpeg',
          width: renderedWidth,
          height: renderedHeight,
          fit: BoxFit.contain,
        ),
        ...markers.map(
          (marker) => _buildMarker(marker, size, constraints),
        ),
      ],
    );
  },
),

                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarker(
    MapMarker marker,
    Size originalImageSize,
    BoxConstraints constraints,
  ) {
    final renderedAspectRatio = constraints.maxWidth / constraints.maxHeight;
    final imageAspectRatio = originalImageSize.width / originalImageSize.height;

    double displayedWidth, displayedHeight;
    double offsetX = 0, offsetY = 0;

    if (renderedAspectRatio > imageAspectRatio) {
      displayedHeight = constraints.maxHeight;
      displayedWidth = imageAspectRatio * displayedHeight;
      offsetX = (constraints.maxWidth - displayedWidth) / 2;
    } else {
      displayedWidth = constraints.maxWidth;
      displayedHeight = displayedWidth / imageAspectRatio;
      offsetY = (constraints.maxHeight - displayedHeight) / 2;
    }

    final left = offsetX + displayedWidth * marker.x;
    final top = offsetY + displayedHeight * marker.y;

    // Aqui pegamos o scale atual do zoom
    final scale = _transformationController.value.getMaxScaleOnAxis();

    // Tamanho base dos marcadores
    double baseSize = 30;

    // Dominui proporcional ao zoom (metade no 5.0)
    double markerSize = baseSize - ((scale - 1.0) / 4) * 22; // entre 1x e 1/2x

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _showMarkerInfo(marker.number, marker.name),
        child: Container(
          width: markerSize,
          height: markerSize,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            marker.number.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: markerSize * 0.5, // texto proporcional ao tamanho
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkerInfo(int number, String name) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Localização $name'),
            content: Text('Informações detalhadas sobre o prédio $number'),
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
