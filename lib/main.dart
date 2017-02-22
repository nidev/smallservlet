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

  String logLevelsString = config[CFG_LOGLEVELS];
  List<String> logLevels = logLevelsString.trim().split(",");
  if (logLevels.length <= 0) {
    log.n("No configuration for log levels. For default, every level is enabled (aka verbose)");
  }
  else {
    log.n("Reset log level");
    Logger.logLevels.clear();

    logLevels.forEach((lv) {
      lv = lv.trim();

      if (LOG_LEVELS_FROM_STRING.containsKey(lv)) {
        Logger.logLevels.add(LOG_LEVELS_FROM_STRING[lv]);
      }
      else {
        // Re-enable error level, and display error message
        Logger.logLevels.add(LOG_LEVELS.ERROR);
        log.e("Given log level name '${lv}' is invalid one. Should be one of debug, notify, warn or error");
        exit(1);
      }
    });
  }

  log.n("Global log levels: ${Logger.logLevels.toString()}");

  Cache.BaseCacheDriver cacheDriver = new Cache.NoCacheDriver();
  if (config[CFG_CACHE__SIZE] > 0) {
    log.d("Cache size is bigger than zero, initiate Redis cache.");
    cacheDriver = new Cache.RedisCacheDriver(
      host: config[CFG_REDIS__HOST],
      port: config[CFG_REDIS__PORT],
      password: config[CFG_REDIS__PASSWORD],
      redisKey: config[CFG_REDIS__KEY]
    );
    cacheDriver
      ..setCacheSize(config[CFG_CACHE__SIZE])
      ..setLifetimeSeconds(config[CFG_CACHE__LIFESECONDS]);
  }
  log.n("Initiate cache");

  final servletEngine = new ServletEngine(config[CFG_BIND__HOST], config[CFG_BIND__PORT], config[CFG_ROOTDIR]);
  servletEngine
    ..setMaxConnection(config[CFG_MAX_CONNECTION])
    ..setCacheDriver(cacheDriver);
  log.n("Initiate servlet engine");

  if (parsed.wasParsed("dry") && parsed["dry"]) {
    log.n("Engine ignition with Dry mode");
    servletEngine.safeIgnition(() => servletEngine.doServe());
  }
  else {
    log.n("Engine ignition with real mode");
    servletEngine.safeIgnition(() => servletEngine.doServe());
  }
}
