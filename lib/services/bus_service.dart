import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/bus_position.dart';

class BusService {
  static const String baseUrl = 'https://dados.mobilidade.rio/gps/sppo';

  Future<List<BusPosition>> fetchBusPositions({String? line}) async {
    final now = DateTime.now();
    // To ensure we get data, we'll look at the last 5 minutes.
    final dataFinal = now;
    final dataInicial = now.subtract(const Duration(minutes: 5));

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final startStr = formatter.format(dataInicial);
    final endStr = formatter.format(dataFinal);

    // Using Uri constructor for safe encoding of spaces and special characters
    final url = Uri.parse(baseUrl).replace(queryParameters: {
      'dataInicial': startStr,
      'dataFinal': endStr,
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<BusPosition> allPositions = data.map((json) => BusPosition.fromJson(json)).toList();

        // Filter by line if provided
        Iterable<BusPosition> filtered = allPositions;
        if (line != null && line.isNotEmpty) {
          filtered = filtered.where((p) => p.linha == line);
        }

        // Group by 'ordem' (bus ID) and keep only the latest position
        final Map<String, BusPosition> latestPositions = {};
        for (var pos in filtered) {
          final existing = latestPositions[pos.ordem];
          if (existing == null || pos.dataHora.isAfter(existing.dataHora)) {
            latestPositions[pos.ordem] = pos;
          }
        }

        return latestPositions.values.toList();
      } else {
        throw Exception('Failed to load bus positions');
      }
    } catch (e) {
      debugPrint('Error fetching bus positions: $e');
      return [];
    }
  }
}
