import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/bus.dart';

class BusService {
  static const String _baseUrl = 'https://dados.mobilidade.rio/gps/sppo';

  Future<List<Bus>> fetchBuses() async {
    try {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final dataInicial = formatter.format(oneMinuteAgo);
      final dataFinal = formatter.format(now);

      final url = Uri.parse(_baseUrl).replace(queryParameters: {
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Bus.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bus data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching buses: $e');
      rethrow;
    }
  }
}
