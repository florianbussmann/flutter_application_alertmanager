import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_alertmanager/main.dart';

void main() {
  group('Alert model', () {
    const sampleApiResponse = '''
    [
      {
        "annotations": {
          "description": "localhost:9090 of job prometheus has been down for more than 5 minutes.",
          "summary": "Instance localhost:9090 down"
        },
        "endsAt": "2025-08-11T16:26:49.562Z",
        "fingerprint": "a78a6f3d436e0dac",
        "receivers": [
          { "name": "web.hook" }
        ],
        "startsAt": "2025-07-21T18:09:34.562Z",
        "status": {
          "inhibitedBy": [],
          "mutedBy": [],
          "silencedBy": [],
          "state": "active"
        },
        "updatedAt": "2025-08-11T18:22:49.567+02:00",
        "generatorURL": "http://prometheus:9090/graph?g0.expr=up+%3D%3D+1&g0.tab=1",
        "labels": {
          "alertname": "InstanceDown",
          "instance": "localhost:9090",
          "job": "prometheus",
          "severity": "page"
        }
      }
    ]
    ''';

    test('parses status.state correctly', () {
      final decoded = jsonDecode(sampleApiResponse) as List;
      final alert = Alert.fromJson(decoded.first);

      expect(alert.status, equals('active'));
    });

    test('parses labels and annotations', () {
      final decoded = jsonDecode(sampleApiResponse) as List;
      final alert = Alert.fromJson(decoded.first);

      expect(alert.labels['alertname'], equals('InstanceDown'));
      expect(alert.annotations['description'], contains('localhost:9090'));
    });
  });
}
