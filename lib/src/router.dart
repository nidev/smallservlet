// encoding: utf-8

import "package:smallservlet/src/route_component/rule.dart";

const String TAG = "Router";

class ServletRouter {
  List<Rule> _rules;

  ServletRouter() {
    _rules = new List<Rule>();
  }

  bool _detectRoutingLoop(String pattern, String nextRoute) {
    // TODO: Detect loop in _rules. Circular redirecting will exhaust all available resources.
    throw new UnimplementedError();
  }

  bool _validateRoutingPattern(String pattern) {
    throw new UnimplementedError();
  }

  void addRoute(Rule routeRule) {
    if (!_validateRoutingPattern(routeRule.pattern)) {
      throw new Exception("Invalid URL routing rule ${routeRule.pattern} on ${routeRule.toString()}");
    }

    if (_detectRoutingLoop(routeRule.pattern, routeRule.nextRoute)) {
      throw new Exception("Circular redirection rule detected!");
    }
    else {
      // TODO: Sorted Tree. (sorted by length of pattern string)
      _rules.add(routeRule);
    }
  }
}