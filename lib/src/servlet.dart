// encoding: utf-8
import "dart:io";
import "dart:async";

class ServletEngine {
  ServletEngine(dynamic host, dynamic port, dynamic rootdir) {

  }

  void setMaxConnection(int _) {
    throw new UnimplementedError();
  }

  void setCacheDriver(dynamic _) {
    throw new UnimplementedError();
  }

  Future<ServletEngine> testOperationOnce(bool drymode) async {
    if (!drymode) {
      // TODO: perform test operations (cache driver, port availability)
      throw new UnimplementedError();
      return this;
    }
    return null;
  }

  Future<bool> doServe() async {
    throw new UnimplementedError();
    return true;
  }

  void haltGracefully() {
    throw new UnimplementedError();
  }

  void haltEmergency() {
    throw new UnimplementedError();
  }
}
