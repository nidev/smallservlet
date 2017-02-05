@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/cache_driver/redis.dart";

void main(List<String> arguments) {

  RedisCacheDriver redisCacheDriver;

  setUp(() {
    redisCacheDriver = new RedisCacheDriver();
  });

  group("RedisCacheDriver default specifications test", () {
    test("Has default cache size",
      () => expect(redisCacheDriver.getCacheSize(), greaterThan(0)));

    test("Has default lifetime seconds",
      () => expect(redisCacheDriver.getLifetimeSeconds(), greaterThan(0)));

    test("Has cache backbone",
      () => expect(redisCacheDriver.hasBackbone(), equals(true)));

    test("Can check cache backbone health",
      () => expect(redisCacheDriver.checkBackbone(), equals(true)));

    test("Can recover cache backbone from failure",
      () => expect(redisCacheDriver.recoverBackbone(), equals(true)));
  });

  tearDown(() {
    redisCacheDriver.emptify();
  });
}
