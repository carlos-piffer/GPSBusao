import 'dart:convert';
import 'package:rio_bus_tracker/models/bus_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BusPosition.fromJson parses correctly with commas', () {
    final jsonStr = '{"ordem":"A27619","latitude":"-22,95073","longitude":"-43,18399","datahora":"1716209992000","velocidade":"0","linha":"548"}';
    final jsonMap = json.decode(jsonStr);

    final bus = BusPosition.fromJson(jsonMap);

    expect(bus.ordem, 'A27619');
    expect(bus.latitude, -22.95073);
    expect(bus.longitude, -43.18399);
    expect(bus.linha, '548');
    expect(bus.velocidade, 0.0);
  });
}
