// encoding: utf-8
import "package:smallservlet/src/cache_driver/base.dart";
import "package:redis/redis.dart";

class RedisCacheDriver implements BaseCacheDriver {
  /**
   * Return cache size in the number of Key-Value items
   */
  int getCacheSize() {
    throw new UnimplementedError();
  }

  /**
   * Set cache size in the number of Key-Value items
   */
  void setCacheSize(int size) {
    throw new UnimplementedError();
  }

  /**
   * Return lifetime in second
   */
  int getLifetimeSeconds() {
    throw new UnimplementedError();
  }

  /**
   * Set lifetime length in second
   */
  void setLifetimeSeconds(int size) {
    throw new UnimplementedError();
  }

  /**
   * Check whether cache already knows the key and confirms its valid lifetime.
   */
  bool hasValue(String key) {
    throw new UnimplementedError();
  }

  /**
   * Get value from cache. This may return number type value or String type value.
   * If key is not in cache, returns null.
   * If key is in cache and outdated, return null and key and its value will be removed.
   */
  dynamic operator[](String key) {
    throw new UnimplementedError();
  }

  /**
   * Compress cache immediately.
   * If set 'brutally', 50% of cached items will be removed even they are valid lifetime.
   */
  void compress(bool brutally) {
    throw new UnimplementedError();
  }

  /**
   * Clear cache. While running, Driver acquires internal cache lock and pauses threads.
   */
  void emptify() {
    throw new UnimplementedError();
  }

  /**
   * Return whether this driver utilizes external softwares. Softwares can be
   * databases like sqlite, Key-value storage like Redis.
   */
  bool hasBackbone() {
    throw new UnimplementedError();
  }

  /**
   * Check whether backbone is healthy and can interact.
   */
  bool checkBackbone() {
    throw new UnimplementedError();
  }

  /**
   * Recover backbone from malfunctioning like disconnection.
   * While running, Driver acquires internal cache lock and pauses threads.
   */
  bool recoverBackbone() {
    throw new UnimplementedError();
  }
}
