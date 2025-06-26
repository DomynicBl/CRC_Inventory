import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../class/markers.dart';
import '../../api/machine_service.dart';
// --- CORREÇÃO ---
// Ajuste no import para corresponder ao arquivo refatorado.
import '../search/search_result.dart'; 

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
  final TextEditingController _searchController = TextEditingController();
  final String mapFileName = 'assets/images/mapaPuc.png';
  final String markFileName = 'assets/data/markers.json';

  bool _isSearching = false;
  String _searchMessage = ''; 
  List<Map<String, dynamic>> _foundMachines = [];

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

  void _performSearch() async {
    final patrimonio = _searchController.text.trim();
    if (patrimonio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um número de patrimônio')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _searchMessage = 'Buscando...';
      _foundMachines = [];
    });

    try {
      final machineService = MachineService();
      final machines = await machineService.getByPatrimonioParcial(patrimonio);

      setState(() {
        _foundMachines = machines;
        _searchMessage = '';
      });
    } catch (e) {
      setState(() {
        _searchMessage = 'Erro: ${e.toString()}';
        _foundMachines = [];
      });
    }
  }

  void _resetSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _foundMachines = [];
      _searchMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar patrimônio...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _resetSearch,
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
      body: _isSearching
          ? _buildSearchResultLayout()
          : _buildMapWidget(),
    );
  }

  Widget _buildMapWidget() {
    return FutureBuilder<Size>(
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
                              .map(
                                (marker) => _buildMarker(
                                  marker,
                                  size,
                                  constraints,
                                ),
                              )
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
    );
  }

  Widget _buildSearchResultLayout() {
    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _resetSearch,
          icon: const Icon(Icons.map),
          label: const Text('Voltar ao mapa'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        if (_searchMessage == 'Buscando...')
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_searchMessage.startsWith('Erro:'))
          Expanded(
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
          )
        else
          SearchResultWidget(
            machines: _foundMachines,
            searchTerm: _searchController.text.trim(),
            onUpdate: _performSearch,
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
    double tamZoom = 8;
    double markerSize = baseSize - ((scale - 1.0) / 4) * (baseSize - tamZoom);

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
    final machineService = MachineService();
    // Formata o nome do prédio como o backend espera (ex: "P30")
    final buildingName = 'P$number';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Máquinas em: $name'),
        // O conteúdo agora é um FutureBuilder que busca e exibe os dados
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: machineService.getMachinesByBuilding(buildingName),
          builder: (context, snapshot) {
            // Estado de carregamento
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Estado de erro
            if (snapshot.hasError) {
              return Text('Erro ao buscar máquinas: ${snapshot.error}');
            }

            // Estado de sucesso
            if (snapshot.hasData) {
              final machines = snapshot.data!;

              // Caso não encontre nenhuma máquina
              if (machines.isEmpty) {
                return const Text('Nenhuma máquina encontrada neste prédio.');
              }

              // Se encontrou, exibe a lista
              return SizedBox(
                width: double.maxFinite,
                height: 300, // Ajuste a altura conforme necessário
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: machines.length,
                  itemBuilder: (context, index) {
                    final machine = machines[index];
                    return ListTile(
                      leading: const Icon(Icons.computer, color: Colors.blueGrey),
                      title: Text('Patrimônio: ${machine['patrimonio'] ?? 'N/A'}'),
                      subtitle: Text('Sala: ${machine['sala'] ?? 'N/A'}'),
                    );
                  },
                ),
              );
            }

            // Estado padrão (não deve ser alcançado)
            return const Text('Nenhuma informação disponível.');
          },
        ),
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
