// encoding: utf-8
import "dart:async";
import "package:redis/redis.dart";
import "package:smallservlet/src/cache_driver/base.dart";

class RedisCacheDriver implements BaseCacheDriver {
  RedisConnection _redis;
  Fucntion _redisCommander;
  int _lifetimeSeconds = 0;
  int _cacheSize = 0;

  RedisCacheDriver({String host = "127.0.0.1", int port = 6379, String password = ""}) {
    _redis = new RedisConnection();

    // Construct Commander closure
    _redisCommander = (redisCommandArray) {
      _redis.connect(host, port)
        .then((command) {
          Future<String> authenticate;

          if (password.isNotEmpty) {
            authenticate = command.send_object(["AUTH", password]);
          }
          else {
            authenticate = new Future<String>.value("OK");
          }

          authenticate.then((response) {
            if (response == "OK") {
              return command.send_object(redisCommandArray);
            }
            else {
              throw new Exception("Incorrect password. Redis access is unauthroized.");
            }
          })
          .then((response) {
            return response;
          })
          .catchError((e) {
            // TODO: Propagate error
            return null;
          });

        });
      };
  }

  /**
   * Return cache size in the number of Key-Value items
   */
  int getCacheSize() {
    return _cacheSize;
  }

  /**
   * Set cache size in the number of Key-Value items
   */
  void setCacheSize(int size) {
    _cacheSize = size;

    // TODO: Manage Redis
  }

  /**
   * Get how many items are in cache
   */
  int countItems() {
    throw new UnimplementedError();
  }

  /**
   * Return lifetime in second
   */
  int getLifetimeSeconds() {
    return _lifetimeSeconds;
  }

  /**
   * Set lifetime length in second
   */
  void setLifetimeSeconds(int seconds) {
    _lifetimeSeconds = seconds;
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
   * Set value to cache. If cache has already same key and key is still valid, no overwriting/updating occurs.
   */
  void operator[]=(String key, dynamic value) {
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
