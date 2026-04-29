import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_position.dart';

class BusMap extends StatelessWidget {
  final List<BusPosition> positions;
  final String? selectedLine;

  const BusMap({
    super.key,
    required this.positions,
    this.selectedLine,
  });

  @override
  Widget build(BuildContext context) {
    // Center of Rio de Janeiro
    const LatLng rioCenter = LatLng(-22.9068, -43.1729);

    return FlutterMap(
      options: const MapOptions(
        initialCenter: rioCenter,
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.rio_bus_tracker',
        ),
        MarkerLayer(
          markers: positions.map((bus) {
            return Marker(
              point: LatLng(bus.latitude, bus.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Linha: ${bus.linha}\nOrdem: ${bus.ordem}\nVelocidade: ${bus.velocidade} km/h',
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
