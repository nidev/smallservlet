// encoding: utf-8
const String TAG = "Logger";

class Logger {
  String _internalTag;
  static Map<String, Logger> _singletons = new Map<String, Logger>();

  // Logger._internal(String tag) {
  //   this.internalTag = tag;
  // }
  Logger._internal(this._internalTag); // <-- shorthand

  factory Logger(String tag) {
    if (!_singletons.containsKey(tag)) {
      final Logger new_logger = new Logger._internal(tag);
      _singletons[tag] = new_logger;

      new_logger.d("Logger has been initialized.");
    }
    return _singletons[tag];
  }

  void d(String msg) {
    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} DEBUG  ${msg}");
  }

  void n(String msg) {
    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} NOTIFY ${msg}");
  }

  void e(String msg) {
    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} ERROR  ${msg}");
  }

  void w(String msg) {
    DateTime date = new DateTime.now();
    print("${_internalTag}/${date} WARN   ${msg}");
  }
}
