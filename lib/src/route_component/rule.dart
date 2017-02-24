// encoding: utf-8
import "dart:io";

enum ROUTE_COMMAND { STATIC, DART_SERVLET, DART_SERVLET_NO_PARAM, DENIED, REDIRECT, FORWARD }
enum METHODS { GET, POST, PUT, DELETE }

/**
 * URL Route rule class
 */
class Rule {
  final ROUTE_COMMAND command;
  final Set<METHODS> acceptedMethods;
  final String pattern;
  final String nextRoute;

  Rule(this.command, this.acceptedMethods, this.pattern, this.nextRoute);


  String onRedirect(HttpRequest req, HttpResponse res) {
    throw new UnimplementedError();
  }

  String onForward() {
    throw new UnimplementedError();
  }
}
