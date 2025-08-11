import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // The application state is not lost during the reload.
        // To reset the state, use hot restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AlertListScreen(title: 'Prometheus Alerts'),
    );
  }
}

class Alert {
  final String status;
  final Map<String, dynamic> labels;
  final Map<String, dynamic> annotations;
  final String startsAt;
  final String? endsAt;

  Alert({
    required this.status,
    required this.labels,
    required this.annotations,
    required this.startsAt,
    this.endsAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      status: json['status']?['state']?.toString() ?? '',
      labels: Map<String, dynamic>.from(json['labels'] ?? {}),
      annotations: Map<String, dynamic>.from(json['annotations'] ?? {}),
      startsAt: json['startsAt'] ?? '',
      endsAt: json['endsAt'],
    );
  }
}

class AlertListScreen extends StatefulWidget {
  const AlertListScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AlertListScreen> createState() => _AlertListScreenState();
}

class _AlertListScreenState extends State<AlertListScreen> {
  late Future<List<Alert>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = fetchAlerts();
  }

  Future<List<Alert>> fetchAlerts() async {
    final url = Uri.parse('http://prometheus-alertmanager:9093/api/v2/alerts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => Alert.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load alerts: ${response.statusCode}');
    }
  }

  Color _stateColor(String state) {
    switch (state.toLowerCase()) {
      case 'active':
        return Colors.red;
      default: // suppressed
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the AlertListScreen object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Alert>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No alerts found'));
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final chipBackground = _stateColor(alert.status);
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(alert.labels['alertname'] ?? 'Unknown Alert'),
                  subtitle: Text(alert.annotations['description'] ?? ''),
                  trailing: Chip(
                    label: Text(
                      alert.status,
                      style: TextStyle(
                        color:
                            ThemeData.estimateBrightnessForColor(
                                  chipBackground,
                                ) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: chipBackground,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(alert.labels['alertname'] ?? 'Alert'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${alert.status}'),
                            Text('Starts: ${alert.startsAt}'),
                            if (alert.endsAt != null)
                              Text('Ends: ${alert.endsAt}'),
                            const SizedBox(height: 10),
                            Text('Labels: ${alert.labels}'),
                            Text('Annotations: ${alert.annotations}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
