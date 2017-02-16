// encoding: utf-8
import "package:smallservlet/src/log_writer/interface.dart";

/**
 * Default (fallback) log writer using STDOUT.
 * Thanks to 'factory', this class does not create more than one logwriter object in VM heap.
 */
class DefaultLogWriter extends LogWriter {
  static DefaultLogWriter _internalLogger = null;

  DefaultLogWriter._internal() {
    // nothing to do
  }

  factory DefaultLogWriter() {
    if (_internalLogger == null) {
      _internalLogger = new DefaultLogWriter._internal();
    }

    return _internalLogger;
  }

  @override void write(String msg) {
    print(msg);
  }

  @override void writeLn(String msg) {
    print(msg);
  }
}