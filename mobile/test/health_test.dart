import 'package:flutter_test/flutter_test.dart';
import 'package:syncbox/api/health.dart';

void main() {
  test('builds the health endpoint URL', () {
    expect(
      healthEndpointUrl('http://127.0.0.1:8080/'),
      'http://127.0.0.1:8080/api/v1/health',
    );
  });

  test('rejects an empty API base URL', () {
    expect(() => healthEndpointUrl('  '), throwsArgumentError);
  });

  test('parses the SyncBox health payload', () {
    final response = HealthResponse.fromJson({
      'success': true,
      'message': 'SyncBox API is running',
    });
    expect(response.success, isTrue);
    expect(response.message, 'SyncBox API is running');
  });
}
