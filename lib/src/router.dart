// encoding: utf-8

import "package:smallservlet/src/route_component/rule.dart";

const String TAG = "Router";

class ServletRouter {
  List<Rule> _rules;

  ServletRouter() {
    _rules = new List<Rule>();
  }

  Rule lookup(String path) {
    for (Rule rule in _rules) {
      if (rule.destination == path) {
        return rule;
      }
    }

    return null;
  }

  /// Find forwarded pattern in list. If destination rule redirects/forwards current request,
  /// it means loop.
  bool _detectRoutingLoop(Rule rule) {
    var nextRoute = lookup(rule.nextRoute);

    if (nextRoute != null && nextRoute.pattern == rule.pattern) {
      return true;
    }

    return false;
  }

  void addRoute(Rule routeRule) {
    if (_detectRoutingLoop(routeRule)) {
      throw new Exception("Circular redirection rule detected!");
    }
    else {
      _rules.add(routeRule);
      _rules.sort((sideA, sideB) => sideA.pattern.compareTo(sideB.pattern));
    }
  }
}
