// encoding: utf-8
import "dart:io";

/**
 * Helper class for platform-dependent values like newline character.
 */
class PlatformUtil {
  static final _NEWLINE_CRLF = "\r\n";
  static final _NEWLINE_LF = "\n";

  static String get newLine {
    if (Platform.isWindows) {
      // using \r\n
      return _NEWLINE_CRLF;
    }
    else {
      // using \n
      return _NEWLINE_LF;
    }
  }
}