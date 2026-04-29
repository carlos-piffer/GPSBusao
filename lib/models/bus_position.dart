class BusPosition {
  final String ordem;
  final double latitude;
  final double longitude;
  final DateTime dataHora;
  final double velocidade;
  final String linha;

  BusPosition({
    required this.ordem,
    required this.latitude,
    required this.longitude,
    required this.dataHora,
    required this.velocidade,
    required this.linha,
  });

  factory BusPosition.fromJson(Map<String, dynamic> json) {
    // API returns latitude and longitude as strings with commas, e.g., "-22,95073"
    double parseCoordinate(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    return BusPosition(
      ordem: json['ordem'] ?? '',
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
      dataHora: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(json['datahora'].toString()) ?? 0,
      ),
      velocidade: double.tryParse(json['velocidade'].toString()) ?? 0.0,
      linha: json['linha'] ?? '',
    );
  }
}
