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

      log.n("Operation Test: Temporary dir Read/Write");
      File tempFile = new File(Path.join(_rootdir, SSPATH[PathKey.TEMP_DIR], "io_test"));
      tempFile.createSync();
      tempFile.writeAsBytesSync([0], mode: FileMode.WRITE, flush: true);
    }));

    log.n("Operation Test: Port availability");
    flightCheck.add(ServerSocket.bind(_SVhost, _SVport).then((socket)=>socket.close()));

    log.n("Operation Test: Cache readiness");
    flightCheck.add(_cache.checkBackbone());

    flightCheck.add(new Future(() {
      log.n("Operation Test: Dart Isolation test");
      // TODO: Real code
      //throw new UnimplementedError();
    }));

    flightCheck.add(new Future(() {
      log.n("Operation Test: Run test isolation");
      // TODO: Real code
      //throw new UnimplementedError();
    }));

    flightCheck.add(new Future(() {
      log.n("Scan rootdir and create routing table");
      // TODO: Real code
      throw new UnimplementedError();
    }));

    Future.wait(flightCheck)
      .then((any) async {
        log.n("Operation Test has finished. Ignite engine!");

        await igniter();
        
        log.n("Operation ends.");
      })
      .catchError((e) {
        log.e("Exception occured : ${e}");
      })
      .whenComplete(() {
        try {
          log.n("Clean up");
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
    final Completer c = new Completer();

    // TODO: Support secure protocol 
    Logger log = new Logger(TAG);
    HttpServer httpServer = await HttpServer.bind(_SVhost, _SVport);
    
    // Connection monitor timer
    Timer monitor = new Timer.periodic(new Duration(seconds: 5), (_) {
      HttpConnectionsInfo connInfo = httpServer.connectionsInfo();
      log.n("Connections[${connInfo.total}]: active[${connInfo.active}] idle[${connInfo.idle}] closing[${connInfo.closing}]");
    });
    
    httpServer.listen((request) {
        log.d("Connection from [${request.connectionInfo.remoteAddress.toString()}] at [${request.connectionInfo.remotePort}]");
        request.response.writeln("Hello World!");
        request.response.close();

        // TODO: Just for now. Signal handler is required.
        c.complete(true);
      },
      onError: (e) {
        log.e("Error occured: ${e}");
      }
    );
    return c.future;
  }

  void haltGracefully() {
    Logger log = new Logger(TAG);

    Logger.logLevels.add(LOG_LEVELS.NOTIFY);
    log.n("Gracefully halt SmallServlet...");

    _cache.syncBackbone(false).then((result) => log.n("Sync cache : ${result}"));

    // TODO: any servlet clean-up, releasing file handles

    // When everything is done
    log.n("Halted");
    exit(0);
  }

  void haltEmergency() {
    final String EmergencyTAG = "EMERGENCY";
    
    // Enable all level
    Logger log = new Logger(EmergencyTAG);
    Logger.logLevels.addAll(LOG_LEVELS.values);

    log.e("!!! EMERGENCY HALT !!!");
    
    _cache.syncBackbone(true).then((result) => log.n("Sync cache : ${result}"));
    
    // TODO: any servlet clean-up, releasing file handles

    exit(-1);
  }
}
