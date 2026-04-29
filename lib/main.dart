import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'models/bus.dart';
import 'services/bus_service.dart';

void main() {
  runApp(const RioBusTrackerApp());
}

class RioBusTrackerApp extends StatelessWidget {
  const RioBusTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rio Bus Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BusTrackerHomePage(),
    );
  }
}

class BusTrackerHomePage extends StatefulWidget {
  const BusTrackerHomePage({super.key});

  @override
  State<BusTrackerHomePage> createState() => _BusTrackerHomePageState();
}

class _BusTrackerHomePageState extends State<BusTrackerHomePage> {
  final BusService _busService = BusService();
  List<Bus> _allBuses = [];
  List<Bus> _filteredBuses = [];
  List<String> _availableLines = [];
  String? _selectedLine;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchBuses();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBuses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final buses = await _busService.fetchBuses();
      setState(() {
        _allBuses = buses;
        _availableLines = buses.map((b) => b.line).toSet().toList()..sort();
        _filterBuses();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterBuses() {
    if (_selectedLine == null || _selectedLine!.isEmpty) {
      _filteredBuses = [];
    } else {
      _filteredBuses = _allBuses.where((b) => b.line == _selectedLine).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rio Bus Tracker'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBuses,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Bus Line',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedLine,
              items: _availableLines.map((line) {
                return DropdownMenuItem(
                  value: line,
                  child: Text(line),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLine = value;
                  _filterBuses();
                });
              },
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-22.9068, -43.1729), // Rio de Janeiro center
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.riobustracker',
                ),
                MarkerLayer(
                  markers: _filteredBuses.map((bus) {
                    return Marker(
                      point: LatLng(bus.latitude, bus.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.directions_bus,
                        color: Colors.blue,
                        size: 30,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
