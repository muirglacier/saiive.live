import 'package:logger/logger.dart';

class LogAllFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

class LogHelper {
  static Logger _instance = Logger(
    filter: LogAllFilter(),
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: false, printTime: true),
  );

  static Logger get instance => _instance;
}
