import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/bus.dart';

class BusData {
  final List<String> availableLines;
  final List<Bus> filteredBuses;

  BusData({required this.availableLines, required this.filteredBuses});
}

class BusService {
  static const String _baseUrl = 'https://dados.mobilidade.rio/gps/sppo';

  Future<BusData> fetchBusData(String? selectedLine) async {
    try {
      final now = DateTime.now();
      // Reduced window to 30 seconds to download less data
      final thirtySecondsAgo = now.subtract(const Duration(seconds: 30));

      final dataInicial = _formatDateTime(thirtySecondsAgo);
      final dataFinal = _formatDateTime(now);

      final url = Uri.parse(_baseUrl).replace(queryParameters: {
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return _parseBusData(response.body, selectedLine);
      } else {
        throw Exception('Failed to load bus data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching buses: $e');
      rethrow;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  BusData _parseBusData(String responseBody, String? selectedLine) {
    final decoded = json.decode(responseBody);
    final Set<String> lines = {};
    final Map<String, Bus> deduplicatedBuses = {};

    void processItem(dynamic item) {
      if (item is Map<String, dynamic>) {
        final line = item['linha']?.toString() ?? '';
        if (line.isNotEmpty) lines.add(line);

        if (selectedLine != null && line == selectedLine) {
          final bus = Bus.fromJson(item);
          if (!deduplicatedBuses.containsKey(bus.order) ||
              bus.timestamp.isAfter(deduplicatedBuses[bus.order]!.timestamp)) {
            deduplicatedBuses[bus.order] = bus;
          }
        }
      }
    }

    if (decoded is List) {
      for (var item in decoded) {
        processItem(item);
      }
    } else if (decoded is Map && decoded.containsKey('data')) {
      final data = decoded['data'];
      if (data is List) {
        for (var item in data) {
          processItem(item);
        }
      }
    }

    final sortedLines = lines.toList()..sort();
    return BusData(
      availableLines: sortedLines,
      filteredBuses: deduplicatedBuses.values.toList(),
    );
  }
}
