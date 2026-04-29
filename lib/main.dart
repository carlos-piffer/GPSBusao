import 'dart:async';
import 'package:flutter/material.dart';
import 'models/bus_position.dart';
import 'services/bus_service.dart';
import 'widgets/bus_map.dart';

void main() {
  runApp(const RioBusApp());
}

class RioBusApp extends StatelessWidget {
  const RioBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rio Bus Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BusTrackerHome(),
    );
  }
}

class BusTrackerHome extends StatefulWidget {
  const BusTrackerHome({super.key});

  @override
  State<BusTrackerHome> createState() => _BusTrackerHomeState();
}

class _BusTrackerHomeState extends State<BusTrackerHome> {
  final BusService _busService = BusService();
  final TextEditingController _lineController = TextEditingController();
  List<BusPosition> _busPositions = [];
  bool _isLoading = false;
  Timer? _refreshTimer;
  String _currentLine = '';

  @override
  void initState() {
    super.initState();
    // Default search for line 100 or something common if needed, or leave empty
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _lineController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (_currentLine.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final positions = await _busService.fetchBusPositions(line: _currentLine);
      setState(() {
        _busPositions = positions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar dados: $e')),
        );
      }
    }
  }

  void _startTracking() {
    _currentLine = _lineController.text.trim();
    if (_currentLine.isEmpty) return;

    _fetchData();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rio Bus Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lineController,
                    decoration: const InputDecoration(
                      labelText: 'Linha de ônibus (ex: 100)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _startTracking(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _startTracking,
                  child: const Text('Rastrear'),
                ),
              ],
            ),
          ),
          if (_isLoading && _busPositions.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Stack(
                children: [
                  BusMap(
                    positions: _busPositions,
                    selectedLine: _currentLine,
                  ),
                  if (_isLoading)
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: CircularProgressIndicator(),
                    ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white70,
                      child: Text(
                        'Ônibus encontrados: ${_busPositions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
