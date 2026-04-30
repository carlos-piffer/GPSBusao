import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'models/bus.dart';
import 'services/bus_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RioBusTrackerApp());
}

class RioBusTrackerApp extends StatelessWidget {
  const RioBusTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rio Bus Tracker',
      debugShowCheckedModeBanner: false,
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
  List<Bus> _filteredBuses = [];
  List<String> _availableLines = [];
  String? _selectedLine;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _fetchBuses());
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _fetchBuses();
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
      final busData = await _busService.fetchBusData(_selectedLine);
      if (!mounted) return;

      setState(() {
        _availableLines = busData.availableLines;
        _filteredBuses = busData.filteredBuses;
        
        if (_selectedLine != null && !_availableLines.contains(_selectedLine)) {
          _selectedLine = null;
          _filteredBuses = [];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rio Bus Tracker', style: TextStyle(fontSize: 18)),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Bus Line'),
              value: _selectedLine,
              underline: const SizedBox(),
              items: _availableLines.map((line) {
                return DropdownMenuItem(
                  value: line,
                  child: Text(line),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLine = value;
                });
                _fetchBuses();
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-22.9068, -43.1729),
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
                      width: 30,
                      height: 30,
                      child: const Icon(
                        Icons.directions_bus,
                        color: Colors.blue,
                        size: 20,
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
