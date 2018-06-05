@TestOn("vm")
import "dart:async";
import "package:test/test.dart";
import "package:smallservlet/src/cache_driver/redis.dart";

const String DRIVER_TEST_KEY_PREFIX = "default_spec_test";

void main() {
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
      expect(() => new RedisCacheDriver(redisKey: ""), throwsA);
    });

    test("Gets error on trying to set cache size to number less than zero", () {
      // TODO: Test with more negative numbers
      expect(() => redisCacheDriver.setCacheSize(-1), throwsA);
    });

    test("Gets error on trying to set lifetime seconds to number less than zero", () {
      // TODO: Test with more negative numbers
      expect(() => redisCacheDriver.setLifetimeSeconds(-1), throwsA);
    });
  });

  group("'Basic cache function' test", () {
    const List<String> paths = const [
      "/user",
      "/user/1",
      "/user/1?test=1"
    ];

    setUp(() async {
      await redisCacheDriver.checkBackbone();
    });

    test("Tries to save an item", () async {
      await redisCacheDriver.store(paths[0], "1");
      expect(await redisCacheDriver.hasKey(paths[0]), equals(true));
    });

    test("Tries to save multiple items", () async {
      List<Future> storingTasks = new List<Future>();

      // Enqueuing Futures that request storing an item
      paths.forEach((path) {
        storingTasks.add(redisCacheDriver.store(path, "1"));
      });

      // Waiting for everything is done before check phrases.
      await Future.wait(storingTasks);

      paths.forEach((path) async {
        expect(await redisCacheDriver.hasKey(path), equals(true));
      });
    });

    tearDown(() async {
      await redisCacheDriver.emptify();
      await redisCacheDriver.recoverBackbone();
    });
  });
}
