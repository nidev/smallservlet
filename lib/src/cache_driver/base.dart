// encoding: utf-8

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
   * Return lifetime in second
   */
  int getLifetimeSeconds();

  /**
   * Set lifetime length in second
   */
  void setLifetimeSeconds(int size);
  
  /**
   * Check whether cache already knows the key and confirms its valid lifetime.
   */
  bool hasValue(String key);

  /**
   * Get value from cache. This may return number type value or String type value.
   * If key is not in cache, returns null.
   * If key is in cache and outdated, return null and key and its value will be removed.
   */
  dynamic operator[](String key);

  /**
   * Compress cache immediately.
   * If set 'brutally', 50% of cached items will be removed even they are valid lifetime.
   */
  void compress(bool brutally);

  /**
   * Clear cache. While running, Driver acquires internal cache lock and pauses threads.
   */
  void emptify();

  /**
   * Return whether this driver utilizes external softwares. Softwares can be
   * databases like sqlite, Key-value storage like Redis.
   */
  bool hasBackbone();

  /**
   * Check whether backbone is healthy and can interact.
   */
  bool checkBackbone();

  /**
   * Recover backbone from malfunctioning like disconnection.
   * While running, Driver acquires internal cache lock and pauses threads.
   */
  bool recoverBackbone();
}
