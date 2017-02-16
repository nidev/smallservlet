// encoding: utf-8
import "package:smallservlet/src/log_writer/interface.dart";
import "package:smallservlet/src/log_writer/defaultwriter.dart";

const String TAG = "Logger";
enum LOG_LEVELS { DEBUG, NOTIFY, ERROR, WARN }
const Map<String, LOG_LEVELS> LOG_LEVELS_FROM_STRING = const {
  "debug": LOG_LEVELS.DEBUG,
  "notify": LOG_LEVELS.NOTIFY,
  "error": LOG_LEVELS.ERROR,
  "warn": LOG_LEVELS.WARN
};

class Logger {
  String _internalTag;
  LogWriter _logWriter;
  
  static Map<String, Logger> _singletons = new Map<String, Logger>();
  static Set<LOG_LEVELS> logLevels = new Set<LOG_LEVELS>.from(LOG_LEVELS.values);

  // Logger._internal(String tag) {
  //   this.internalTag = tag;
  // }
  Logger._internal(this._internalTag, this._logWriter); // <-- shorthand

  factory Logger(String tag, { LogWriter logWriter = null }) {
    if (!_singletons.containsKey(tag)) {
      // If there's no given custom writer, use default one. (STDOUT)
      if (logWriter == null) {
        logWriter = new DefaultLogWriter();
      }

      final Logger new_logger = new Logger._internal(tag, logWriter);
      _singletons[tag] = new_logger;

      new_logger._l("Logger for '${tag}' has been initialized");
      new_logger._l("At this time, following log levels are enabled: ${logLevels.toString()}");
    }
    return _singletons[tag];
  }

  void _l(String msg) {
    DateTime date = new DateTime.now();
    _logWriter.writeLn("${_internalTag}/${date} ${msg}");
  }

  void d(String msg) {
    if (!logLevels.contains(LOG_LEVELS.DEBUG)) return;

    DateTime date = new DateTime.now();
    _logWriter.writeLn("${_internalTag}/${date} DEBUG  ${msg}");
  }

  void n(String msg) {
    if (!logLevels.contains(LOG_LEVELS.NOTIFY)) return;

    DateTime date = new DateTime.now();
    _logWriter.writeLn("${_internalTag}/${date} NOTIFY ${msg}");
  }

  void e(String msg) {
    if (!logLevels.contains(LOG_LEVELS.ERROR)) return;

    DateTime date = new DateTime.now();
    _logWriter.writeLn("${_internalTag}/${date} ERROR  ${msg}");
  }

  void w(String msg) {
    if (!logLevels.contains(LOG_LEVELS.WARN)) return;

    DateTime date = new DateTime.now();
    _logWriter.writeLn("${_internalTag}/${date} WARN   ${msg}");
  }
}
