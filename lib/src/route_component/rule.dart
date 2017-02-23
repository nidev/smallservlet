// encoding: utf-8
import "dart:io";

enum ROUTE_COMMAND { STATIC, DART_SERVLET, DART_SERVLET_NO_PARAM, DENIED, REDIRECT, FORWARD }
enum METHODS { GET, POST, PUT, DELETE }

/**
 * URL Route rule class
 */
class Rule {
  ROUTE_COMMAND _doRoute;
  Set<METHODS> _onMethods;
  String _pattern;
  String _nextRoute;

  Rule(this._doRoute, this._pattern, this._onMethods);


  String onRedirect(HttpRequest req, HttpResponse res) {
    throw new UnimplementedError();
  }

  String onForward() {
    throw new UnimplementedError();
  }
}
