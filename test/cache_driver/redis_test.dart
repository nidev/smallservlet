@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/cache_driver/redis.dart";

const String DRIVER_TEST_KEY_PREFIX = "default_spec_test";

void main(List<String> arguments) {
  // Generate randomized suffix for
  final String testKey = "${DRIVER_TEST_KEY_PREFIX}:${new DateTime.now().microsecond}";

  RedisCacheDriver redisCacheDriver;
  redisCacheDriver = new RedisCacheDriver(redisKey: testKey);
  
  group("RedisCacheDriver default specifications test", () {
    test("Has default cache size",
      () => expect(redisCacheDriver.getCacheSize(), greaterThan(0)));

    test("Has default lifetime seconds",
      () => expect(redisCacheDriver.getLifetimeSeconds(), greaterThan(0)));

    test("Has cache backbone",
      () => expect(redisCacheDriver.hasBackbone(), equals(true)));

    test("Can check cache backbone health",
      () => expect(redisCacheDriver.checkBackbone(), completion(equals(true))));

    test("Can recover cache backbone from failure", () {
      expect(redisCacheDriver.checkBackbone(), completion(equals(true)));
      expect(redisCacheDriver.recoverBackbone(), completion(equals(true)));
    });
    
    tearDown(() async {
      await redisCacheDriver.recoverBackbone();
    });
  });

  group("'Parameter guard' test", () {
    test("Blank redis key throws exception at constructor", () {
      expect(() => new RedisCacheDriver(redisKey: ""), throws);
    });

    test("Gets error on trying to set cache size to number less than zero", () {
      // TODO: Test with more negative numbers
      expect(() => redisCacheDriver.setCacheSize(-1), throws);
    });

    test("Gets error on trying to set lifetime seconds to number less than zero", () {
      // TODO: Test with more negative numbers
      expect(() => redisCacheDriver.setLifetimeSeconds(-1), throws);
    });
  });

  group("'Basic cache function' test", () {
    setUp(() async {
      await redisCacheDriver.checkBackbone();
    });

    test("Tries to save an item", () async {
      // XXX: operator[] is not an async/await function. There is a possibility of cache miss
      await redisCacheDriver.store("fireball", "1");
      expect(redisCacheDriver.hasValue("fireball"), completion(equals(true)));
    });

    tearDown(() async {
      await redisCacheDriver.emptify();
      await redisCacheDriver.recoverBackbone();
    });
  });
}
