import 'package:logger/logger.dart';

/*
Map<Level, String>? levelEmojis*/
final Map<Level, String> emojiLoggerMap = {
  Level.trace: '[🔍]',
  Level.debug: '[D]',
  Level.info: '[I]',
  Level.warning: '[W]',
  Level.error: '[E]',
  Level.fatal: '[F]',
};

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 10,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    noBoxingByDefault: true,
    dateTimeFormat: DateTimeFormat.onlyTime,
    levelEmojis: emojiLoggerMap,
  ),
);
