// encoding: utf-8

import "dart:async";

/**
 * Abstract class & Interface declaration for CacheDriver classes.
 */
abstract class BaseCacheDriver {
  /**
   * Return cache size in the number of Key-Value items
   */
  int getCacheSize();

  /**
   * Set cache size in the number of Key-Value items
   */
  void setCacheSize(int size);

  /**
   * Get how many items are in cache
   */
  Future<int> countItems();

  /**
   * Return lifetime in second
   */
  int getLifetimeSeconds();

  /**
   * Set lifetime length in second
   */
  void setLifetimeSeconds(int seconds);

  /**
   * Check whether cache already knows the key and confirms its valid lifetime.
   */
  Future<bool> hasValue(String key);

  /**
   * Get value from cache. This may return number type value or String type value.
   * If key is not in cache, returns null.
   * If key is in cache and outdated, return null and key and its value will be removed.
   */
  Future<dynamic> operator[](String key);

  /**
   * Short-hand of storeAsync(key, value). only supports synchronous operation.
   * Due to limitation of Dart specification, you are discouraged to implement this.
   * (Just throwing an exception would be better)
   */
  void operator[]=(String key, dynamic value);

  /**
   * Set value to cache. If cache has already same key and key is still valid, no overwriting/updating occurs.
   * Asynchronous version of operator[]=, due to limitation of Dart specification.
   */
  Future<Null> store(String key, dynamic value);
  
  /**
   * Compress cache immediately.
   * If set 'brutally', 50% of cached items will be removed even they are valid lifetime.
   */
  void compress(bool brutally);

  /**
   * Clear cache. While running, Driver acquires internal cache lock and pauses threads.
   */
  Future<Null> emptify();

  /**
   * Return whether this driver utilizes external softwares. Softwares can be
   * databases like sqlite, Key-value storage like Redis.
   */
  bool hasBackbone();

  /**
   * Check whether backbone is healthy and can interact.
   */
  Future<bool> checkBackbone();

  /**
   * Recover backbone from malfunctioning like disconnection.
   * While running, Driver acquires internal cache lock and pauses threads.
   */
  Future<bool> recoverBackbone();
}
