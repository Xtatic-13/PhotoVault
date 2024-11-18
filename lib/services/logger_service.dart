import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  get logger => (Type type) => Logger(printer: CustomPrinter(type.toString()));

  static Future<void> logToFile(String message) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log.txt');
    await file.writeAsString(
        '>> ${DateTime.now().millisecondsSinceEpoch} : $message\n',
        mode: FileMode.append);
  }

  static Future<void> logFileAccessed(String fileName) async {
    if (fileName.isNotEmpty) {
      final String message = "File $fileName was Viewed by the User";
      logToFile(message);
    }
  }

  static Future<String> readLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log.txt');
    final logs = await file.readAsString();
    return logs;
  }

  static Future<void> logFileMoved(
    String pathBefore,
    String pathAfter,
  ) async {
    final String message =
        "File was Moved from Path: $pathBefore to Path: $pathAfter";
    logToFile(message);
  }
}

class CustomPrinter extends PrettyPrinter {
  final String className;
  CustomPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    final message = event.message;
    return ['$className: $message'];
  }
}
