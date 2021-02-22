import 'package:logger/logger.dart';

class LogHelper {
  static Logger _instance = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: false, printTime: true),
  );

  static Logger get instance => _instance;
}
