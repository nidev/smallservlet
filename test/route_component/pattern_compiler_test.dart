@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/route_component/pattern_compiler.dart";

void main(List<String> args) {
  var pattern;

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

    test("Compile /index.dart => /index.dart", () {
       pattern = new URLPattern.compileFrom("/index.dart", "/index.dart");
       expect(pattern.compiledPath, equals("/index.dart"));
    });

    test("Compile * => /*", () {
       pattern = new URLPattern.compileFrom("*", "*");
       expect(pattern.compiledPath, equals("/*"));
    });

    test("Compile /* => /*", () {
       pattern = new URLPattern.compileFrom("*", "*");
       expect(pattern.compiledPath, equals("/*"));
    });

    test("Compile /users/ => /users/index.dart", () {
       pattern = new URLPattern.compileFrom("/users/", "/users/");
       expect(pattern.compiledPath, equals("/users/index.dart"));
    });

    test("Compile /users/index.dart => /users/index.dart", () {
       pattern = new URLPattern.compileFrom("/users/index.dart", "/users/index.dart");
       expect(pattern.compiledPath, equals("/users/index.dart"));
    });
  });

  group("'URL with template path compilation' test", () {
    test("Compile /users/{name} with /users/foo => /users.dart with params {name: foo}", () {
       pattern = new URLPattern.compileFrom("/users/{name}", "/users/foo");
       expect(pattern.compiledPath, equals("/users.dart"));
       expect(pattern.compiledParam, isNotEmpty);
       expect(pattern.compiledParam.containsKey("name"), isTrue);
       expect(pattern.compiledParam["name"], equals("foo"));
    });

    test("Compile /users/{name}/{age} with /users/foo/15 => /users.dart with params {name: foo, age: 15}", () {
       pattern = new URLPattern.compileFrom("/users/{name}/{age}", "/users/foo/15");
       expect(pattern.compiledPath, equals("/users.dart"));
       expect(pattern.compiledParam, isNotEmpty);
       expect(pattern.compiledParam.containsKey("name"), isTrue);
       expect(pattern.compiledParam["name"], equals("foo"));
       expect(pattern.compiledParam.containsKey("age"), isTrue);
       expect(pattern.compiledParam["age"], equals("15"));
    });
  });

  group("'Preserving orignal query strings' test", () {

  });

  group("'Disallowed URL pattern' test", () {

  });
}
