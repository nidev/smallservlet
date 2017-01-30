// encoding: utf-8

import "logger.dart";
import "cache.dart";
import "config.dart";
import "version.dart";

const String TAG = "Main";

void main() {
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
