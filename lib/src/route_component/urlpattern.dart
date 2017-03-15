// encoding: utf-8

library route_component;

import "dart:convert";
import "package:smallservlet/src/route_component/compiler.dart";

/// URL pattern object
/// This class contains precompiled URL matcher and presents location of exact Dart servlet.
class URLPattern {
  final URLPatternCompiler _compiler;

  String get dartFile {
    return _compiler.dartLocation;
  }

  URLPattern(String pt) : this._compiler = new URLPatternCompiler(pt);

  bool isServletPathMatched(String urlPath) {
    return _compiler.respondable(urlPath);
  }

  Map<String, String> parsePath(String urlPath) {
    return _compiler.parse(urlPath);
  }
}
