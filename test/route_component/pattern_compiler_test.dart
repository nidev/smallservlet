@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/route_component/pattern_compiler.dart";

void main(List<String> args) {
  URLPattern pattern;

  group("'No default constructor' test", () {
    test("Throws an Exception when default constructor is called",
      () => expect(() => new URLPattern(), throws));

    test("Throws nothing when proper constructor is called", () {
      pattern = new URLPattern.compileFrom("/", "/");
    });
  });

  group("'URL without template path compilation' test", () {
    test("Compile / => /index.dart", () {
       pattern = new URLPattern.compileFrom("/", "/");

       expect(pattern.compiledPath, equals("/index.dart"));
    });
  });

  group("'URL with template path compilation' test", () {

  });

  group("'Allowed URL pattern' test", () {

  });

  group("'Disallowed URL pattern' test", () {

  });
}
