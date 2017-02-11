@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/cache_driver/redis.dart";

void main(List<String> arguments) {

  RedisCacheDriver redisCacheDriver;
  redisCacheDriver = new RedisCacheDriver(redisKey: "default_spec_test");
  
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
}
