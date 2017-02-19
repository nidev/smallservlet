// encoding: utf-8
import "dart:io";
import "dart:async";
import "package:system_info/system_info.dart";
import "package:path/path.dart" as Path;
import "package:smallservlet/src/logger.dart";
import "package:smallservlet/src/cache_driver/base.dart";

const String TAG = "Servlet";
enum PathKey { TEMP_DIR, SERVLET_DIR, CONTEXT_FILE }
const Map<PathKey, String> SSPATH = const {
  PathKey.TEMP_DIR: "tempdir",
  PathKey.SERVLET_DIR: "servlet",
  PathKey.CONTEXT_FILE: ".context"
};

class ServletEngine {
  BaseCacheDriver _cache;
  int _maxConnection = 0;
  dynamic _SVhost = InternetAddress.ANY_IP_V6 ;
  String _rootdir = "/var/lib/smallservlet/";
  int _SVport;


  ServletEngine(dynamic host, int port, String rootdir) {
    _SVhost = host;
    _SVport = port;
    _rootdir = rootdir.trim();
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
      
      if (SysInfo.userName == "root" || SysInfo.userId == "root") {
        log.e("You SHOULD NOT run this program as root user.");
        throw new Exception("Run as non-root user");
      }
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Root dir folder structure and Read/Write");

      if (!Path.isAbsolute(_rootdir)) {
        throw new Exception("Path to rootdir should be an absolute path.");
      }

      Directory rootDir = new Directory(_rootdir);
      if (rootDir.existsSync()) {
        SSPATH.values.forEach((directory) {
          Directory subDir = new Directory(Path.join(_rootdir, directory));
          subDir.createSync();
        });
      }
      else {
        throw new Exception("Rootdir path [${_rootdir}] does not exist.");
      }
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Temporary dir Read/Write");
      // TODO: Real code
      throw new UnimplementedError();
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Port availability");
      // TODO: Real code
      throw new UnimplementedError();
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Cache readiness");
      // TODO: Real code
      throw new UnimplementedError();
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Dart Isolation test");
      // TODO: Real code
      throw new UnimplementedError();
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Run as non-root user");
      // TODO: Real code
      throw new UnimplementedError();
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
