// encoding: utf-8
import "dart:io";
import "dart:async";
import "package:smallservlet/src/logger.dart";
import "package:smallservlet/src/cache_driver/base.dart";

const String TAG = "Servlet";

class ServletEngine {
  BaseCacheDriver _cache;
  int _maxConnection = 0;
  dynamic _SVhost = InternetAddress.ANY_IP_V6 ;
  int _SVport;


  ServletEngine(dynamic host, int port, String rootdir) {
    _SVhost = host;
    _SVport = port;
  }

  void setMaxConnection(int max_num) {
    if (max_num > 0) {
      _maxConnection = max_num;
    }
    else {
      throw new Exception("Maximum connection number can not be zero or less than zero");
    }
  }

  void setCacheDriver(BaseCacheDriver cacheDriver) {
    if (cacheDriver != null) {
      _cache = cacheDriver;
    }
    else {
      throw new Exception("Cache driver can not be null");
    }
  }

  void safeIgnition(Function igniter) {
    Logger log = new Logger(TAG);
  
    List<Future<dynamic>> flightCheck = new List<Future<dynamic>>();
    
    flightCheck.add(new Future(() {
      log.n("Operation Test: Run as non-root user");
      // TODO: Real code
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Temporary dir Read/Write");
      // TODO: Real code
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Port availability");
      // TODO: Real code
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Cache readiness");
      // TODO: Real code
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Dart Isolation test");
      // TODO: Real code
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Run as non-root user");
      // TODO: Real code
    }));

    Future.wait(flightCheck)
      .then((any) {
        log.n("Operation Test has finished. Ignite engine!");
        igniter();
      })
      .catchError((e) {
        log.e("Exception occured : ${e}");
      })
      .whenComplete(() {
        try {
          haltGracefully();
        }
        on Exception catch (e, s) {
          log.e("SmallServlet could not halt service gracefully.");
          log.e("Your configuration, runtime or OS may have serious problem.");
          log.e("Please check everything around SmallServlet");
          log.e("Exception : ${e}");
          log.e("Stack Trace : ${s}");

          haltEmergency();
        }
      });
  }

  Future<bool> doServe() async {
    // TODO: Support secure protocol 
    Logger log = new Logger(TAG);
    throw new UnimplementedError();
    return true;
  }

  void haltGracefully() {
    Logger log = new Logger(TAG);
    throw new UnimplementedError();
  }

  void haltEmergency() {
    Logger log = new Logger(TAG);
    throw new UnimplementedError();
  }
}
