// encoding: utf-8
import "dart:async";
import "package:redis/redis.dart";
import "package:smallservlet/src/cache_driver/base.dart";

const String REDIS_INDEX_SUFFIX = ":L";
const String REDIS_HASH_SUFFIX = ":H";

class RedisCacheDriver implements BaseCacheDriver {
  RedisConnection _redis;
  Function _redisCommander;
  Function _redisMultiCommander;
  int _lifetimeSeconds = 120;
  int _cacheSize = 36;
  
  String _redisHashKey;
  String _redisIndexKey;

  void set _redisKey(String baseKey) {
    if (baseKey == null || baseKey == "") {
      throw new Exception("Cache key can not be null or empty string");
    }

    _redisIndexKey = "${baseKey}${REDIS_INDEX_SUFFIX}";
    _redisHashKey = "${baseKey}${REDIS_HASH_SUFFIX}";
  }

  RedisCacheDriver({String host = "127.0.0.1", int port = 6379, String password = "", String redisKey = ""}) {
    _redis = new RedisConnection();
    _redisKey = redisKey;

    // Construct Commander closure
    _redisCommander = (redisCommand) async {
      Command command = await _redis.connect(host, port);

      String authenticate = "OK";
      if (password.isNotEmpty) {
        authenticate = await command.send_object(["AUTH", password]);
      }

      if (authenticate == "OK") {
        return command.send_object(redisCommand);
      }
      else {
        throw new Exception("Incorrect password. Redis access is unauthorized.");
      }
    };

    _redisMultiCommander = (List<List<String>> redisCommands) async {
      Command command = await _redis.connect(host, port);

      String authenticate = "OK";
      if (password.isNotEmpty) {
        authenticate = await command.send_object(["AUTH", password]);
      }

      if (authenticate == "OK") {
        return command.multi().then((Transaction t) {
          t.pipe_start();
          
          redisCommands.forEach((redisCommand) {
            t.send_object(redisCommand);
          });

          t.pipe_end();
          return t.exec();
        });
      }
      else {
        throw new Exception("Incorrect password. Redis access is unauthorized.");
      }
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
  }

  /**
   * Get how many items are in cache
   */
  Future<int> countItems() async {
    return _redisCommander(["ZCOUNT", _redisIndexKey, "-inf", "+inf"]);
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
  Future<bool> hasValue(String key) {
    int found = _redisCommander(["Z"]);
  }

  /**
   * Get value from cache. This may return number type value or String type value.
   * If key is not in cache, returns null.
   * If key is in cache and outdated, return null and key and its value will be removed.
   */
  Future<dynamic> operator[](String key) {
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
  Future emptify() async {
    _redisMultiCommander([
      ["LTRIM", ]
      ]);
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
  Future<bool> checkBackbone() async {
    throw new UnimplementedError();
  }

  /**
   * Recover backbone from malfunctioning like disconnection.
   * While running, Driver acquires internal cache lock and pauses threads.
   */
  Future<bool> recoverBackbone() async {
    throw new UnimplementedError();
  }
}
