// encoding: utf-8
import "package:smallservlet/src/cache_driver/base.dart";

class HttpCache {
  BaseCacheDriver _driver;

  HttpCache() {
    throw new Exception("Do not construct cache object with default constructor. Use HttpCache.withDriver() instead.");
  }

  HttpCache.withDriver(BaseCacheDriver cacheDriver) {
    _driver = cacheDriver;
  }

  dynamic operator[](String key) {
    throw new UnimplementedError();
  }
}
