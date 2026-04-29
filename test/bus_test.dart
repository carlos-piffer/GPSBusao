import 'package:flutter_test/flutter_test.dart';
import 'package:rio_bus_tracker/models/bus.dart';

void main() {
  group('Bus Model', () {
    test('should parse JSON correctly with comma in coordinates', () {
      final json = {
        "ordem": "C44654",
        "latitude": "-22,81948",
        "longitude": "-43,32448",
        "datahora": "1777476239000",
        "velocidade": "0",
        "linha": "LECD140",
      };

      final bus = Bus.fromJson(json);

      expect(bus.order, "C44654");
      expect(bus.latitude, -22.81948);
      expect(bus.longitude, -43.32448);
      expect(bus.line, "LECD140");
      expect(bus.speed, 0.0);
    });

    test('should parse JSON correctly with dot in coordinates', () {
      final json = {
        "ordem": "B44619",
        "latitude": -22.83251,
        "longitude": -43.32838,
        "datahora": "1777476238000",
        "velocidade": "10.5",
        "linha": "712",
      };

      final bus = Bus.fromJson(json);

      expect(bus.order, "B44619");
      expect(bus.latitude, -22.83251);
      expect(bus.longitude, -43.32838);
      expect(bus.line, "712");
      expect(bus.speed, 10.5);
    });
  });
}
