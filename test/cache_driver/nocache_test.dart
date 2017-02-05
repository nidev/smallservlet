@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/cache_driver/nocache.dart";

void main() {
  NoCacheDriver noCacheDriver;
  setUp(() {
    noCacheDriver = new NoCacheDriver();
  });

  group("NoCacheDriver default specifications test", () {
    test("Has zero cache size",
      () => expect(noCacheDriver.getCacheSize(), equals(0)));

    test("Has zero lifetime seconds",
      () => expect(noCacheDriver.getLifetimeSeconds(), equals(0)));

    test("Does not have cache backbone",
      () => expect(noCacheDriver.hasBackbone(), equals(false)));

    test("Can not check cache backbone health",
      () => expect(noCacheDriver.checkBackbone(), equals(false)));

    test("Can not recover cache backbone from failure",
      () => expect(noCacheDriver.recoverBackbone(), equals(false)));
  });

  group("'No configurable option for NoCacheDriver' test", () {
    test("Tries to set cache size to number greater than zero, but always gets zero", () {
      Iterable range = new Iterable.generate(100, (i) => i);
      for (int x in range) {
        noCacheDriver.setCacheSize(x);
        expect(noCacheDriver.getCacheSize(), equals(0));
      }
    });

    test("Tries to set cache size to number less than zero, but always gets zero", () {
      Iterable range = new Iterable.generate(100, (i) => i);
      for (int x in range) {
        noCacheDriver.setCacheSize(-x);
        expect(noCacheDriver.getCacheSize(), equals(0));
      }
    });

    test("Tries to set lifetime seconds to number greater than zero, but always gets zero", () {
      Iterable range = new Iterable.generate(100, (i) => i);
      for (int x in range) {
        noCacheDriver.setCacheSize(x);
        expect(noCacheDriver.getCacheSize(), equals(0));
      }
    });

    test("Tries to set lifetime seconds to number less than zero, but always gets zero", () {
      Iterable range = new Iterable.generate(100, (i) => i);
      for (int x in range) {
        noCacheDriver.setCacheSize(-x);
        expect(noCacheDriver.getCacheSize(), equals(0));
      }
    });
  });

  group("'NoCacheDriver can not store anything' test", () {
    const List<String> paths = const [
      "/user",
      "/user/1",
      "/user/1?test=1"
    ];
    setUp(() {
      paths.forEach((path) {
        noCacheDriver[path] = "1";
      });
    });

    test("Check nothing is available in cache", () {
      paths.forEach((path) {
        expect(noCacheDriver[path], equals(null));
      });
    });

    tearDown(() {
      noCacheDriver.emptify();
    });
  });

  group("Emptifying", () {
    test("Check it really works", () {
      noCacheDriver.emptify();
      expect(noCacheDriver.countItems(), equals(0));
    });
  });

  tearDown(() {
    noCacheDriver.emptify();
  });
}
