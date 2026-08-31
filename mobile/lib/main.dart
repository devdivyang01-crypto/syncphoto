import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api/health.dart';

void main() {
  runApp(const SyncBoxApp());
}

class SyncBoxApp extends StatelessWidget {
  const SyncBoxApp({super.key, this.autoCheckHealth = true});

  final bool autoCheckHealth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HelloSyncBoxPage(autoCheckHealth: autoCheckHealth),
    );
  }
}

class HelloSyncBoxPage extends StatefulWidget {
  const HelloSyncBoxPage({super.key, this.autoCheckHealth = true});

  final bool autoCheckHealth;

  @override
  State<HelloSyncBoxPage> createState() => _HelloSyncBoxPageState();
}

class _HelloSyncBoxPageState extends State<HelloSyncBoxPage> {
  final String apiBaseUrl = defaultApiBaseUrl();
  String status = 'Checking API';
  String message = 'Checking the SyncBox API...';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.autoCheckHealth) {
      refreshHealth();
    } else {
      loading = false;
      status = 'Ready';
      message = 'Tap recheck to call the SyncBox API.';
    }
  }

  Future<void> refreshHealth() async {
    setState(() {
      loading = true;
      status = 'Checking API';
      message = 'Checking the SyncBox API...';
    });

    try {
      final uri = Uri.parse(healthEndpointUrl(apiBaseUrl));
      final response = await http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
      if (!mounted) {
        return;
      }
      if (response.statusCode != 200) {
        throw HttpException('Health check failed with HTTP ${response.statusCode}.');
      }
      final payload = HealthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      setState(() {
        loading = false;
        status = payload.success ? 'API online' : 'API unreachable';
        message = payload.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
        status = 'API unreachable';
        message = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SYNCBOX',
                style: TextStyle(
                  letterSpacing: 3,
                  color: Color(0xFF5EEAD4),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hello SyncBox',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Mobile client foundation. The synchronization engine will land after this CI/CD path is green.',
              ),
              const SizedBox(height: 24),
              Text('API', style: Theme.of(context).textTheme.labelMedium),
              Text(apiBaseUrl, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: Icon(
                    status == 'API online'
                        ? Icons.check_circle
                        : Icons.wifi_tethering_error,
                  ),
                  title: Text(status),
                  subtitle: Text(message),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : refreshHealth,
                  child: const Text('Recheck health'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HttpException implements Exception {
  HttpException(this.message);
  final String message;

  @override
  String toString() => message;
}
