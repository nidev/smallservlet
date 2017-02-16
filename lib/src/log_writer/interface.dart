// encoding: utf-8

/**
 * LogWriter interface.
 * You may pass an object which implements this interface, to construct customized Logger object.
 * (ex. logging to special device like serial port)
 */
abstract class LogWriter {
  void write(String msg);
  void writeLn(String msg);
}
