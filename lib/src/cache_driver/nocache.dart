// encoding: utf-8
import "package:smallservlet/src/cache_driver/base.dart";

class NoCacheDriver implements BaseCacheDriver {
  /**
   * Return cache size in the number of Key-Value items
   */
  int getCacheSize() {
    return 0;
  }

  /**
   * Set cache size in the number of Key-Value items
   */
  void setCacheSize(int size) {
    int _ = size;
  }

  /**
   * Return lifetime in second
   */
  int getLifetimeSeconds() {
    return 0;
  }

  /**
   * Set lifetime length in second
   */
  void setLifetimeSeconds(int seconds) {
    int _ = seconds;
  }

  /**
   * Check whether cache already knows the key and confirms its valid lifetime.
   */
  bool hasValue(String key) {
    return false;
  }

  /**
   * Get value from cache. This may return number type value or String type value.
   * If key is not in cache, returns null.
   * If key is in cache and outdated, return null and key and its value will be removed.
   */
  dynamic operator[](String key) {
    return null;
  }

  /**
   * Compress cache immediately.
   * NoCacheDriver does nothing.
   */
  void compress(bool brutally) {
    bool _ = brutally;
  }

  /**
   * Clear cache. NoCacheDriver does nothing.
   */
  void emptify() {
    ;
  }

  /**
   * Return whether this driver utilizes external softwares. Softwares can be
   * databases like sqlite, Key-value storage like Redis.
   */
  bool hasBackbone() {
    return false;
  }

  /**
   * Check whether backbone is healthy and can interact.
   */
  bool checkBackbone() {
    return false;
  }

  /**
   * Recover backbone from malfunctioning like disconnection.
   * NoCacheDriver does nothing.
   */
  bool recoverBackbone() {
    return false;
  }
}
