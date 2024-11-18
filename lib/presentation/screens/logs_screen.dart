import 'package:app/services/logger_service.dart';
import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Logs'),
      ),
      body: _buildLogView(context),
    );
  }

  Widget _buildLogView(BuildContext context) {
    return FutureBuilder(
      future: LoggerService.readLogFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(snapshot.data.toString()),
              ),
            );
          } else {
            return const Center(child: Text("No Logs to View"));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
