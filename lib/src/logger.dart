// encoding: utf-8
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
  static Map<String, Logger> _singletons = new Map<String, Logger>();
  static Set<LOG_LEVELS> logLevels = new Set<LOG_LEVELS>.from(LOG_LEVELS.values);

  // Logger._internal(String tag) {
  //   this.internalTag = tag;
  // }
  Logger._internal(this._internalTag); // <-- shorthand

  factory Logger(String tag) {
    if (!_singletons.containsKey(tag)) {
      final Logger new_logger = new Logger._internal(tag);
      _singletons[tag] = new_logger;

      new_logger.d("Logger for '${tag}' has been initialized");
    }
    return _singletons[tag];
  }

  void d(String msg) {
    if (!logLevels.contains(LOG_LEVELS.DEBUG)) return;

    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} DEBUG  ${msg}");
  }

  void n(String msg) {
    if (!logLevels.contains(LOG_LEVELS.NOTIFY)) return;

    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} NOTIFY ${msg}");
  }

  void e(String msg) {
    if (!logLevels.contains(LOG_LEVELS.ERROR)) return;

    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} ERROR  ${msg}");
  }

  void w(String msg) {
    if (!logLevels.contains(LOG_LEVELS.WARN)) return;

    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} WARN   ${msg}");
  }
}
