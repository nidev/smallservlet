// encoding: utf-8
import "dart:async";
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
   * Get how many items are in cache
   */
  Future<int> countItems() {
    return new Future<int>.value(0);
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
  Future<bool> hasValue(String key) async {
    return new Future<bool>.value(false);
  }

  /**
   * Get value from cache. This may return number type value or String type value.
   * If key is not in cache, returns null.
   * If key is in cache and outdated, return null and key and its value will be removed.
   */
  Future<dynamic> operator[](String key) async {
    return new Future.value(null);
  }

  /**
   * Set value to cache. If cache has already same key and key is still valid, no overwriting/updating occurs.
   */
  void operator[]=(String key, dynamic value) {
    ;
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
  Future emptify() async {
    return new Future.value(null);
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
  Future<bool> checkBackbone() async {
    return new Future<bool>.value(false);
  }

  /**
   * Recover backbone from malfunctioning like disconnection.
   * NoCacheDriver does nothing.
   */
  Future<bool> recoverBackbone() async {
    return new Future<bool>.value(false);
  }
}
