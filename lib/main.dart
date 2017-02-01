// encoding: utf-8
import "dart:io";
import "package:args/args.dart";
import "package:smallservlet/src/logger.dart";
import "package:smallservlet/src/cache.dart";
import "package:smallservlet/src/config.dart";
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

  final config = new SSConfiguration.fromFile("", configFilePath);
  log.n("Load configuration");

  final cache = new HttpCache(config[CFG_CACHE__SIZE], config[CFG_CACHE__LIFESECONDS]);
  log.n("Initiate cache");

  cache.connectRedis();
  cache.clearPool();

  final servletEngine = new ServletEngine();
  log.n("Initiate servlet engine");
}
