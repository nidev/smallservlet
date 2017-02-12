// encoding: utf-8
import "dart:async";
import "package:redis/redis.dart";
import "package:smallservlet/src/cache_driver/base.dart";
import "package:smallservlet/src/logger.dart";

const String TAG = "RedisCacheDriver";
const String REDIS_INDEX_SUFFIX = ":L";
const String REDIS_HASH_SUFFIX = ":H";

class RedisCacheDriver implements BaseCacheDriver {
  RedisConnection _redis;
  Command _command;
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
    _redisCommander = (redisQuery) async {
      if (_command == null) {
        _command = await _redis.connect(host, port);
      }

      String authenticate = "OK";
      if (password.isNotEmpty) {
        authenticate = await _command.send_object(["AUTH", password]);
      }

      if (authenticate == "OK") {
        return _command.send_object(redisQuery);
      }
      else {
        throw new Exception("Incorrect password. Redis access is unauthorized.");
      }
    };

    _redisMultiCommander = (List<List<String>> redisQueries) async {
      if (_command == null) {
        _command = await _redis.connect(host, port);
      }

      String authenticate = "OK";
      if (password.isNotEmpty) {
        authenticate = await _command.send_object(["AUTH", password]);
      }

      if (authenticate == "OK") {
        return _command.multi().then((Transaction t) {
          redisQueries.forEach((query) {
            print("Execute ${query.join(' ')}");
            t.send_object(query);
          });
          t.exec();
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
    if (size < 0) {
      throw new Exception("Cache size can not be negative integer");
    }
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
    if (seconds < 0) {
      throw new Exception("Lifetime can not be negative integer");
    }
    _lifetimeSeconds = seconds;
  }

  /**
   * Check whether cache already knows the key and confirms its valid lifetime.
   */
  Future<bool> hasValue(String key) async {
    dynamic response = await _redisCommander(["SISMEMBER", _redisIndexKey, key]);
    if (response is int) {
      return new Future<bool>.value(response == 1);
    }
    
    Logger log = new Logger(TAG);
    log.w("Unexpected value from _redisCommander:SISMEMBER, ${response.toString()}");

    return new Future<bool>.value(false);
  }

  /**
   * Get value from cache. This may return number type value or String type value.
   * If key is not in cache, returns null.
   * If key is in cache and outdated, return null and key and its value will be removed.
   */
  Future<dynamic> operator[](String key) async {
    bool keyAvailable = await hasValue(key);
    if (keyAvailable) {
      return _redisCommander(["HGET", _redisHashKey, key]);
    }

    return new Future<Null>.value(null);
  }

  /**
   * Set value to cache. If cache has already same key and key is still valid, no overwriting/updating occurs.
   * This operation does not support async/await.
   * Thus, If in bad case, Acquiring goes first before storing made by this operation. That is cache miss.
   * 
   * You're discouraged to call this unless you know what you do. Instead, use store(key, value).
   */
  void operator[]=(String key, dynamic value) {
    Logger log = new Logger(TAG);
    log.w("Calling asynchronous function from synchronous function without await.");
    log.w("Avoid calling operator []=, instead use store(key, value)");

    store(key, value);
  }

  /**
   * Set value to cache. If cache has already same key and key is still valid, no overwriting/updating occurs.
   */
  Future<Null> store(String key, dynamic value) async {
    await _redisMultiCommander([
      ["SADD", _redisIndexKey, key],
      ["HSET", _redisHashKey, key, value.toString()]
    ]);

    return new Future<Null>.value(null);
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
  Future<Null> emptify() async {
    await _redisMultiCommander([
      ["DEL", _redisIndexKey],
      ["DEL", _redisHashKey]]);
  }

  /**
   * Return whether this driver utilizes external softwares. Softwares can be
   * databases like sqlite, Key-value storage like Redis.
   */
  bool hasBackbone() {
    return true;
  }

  /**
   * Check whether backbone is healthy and can interact.
   */
  Future<bool> checkBackbone() async {
    String response = await _redisCommander(["PING"]);
    return new Future<bool>.value(response == "PONG");
  }

  /**
   * Recover backbone from malfunctioning like disconnection.
   * While running, Driver acquires internal cache lock and pauses threads.
   */
  Future<bool> recoverBackbone() async {
    Logger log = new Logger(TAG);

    try {
      if (_redis != null && _command != null) {
        log.d("Destroy previous connection");
        await _redis.close();
        _redis = null;
        _command = null;

        log.d("New RedisConnection is created. Actual connection will be made on sending command");
        _redis = new RedisConnection();
      }
      else {
        log.d("RedisConnection has not been made before and reconnection is skipped");
      }

      return new Future<bool>.value(true);
    }
    catch (e) {
      log.e("------------- recover backbone failed --------------");
      log.e(e);
      log.e("----------------------------------------------------");
    }

    return new Future<bool>.value(false);
  }
}
