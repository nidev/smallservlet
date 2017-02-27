// encoding: utf-8
import "dart:io";
import "package:smallservlet/src/route_component/pattern_compiler.dart";

/// Available actions on SmallServlet routing rule
enum ROUTE_COMMAND {
  /// Serves static datum/file in exact rootdir path (i.e. http://localhost/imgs/image.png will serve $rootdir/imgs/image.png)
  STATIC,
  /// Serves Dart-based servlet in Isolated context (See [Dart Isolate API](https://api.dartlang.org/stable/1.22.1/dart-isolate/Isolate-class.html) on official site)
  DART_SERVLET,
  /// Serves Dart-based servlet in Isolated context, but wipes all params (represented as HTTP query string) before executing.
  DART_SERVLET_NO_PARAM,
  /// Will serve error page with error code instead of executing or serving a content
  DENIED,
  /// Redirects to another Dart-based servlet or static content
  REDIRECT,
  /// Requested servlet will not handle request, instead, preserving all parameters, delegated servlet or static content will be done/provided.
  FORWARD
}

/// Predefined allowed HTTP methods
enum METHODS {
  /// HTTP GET method
  GET,
  /// HTTP POST method
  POST,
  /// HTTP PUT method
  PUT,
  /// HTTP DELETE method
  DELETE
}

/// URL Routing rule for SmallServlet and router.dart
class Rule {
  final ROUTE_COMMAND command;
  final Set<METHODS> acceptedMethods;
  final String pattern;
  final String nextRoute;

  Rule(ROUTE_COMMAND route_command, Set<METHODS> methods, String stringPattern, String nextRoutePath) :
    command = route_command,
    acceptedMethods = methods,
    pattern = stringPattern,
    nextRoute = nextRoutePath;

  bool isMatched(String url) {
    URLPattern pattern = new URLPattern.compileFrom(this.pattern, url);
    return pattern.isCompiled();
  }

  String onRedirect(HttpRequest req, HttpResponse res) {
    throw new UnimplementedError();
  }

  String onForward() {
    throw new UnimplementedError();
  }
}
