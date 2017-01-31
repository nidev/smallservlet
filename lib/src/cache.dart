// encoding: utf-8
import "package:redis/redis.dart";

class HttpCache {
  HttpCache(int cacheSize, int lifetime_secs) {
    throw new UnimplementedError();
  }

  void connectRedis() {
    throw new UnimplementedError();
  }

  void clearPool() {
    throw new UnimplementedError();
  }
  
  Object operator[](String key) {
    throw new UnimplementedError();
    return null;
  }
}
