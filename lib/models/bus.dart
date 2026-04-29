class Bus {
  final String order;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double speed;
  final String line;

  Bus({
    required this.order,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speed,
    required this.line,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    double parseCoordinate(dynamic value) {
      if (value is double) return value;
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    return Bus(
      order: json['ordem'] ?? '',
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['datahora'].toString()) ?? 0),
      speed: double.tryParse(json['velocidade'].toString()) ?? 0.0,
      line: json['linha'] ?? '',
    );
  }

  @override
  String toString() => 'Bus(order: $order, line: $line, lat: $latitude, lon: $longitude)';
}
