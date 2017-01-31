// encoding: utf-8

import "package:smallservlet/src/logger.dart";
import "package:smallservlet/src/cache.dart";
import "package:smallservlet/src/config.dart";
import "package:smallservlet/version.dart";

const String TAG = "Main";

void bootstrap(List<String> arguments) {
  final log = new Logger("Main");
  final appVersion = getPackageVersion();

  log.n("Boot up SmallServlet ${appVersion.toString()}");

  final config = new SSConfiguration.fromFile("", "");
  log.n("Load configuration");

  final cache = new HttpCache(config[CFG_CACHE__SIZE], config[CFG_CACHE__LIFESECONDS]);
  log.n("Initiate cache");

  cache.connectRedis();
  cache.clearPool();

  final servletEngine = new ServletEngine();
  log.n("Initiate servlet engine");
}
