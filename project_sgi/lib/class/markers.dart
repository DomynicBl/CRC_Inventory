class MapMarker {
  final int number;
  final String name;
  final double x;
  final double y;

  MapMarker({
    required this.number,
    required this.name,
    required this.x,
    required this.y,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      number: json['number'],
      name: json['name'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }
}
