// encoding: utf-8

import "package:smallservlet/src/exception/exceptions.dart";

/// URL pattern compiler
/// This class will compile URL (in String) to Pattern object.
///
/// Path separator is forward slash (/). Space(s) after/before pattern will be trimmed.
///
/// Following patterns are available and valid:
/// 1. * (Only allowed at tail. Only one occurrence is allowed. i.e. pattern '/users/*' is valid and will hook everything)
/// 2. / (translated into /index.dart)
/// 3. /users (translated into /users.dart)
/// 4. /users/ (translated into /users/index.dart)
/// 5. /users/{name} (translated into /users.dart with params = {name: (name here)})
/// 6. /users/account_info/{name} (translated into /users/account_info.dart with params = {name: (name here)})
/// 7. /users/account_info.dart/{name} (Sure, this is valid.)
/// 8. /users/account_info/{name}/{location}
/// (translated into /users/account_info.dart with params = {name: (name here), location: (location here)}. Only allows consecuted template(s). See below.)
/// 9. And with query string(?key1=value1&key2=value2...) with above patterns
///
/// Following patterns are not valid:
/// 1. Mixing .. or . in pattern
/// (not allowed for security reason)
/// 2. /users/{name}/not_admin/{name}
/// (Can not recognize which one is exact Dart-based servlet)
/// 3. /users/{full name}/{previous location}
/// (Do not include space directly for template name. If space is encoded with percent encoding, it is okay)
/// 4. /users/add/{なまえ}/{生日}/{사는곳}
/// (Non-ASCII characters in parameter template name, but parameter values with Non-ASCII characters are allowed when they are encoded in percent encoding.)
class URLPattern {
  final RegExp _unwrapper = new RegExp(r"\{([a-zA-Z0-9%]+)\}");
  String compiledPath;
  Map<String, String> compiledParam;

  URLPattern() {
    throw new Exception("must construct from URLPattern.compileFrom() instead");
  }

  URLPattern.compileFrom(String patternString, String urlPath) {
    var patternTokens = patternString.trim().split("/");
    var pathTokens = urlPath.trim().split("/");
    var rebuiltPath = <String>[];
    var rebuiltParam = <String, String>{};
    var noMorePath = false;

    if (patternTokens.length != pathTokens.length) {
      throw new PatternCompilerError("Pattern can not be matched with given path. (Pattern tokens:${patternTokens.length}, given URL tokens: ${pathTokens.length})");
    }

    for (var index = 0, length = patternTokens.length; index < length; index++) {
      var pattern = patternTokens[index];
      var item = pathTokens[index];

      // Accept only one asterisk, at tail position
      if (pattern == "*") {
        if (!noMorePath) {
          rebuiltPath.add(pattern);
          break;
        }
        else {
          throw new PatternCompilerError("Since template string started, you can not use asterisk more.");
        }
      }

      if (pattern.startsWith("{")) {
        // validating closing curly bracket
        if (!pattern.endsWith("}")) {
          throw new PatternCompilerError("Enclose template brackets correctly. ($pattern)");
        }

        // last added path is a Dart servlet. This will conclude accepting
        // servlet path.
        noMorePath = true;

        if (rebuiltPath.isEmpty) {
          // This one will be a index.dart
          rebuiltPath.add("index.dart");
        }
        else {
          if (!rebuiltPath.last.endsWith(".dart")) {
            // Make last path item to Dart servlet
            var estimatedServlet = rebuiltPath.last + ".dart";

            rebuiltPath.removeLast();
            rebuiltPath.add(estimatedServlet);
          }
        }

        // And match place...
        Match unwrapped = _unwrapper.firstMatch(pattern);
        if ((unwrapped?.groupCount ?? 0) == 1) {
          var pathName = unwrapped.group(1);
          rebuiltParam[pathName] = pathTokens[index];
        }
        else {
          // Void template name
          throw new PatternCompilerError("Template name can not be empty or filled with space");
        }
      }
      else {
        // Check whether it can accept more path item
        if (noMorePath) {
          throw new PatternCompilerError("Can not accept more path, as template matching started before");
        }

        // detecting dangling brackets
        if (pattern.allMatches("[\{\}]")) {
          throw new PatternCompilerError("Incomplete template bracket(s) are found. ($pattern)");
        }

        if (pattern == item) {
          if (rebuiltPath.isEmpty) {
            rebuiltPath.add(item);
          }
          else {
            if (pattern == "") {
              rebuiltPath.add("index.dart");
              noMorePath = true;
            }
            else {
              rebuiltPath.add(item);
            }
          }
        }
        else {
          throw new PatternCompilerError("Unexpected pattern. (Expected: $pattern, Instead: $item)");
        }
      }
    }

    compiledPath = rebuiltPath.join("/");
    if (!compiledPath.startsWith("/")) {
      compiledPath = "/$compiledPath";
    }

    compiledParam = rebuiltParam;

    // TODO: If successful, create Rule object
  }
}
