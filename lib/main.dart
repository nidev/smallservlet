// encoding: utf-8
import "dart:io";
import "dart:async";
import "package:args/args.dart";
import "package:smallservlet/src/logger.dart";
import "package:smallservlet/src/cache_driver/base.dart" as Cache;
import "package:smallservlet/src/cache_driver/nocache.dart" as Cache;
import "package:smallservlet/src/cache_driver/redis.dart" as Cache;
import "package:smallservlet/src/config.dart";
import "package:smallservlet/src/exception/exceptions.dart";
import "package:smallservlet/src/servlet.dart";
import "package:smallservlet/version.dart";


const String TAG = "Main";

void bootstrap(List<String> arguments) {
  final log = new Logger("Main");
  final appVersion = getPackageVersion();

  log.n("Boot up SmallServlet ${appVersion.toString()}");

  ArgParser parser = new ArgParser()
    ..addFlag("verbose", abbr:"v", help:"Display verbose debug messages", defaultsTo: false, negatable: false)
    ..addFlag("daemon", abbr:"D", help:"Run as daemonic service", defaultsTo: false, negatable: false)
    ..addFlag("dry", abbr:"d", help: "Run as dry mode. Once bootstrapping is over, the program exits", defaultsTo: false, negatable: false)
    ..addFlag("help", abbr:"h", help: "Show help message", defaultsTo: false, negatable: false)
    ..addFlag("cache", abbr: "n", help: "Decide to use/not to use servlet cache", defaultsTo: true, negatable: true)
    ..addOption("config", abbr: "c", help: "Pass configuration file path (required)", valueHelp: "path");

  ArgResults parsed = parser.parse(arguments);

  if (!parsed.wasParsed("config") || parsed["help"]) {
    log.n("The program stops right after printing help message");
    print("SmallServlet help");
    print(parser.usage);
    exit(1);
  }

  String configFilePath = parsed["config"];

  final SSConfiguration config = new SSConfiguration.fromFile("", configFilePath);
  log.n("Load configuration");

  Cache.BaseCacheDriver cacheDriver = new Cache.NoCacheDriver();
  if (config[CFG_CACHE__SIZE] > 0) {
    cacheDriver = new Cache.RedisCacheDriver(host: config[CFG_REDIS__HOST], port: config[CFG_REDIS__PORT], password: config[CFG_REDIS__PASSWORD]);
    cacheDriver.setCacheSize(config[CFG_CACHE__SIZE]);
    cacheDriver.setLifetimeSeconds(config[CFG_CACHE__LIFESECONDS]);
  }
  log.n("Initiate cache");

  final servletEngine = new ServletEngine(config[CFG_BIND__HOST], config[CFG_BIND__PORT], config[CFG_ROOTDIR]);
  servletEngine
    ..setMaxConnection(config[CFG_MAX_CONNECTION])
    ..setCacheDriver(cacheDriver);
  log.n("Initiate servlet engine");

  servletEngine.testOperationOnce(parsed.wasParsed("dry") && parsed["dry"])
    .then((realServletEngine) async => await realServletEngine.doServe())
    .catchError((e) {
      log.e("Exception occured : ${e}");
    })
    .whenComplete(() {
      try {
        servletEngine.haltGracefully();
      }
      on Exception catch (e, s) {
        log.e("SmallServlet could not halt service gracefully.");
        log.e("Your configuration, runtime or OS may have serious problem.");
        log.e("Please check everything around SmallServlet");
        log.e("Exception : ${e}");
        log.e("Stack Trace : ${s}");

        servletEngine.haltEmergency();
      }
    });
}
