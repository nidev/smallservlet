@TestOn("vm")
import "package:test/test.dart";
import "package:smallservlet/src/route_component/compiler.dart";

void main(List<String> args) {
  var compiler;

  group("'Make query string parsed' test", () {
    compiler = new URLPatternCompiler("/");

    test("Checks parsed result is empty when no query string is provided", () {
      expect(compiler.parse("/"), isEmpty);
    });

    test("Checks query string is converted to Map<String, String>", () {
      var params = compiler.parse("/?fruit=apple&count=1");

      expect(param, isNotNull);
      expect(param, isNotEmpty);
      expect(param["fruit"], equals("apple"));
      expect(param["count"], equals("1"));
    });
  });

  group("'URL without template path compilation' test", () {
    test("Compiles / => /index.dart", () {
       compiler = new URLPatternCompiler("/");
       expect(compiler.dartLocation, equals("/index.dart"));
    });

    test("Compiles /index.dart => /index.dart", () {
       compiler = new URLPatternCompiler("/index.dart");
       expect(compiler.dartLocation, equals("/index.dart"));
    });

    test("Compiles /* => /*", () {
       compiler = new URLPatternCompiler("/*");
       expect(compiler.dartLocation, equals("/*"));
    });

    test("Compiles /* with /, it is matched", () {
       compiler = new URLPatternCompiler("/*");
       expect(compiler.parse("/"), isNotNull); // does not throw
    });

    test("Compiles /* with /users/, it is matched", () {
      compiler = new URLPatternCompiler("/*");
      expect(compiler.parse("/users/"), isNotNull); // does not throw
    });

    test("Compiles /users/ => /users/index.dart", () {
       compiler = new URLPatternCompiler("/users/");
       expect(compiler.dartLocation, equals("/users/index.dart"));
    });

    test("Compiles /users/* with /users/foo, it is matched", () {
      compiler = new URLPatternCompiler("/users/*");
      expect(compiler.parse("/users/foo"), isNotEmpty);
    });

    test("Compiles /users/index.dart => /users/index.dart", () {
       compiler = new URLPatternCompiler("/users/index.dart", "/users/index.dart");
       expect(compiler.dartLocation, equals("/users/index.dart"));
    });
  });

  group("'URL with template path compilation' test", () {
    test("Compiles /users/{name} with /users/foo => /users.dart with params {name: foo}", () {
       compiler = new URLPatternCompiler("/users/{name}", "/users/foo");
       expect(compiler.dartLocation, equals("/users.dart"));
       expect(pattern.compiledParam, isNotEmpty);
       expect(pattern.compiledParam.containsKey("name"), isTrue);
       expect(pattern.compiledParam["name"], equals("foo"));
    });

    test("Compiles /users/{name}/{age} with /users/foo/15 => /users.dart with params {name: foo, age: 15}", () {
       compiler = new URLPatternCompiler("/users/{name}/{age}", "/users/foo/15");
       expect(compiler.dartLocation, equals("/users.dart"));
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
      expect(() => new URLPatternCompiler("/../*", "/"), throws);
      expect(() => new URLPatternCompiler("/./*", "/"), throws);
      expect(() => new URLPatternCompiler("/../../", "/"), throws);
    });

    test("Does not allow using .. or . in path", () {
      expect(() => new URLPatternCompiler("/{dummy}", "/.."), throws);
      expect(() => new URLPatternCompiler("/{dummy}", "/."), throws);
      expect(() => new URLPatternCompiler("/{dummy}/", "/../index.dart"), throws);
    });

    test("Throws on re-occuring of path literal in pattern after template begins", () {
      expect(() => new URLPatternCompiler("/a/{b}/c", "/a/b/c"), throws);
    });

    test("Throws on space or control character in template name", () {
      expect(() => new URLPatternCompiler("/users/{first name}", "/users/charles"), throws);
      expect(() => new URLPatternCompiler("/users/{space\tlocation}", "/users/earth"), throws);
      expect(() => new URLPatternCompiler("/users/{\r\n}", "/users/whatdidyousay"), throws);
    });

    test("Throws on non-alphanumeric template names in pattern", () {
      expect(() => new URLPatternCompiler("/users/{이름}", "/users/charles"), throws);
      expect(() => new URLPatternCompiler("/users/{場所}", "/users/earth"), throws);
      expect(() => new URLPatternCompiler("/users/{AAアア11}", "/users/whatdidyousay"), throws);
    });
  });
}
