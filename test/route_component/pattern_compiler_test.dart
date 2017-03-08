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

  group("'Make query string parsed' test", () {
    test("Checks parsed result is null when no query string is provided", () {
      pattern = new URLPattern.compileFrom("/", "/");

      expect(pattern.param, isNull);
    });

    test("Checks query string is converted to Map<String, String>", () {
      pattern = new URLPattern.compileFrom("/", "/?fruit=apple&count=1");

      expect(pattern.param, isNotNull);
      expect(pattern.param, isNotEmpty);
      expect(pattern.param["fruit"], equals("apple"));
      expect(pattern.param["count"], equals("1"));
    });
  });

  group("'URL without template path compilation' test", () {
    test("Compiles / => /index.dart", () {
       pattern = new URLPattern.compileFrom("/", "/");
       expect(pattern.compiledPath, equals("/index.dart"));
    });

    test("Compiles /index.dart => /index.dart", () {
       pattern = new URLPattern.compileFrom("/index.dart", "/index.dart");
       expect(pattern.compiledPath, equals("/index.dart"));
    });

    test("Compiles /* => /*", () {
       pattern = new URLPattern.compileFrom("/*", "/*");
       expect(pattern.compiledPath, equals("/*"));
    });

    test("Compiles /* with /, it is matched", () {
       pattern = new URLPattern.compileFrom("/*", "/");
       expect(pattern.compiledPath, isNotEmpty);
    });

    test("Compiles /* with /users/, it is matched", () {
       pattern = new URLPattern.compileFrom("/*", "/users/");
       expect(pattern.compiledPath, isNotEmpty);
    });

    test("Compiles /users/ => /users/index.dart", () {
       pattern = new URLPattern.compileFrom("/users/", "/users/");
       expect(pattern.compiledPath, equals("/users/index.dart"));
    });

    test("Compiles /users/* with /users/foo, it is matched", () {
      pattern = new URLPattern.compileFrom("/users/*", "/users/foo");
      expect(pattern.compiledPath, isNotEmpty);
    });

    test("Compiles /users/index.dart => /users/index.dart", () {
       pattern = new URLPattern.compileFrom("/users/index.dart", "/users/index.dart");
       expect(pattern.compiledPath, equals("/users/index.dart"));
    });
  });

  group("'URL with template path compilation' test", () {
    test("Compiles /users/{name} with /users/foo => /users.dart with params {name: foo}", () {
       pattern = new URLPattern.compileFrom("/users/{name}", "/users/foo");
       expect(pattern.compiledPath, equals("/users.dart"));
       expect(pattern.compiledParam, isNotEmpty);
       expect(pattern.compiledParam.containsKey("name"), isTrue);
       expect(pattern.compiledParam["name"], equals("foo"));
    });

    test("Compiles /users/{name}/{age} with /users/foo/15 => /users.dart with params {name: foo, age: 15}", () {
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
    test("Does not allow using .. or . in pattern", () {
      expect(() => new URLPattern.compileFrom("/../*", "/"), throws);
      expect(() => new URLPattern.compileFrom("/./*", "/"), throws);
      expect(() => new URLPattern.compileFrom("/../../", "/"), throws);
    });

    test("Does not allow using .. or . in path", () {
      expect(() => new URLPattern.compileFrom("/{dummy}", "/.."), throws);
      expect(() => new URLPattern.compileFrom("/{dummy}", "/."), throws);
      expect(() => new URLPattern.compileFrom("/{dummy}/", "/../index.dart"), throws);
    });

    test("Throws on re-occuring of path literal in pattern after template begins", () {
      expect(() => new URLPattern.compileFrom("/a/{b}/c", "/a/b/c"), throws);
    });

    test("Throws on space or control character in template name", () {
      expect(() => new URLPattern.compileFrom("/users/{first name}", "/users/charles"), throws);
      expect(() => new URLPattern.compileFrom("/users/{space\tlocation}", "/users/earth"), throws);
      expect(() => new URLPattern.compileFrom("/users/{\r\n}", "/users/whatdidyousay"), throws);
    });

    test("Throws on non-alphanumeric template names in pattern", () {
      expect(() => new URLPattern.compileFrom("/users/{이름}", "/users/charles"), throws);
      expect(() => new URLPattern.compileFrom("/users/{場所}", "/users/earth"), throws);
      expect(() => new URLPattern.compileFrom("/users/{AAアア11}", "/users/whatdidyousay"), throws);
    });
  });
}
