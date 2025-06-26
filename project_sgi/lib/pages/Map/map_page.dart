import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../class/markers.dart';
import '../../api/machine_service.dart';
import '../search/search_result.dart'; 
// Importe o seu MachineCard, o caminho pode precisar de ajuste
import '../cards/machine_card.dart'; 

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // O estado da tela continua o mesmo
  late Future<List<MapMarker>> markerList;
  late Future<Size> imageSize;
  final TransformationController _transformationController = TransformationController();
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
    _transformationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- NENHUMA MUDANÇA NAS FUNÇÕES DE CARREGAMENTO E BUSCA ---
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
    if (patrimonio.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);
    try {
      final machines = await MachineService().getByPatrimonioParcial(patrimonio);
      setState(() => _foundMachines = machines);
    } catch (e) {
      setState(() => _searchMessage = 'Erro: ${e.toString()}');
    }
  }

  void _resetSearch() => setState(() {
    _isSearching = false;
    _searchController.clear();
  });


  // --- NOVA FUNÇÃO: MOSTRAR O CARD DETALHADO DA MÁQUINA ---
  void _showMachineDetailsDialog(Map<String, dynamic> machine, VoidCallback onUpdate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        // O conteúdo é o seu MachineCard
        content: MachineCard(
          machine: machine,
          // Passamos a função onUpdate para que o card possa recarregar a lista
          onUpdate: () {
            Navigator.of(context).pop(); // Fecha o card
            onUpdate(); // Chama a função que recarrega a lista de salas
          },
        ),
        // Ações removidas daqui para usar o layout do seu card
      ),
    );
  }

  // --- _showMarkerInfo TOTALMENTE REFEITO COM A NOVA LÓGICA ---
  void _showMarkerInfo(int number, String name) {
    final machineService = MachineService();
    final buildingName = 'P$number';

    // Função para ser chamada quando precisarmos recarregar este diálogo
    VoidCallback reloadDialog = () {
      Navigator.of(context).pop(); // Fecha o diálogo atual
      _showMarkerInfo(number, name); // E o reabre para recarregar os dados
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Locais em: $name'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: machineService.getMachinesByBuilding(buildingName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text('Erro ao buscar: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Nenhuma máquina encontrada neste prédio.');
            }

            // --- LÓGICA PARA AGRUPAR MÁQUINAS POR SALA ---
            final machines = snapshot.data!;
            final Map<String, List<Map<String, dynamic>>> rooms = {};
            for (var machine in machines) {
              final roomNumber = machine['sala'] ?? 'Sala Desconhecida';
              // Adiciona a máquina à lista da sua respectiva sala
              (rooms[roomNumber] ??= []).add(machine);
            }

            // Constrói a lista de ExpansionTile
            return SizedBox(
              width: double.maxFinite,
              height: 400, // Altura ajustável
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: rooms.keys.length,
                itemBuilder: (context, index) {
                  String roomKey = rooms.keys.elementAt(index);
                  List<Map<String, dynamic>> machinesInRoom = rooms[roomKey]!;
                  
                  return ExpansionTile(
                    leading: const Icon(Icons.meeting_room_outlined),
                    title: Text('Sala: $roomKey (${machinesInRoom.length} máq.)'),
                    children: machinesInRoom.map((machine) {
                      // Cria o item da lista para cada máquina
                      return ListTile(
                        leading: const Icon(Icons.computer, size: 20),
                        title: Text('${machine['nome'] ?? 'N/A'}'),
                        subtitle: Text('Patrimônio: ${machine['patrimonio'] ?? 'N/A'}'),
                        onTap: () {
                          // Abre o card detalhado da máquina
                          _showMachineDetailsDialog(machine, reloadDialog);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  // --- WIDGETS DE LAYOUT (build, _buildMapWidget, etc.) SEM MUDANÇAS DRÁSTICAS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [ Expanded(child: TextField(controller: _searchController, decoration: InputDecoration(hintText: 'Buscar patrimônio...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),), isDense: true, contentPadding: const EdgeInsets.all(8), suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _resetSearch,),), onSubmitted: (_) => _performSearch(), keyboardType: TextInputType.number,),), const SizedBox(width: 8), ElevatedButton(onPressed: _performSearch, child: const Text('Buscar'),),],),),),
      body: _isSearching ? _buildSearchResultLayout() : _buildMapWidget(),
    );
  }

  Widget _buildSearchResultLayout() {
    return Column(children: [ const SizedBox(height: 16), ElevatedButton.icon(onPressed: _resetSearch, icon: const Icon(Icons.map), label: const Text('Voltar ao mapa'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),),), const SizedBox(height: 16), if (_isSearching && _foundMachines.isEmpty && _searchMessage.isEmpty) const Expanded(child: Center(child: CircularProgressIndicator())) else if (_searchMessage.isNotEmpty) Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(_searchMessage, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center,),),),) else SearchResultWidget(machines: _foundMachines, searchTerm: _searchController.text.trim(), onUpdate: _performSearch,),],
    );
  }

  Widget _buildMapWidget() {
    return FutureBuilder<Size>(future: imageSize, builder: (context, snapshot) { if (!snapshot.hasData) { return const Center(child: CircularProgressIndicator()); } final size = snapshot.data!; return Center(child: InteractiveViewer(transformationController: _transformationController, minScale: 1.0, maxScale: 5.0, child: LayoutBuilder(builder: (context, constraints) { return Stack(children: [ Image.asset(mapFileName, width: constraints.maxWidth, height: constraints.maxHeight, fit: BoxFit.contain,), FutureBuilder<List<MapMarker>>(future: markerList, builder: (context, markerSnapshot) { if (!markerSnapshot.hasData) return const SizedBox.shrink(); return Stack(children: markerSnapshot.data!.map((marker) => _buildMarker(marker, size, constraints)).toList(),);},),],);},),),);},
    );
  }
  
  Widget _buildMarker(MapMarker marker, Size originalImageSize, BoxConstraints constraints) {
    final renderedAspectRatio = constraints.maxWidth / constraints.maxHeight; final imageAspectRatio = originalImageSize.width / originalImageSize.height; double displayedWidth, displayedHeight; double offsetX = 0, offsetY = 0; if (renderedAspectRatio > imageAspectRatio) { displayedHeight = constraints.maxHeight; displayedWidth = imageAspectRatio * displayedHeight; offsetX = (constraints.maxWidth - displayedWidth) / 2; } else { displayedWidth = constraints.maxWidth; displayedHeight = displayedWidth / imageAspectRatio; offsetY = (constraints.maxHeight - displayedHeight) / 2; } final left = offsetX + displayedWidth * marker.x; final top = offsetY + displayedHeight * marker.y; final scale = _transformationController.value.getMaxScaleOnAxis(); double baseSize = 30; double tamZoom = 8; double markerSize = baseSize - ((scale - 1.0) / 4) * (baseSize - tamZoom);
    return Positioned(left: left - markerSize / 2, top: top - markerSize / 2, child: GestureDetector(onTap: () => _showMarkerInfo(marker.number, marker.name), child: Container(width: markerSize, height: markerSize, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2),),],), alignment: Alignment.center, child: Text(marker.number.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: markerSize * 0.5,),),),),);
  }
}
