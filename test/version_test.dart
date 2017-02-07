@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/version.dart";

void main(List<String> args) {
  group("'SmallServlet version constants' test", () {
    test("Checks proper (>= 0) major version is set", () {
      expect(VERSION_MAJOR, greaterThanOrEqualTo(0));
    });

    test("Checks proper (>= 0) minor version is set", () {
      expect(VERSION_MINOR, greaterThanOrEqualTo(0));
    });

    test("Checks VERSION_STRING is composed of VERSION_MAJOR AND VERSION_MINOR", () {
      expect(VERSION_STRING, equals("${VERSION_MAJOR}.${VERSION_MINOR}"));
    });
  });

  group("'SmallServlet VersionData object' test", () {
    VersionData versionData = getPackageVersion();

    test("toString() returns same as VERSION_STRING", () {
      expect(VERSION_STRING, equals(versionData.toString()));
    });

    test("Has same major number like VERSION_MAJOR", () {
      expect(VERSION_MAJOR, equals(versionData.getMajorVersion()));
    });

    test("Has same minor number like VERSION_MINOR", () {
      expect(VERSION_MINOR, equals(versionData.getMinorVersion()));
    });
  });

  group("'VersionData class' operator overloading test", () {
    VersionData a;
    VersionData b;
    VersionData c;
    VersionData d;

    setUp(() {
      // a < c < b == d
      a = new VersionData(0, 1);
      b = new VersionData(1, 1);
      c = new VersionData(1, 0);
      d = new VersionData(1, 1);
    });

    test("0.1 < 1.0   => true", () {
      expect(a < c, equals(true));
    });

    test("0.1 > 1.0   => false", () {
      expect(a > c, equals(false));
    });

    test("1.0 > 0.1   => true", () {
      expect(c > a, equals(true));
    });

    test("1.0 < 0.1   => false", () {
      expect(c < a, equals(false));
    });

    test("1.1 == 1.1 for same objects   => true", () {
      expect(b == b, equals(true));
      expect(b.hashCode == b.hashCode, equals(true));
    });

    test("1.1 == 1.1 for different objects   => true", () {
      expect(b == d, equals(true));
      expect(b.hashCode != d.hashCode, equals(true));
    });

    test("1.1 != 1.1 for same objects   => false", () {
      expect(b != b, equals(false));
      expect(b.hashCode == b.hashCode, equals(true));
    });

    test("1.1 != 1.1 for different objects   => false", () {
      expect(b != d, equals(false));
      expect(b.hashCode != d.hashCode, equals(true));
    });

    test("1.1 <= 1.1   => true", () {
      expect(b <= b, equals(true));
    });

    test("1.1 >= 1.1   => true", () {
      expect(b >= b, equals(true));
    });
  });
}