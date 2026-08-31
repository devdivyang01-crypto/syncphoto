class HealthResponse {
  const HealthResponse({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'];
    final message = json['message'];
    if (success is! bool || message is! String) {
      throw const FormatException('Unexpected health response.');
    }
    return HealthResponse(success: success, message: message);
  }
}

String healthEndpointUrl(String baseUrl) {
  final normalized = baseUrl.trim();
  if (normalized.isEmpty) {
    throw ArgumentError('API_BASE_URL is not configured for this environment.');
  }
  final withoutSlash = normalized.endsWith('/')
      ? normalized.substring(0, normalized.length - 1)
      : normalized;
  return '$withoutSlash/api/v1/health';
}

String defaultApiBaseUrl() {
  const fromDefine = String.fromEnvironment('API_BASE_URL');
  if (fromDefine.trim().isNotEmpty) {
    return fromDefine.trim();
  }
  return 'http://127.0.0.1:8080';
}
