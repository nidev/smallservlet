
class ServletEngineException {
  DateTime when;
  String msg;

  ServletEngineException([String exceptionMsg]) {
    when = new DateTime.now();
    msg = exceptionMsg;
  }
}
