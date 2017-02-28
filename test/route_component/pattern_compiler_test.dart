@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/route_component/pattern_compiler.dart";

void main(List<String> args) {
  group("'No default constructor' test", () {
    test("Throws an Exception when default constructor is called",
      () => expect(() => new URLPattern(), throws));
  });

  group("'URL path sanity check' test", () {

  });

  group("'Allowed URL pattern' test", () {

  });
}
