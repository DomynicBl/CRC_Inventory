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
  final TransformationController _transformationController = TransformationController();
  final TextEditingController _searchController = TextEditingController();

  final String mapFileName = 'assets/images/mapaPuc.png';
  final String markFileName = 'assets/data/markers.json';

  bool _isSearching = false;
  String _searchResult = '';

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
    _searchController.dispose();
    super.dispose();
  }

  Future<List<MapMarker>> _loadMarkers() async {
    final jsonString = await rootBundle.loadString(markFileName);
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => MapMarker.fromJson(item)).toList();
  }

  Future<Size> _getImageSize() async {
    final data = await rootBundle.load(mapFileName);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  void _performSearch() {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um número de patrimônio')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResult = 'Resultado para patrimônio: ${_searchController.text}';
    });
  }

  void _resetSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Interativo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar patrimônio...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isSearching
          ? _buildSearchResult()
          : FutureBuilder<Size>(
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
                              mapFileName,
                              width: renderedWidth,
                              height: renderedHeight,
                              fit: BoxFit.contain,
                            ),
                            FutureBuilder<List<MapMarker>>(
                              future: markerList,
                              builder: (context, markerSnapshot) {
                                if (!markerSnapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final markers = markerSnapshot.data!;
                                return Stack(
                                  children: markers
                                      .map((marker) =>
                                          _buildMarker(marker, size, constraints))
                                      .toList(),
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

  Widget _buildSearchResult() {
  return Column(
    children: [
      const SizedBox(height: 16), // aproxima da barra de busca
      ElevatedButton.icon(
        onPressed: _resetSearch,
        icon: const Icon(Icons.map),
        label: const Text('Voltar ao mapa'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _searchResult,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    ],
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

    final scale = _transformationController.value.getMaxScaleOnAxis();
    double baseSize = 30;
    double markerSize = baseSize - ((scale - 1.0) / 4) * 22;

    return Positioned(
      left: left - markerSize / 2,
      top: top - markerSize / 2,
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
              fontSize: markerSize * 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkerInfo(int number, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
