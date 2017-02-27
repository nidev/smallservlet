// encoding: utf-8

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
  URLPattern() {
    throw new UnimplementedError();
  }

  URLPattern.compileFrom(String patternString, String urlPath) {
    var patternTokens = patternString.trim().split("/");
    var pathTokens = urlPath.trim().split("/");
    var rebuiltPath = <String>[];
    var rebuiltParam = <String, String>{};
    var foundAsteriskOnce = false;

    if (!patternString.startsWith("/") || !urlPath.startsWith("/")) {
      if (patternString == "*") {
        rebuiltPath.add(patternString);
        foundAsteriskOnce = true;
        // TODO: Create Rule object
        return; // Compile finished: asterisk
      }
      else {
        throw new Exception("Pattern/Path must start with forward slash (/)");
      }
    }

    if (patternTokens.length != pathTokens.length) {
      throw new Exception("Pattern can not be matched with given path. (Pattern tokens:${patternTokens.length}, given URL tokens: ${pathTokens.length})");
    }

    for (var index = 0; index < patternTokens.length; index++) {
      var pattern = patternTokens[index];
      var item = urlPath[index];

      if (pattern.startsWith("{")) {
        // validating closing curly bracket
        if (!pattern.endsWith("}")) {
          throw new Exception("Enclose template brackets correctly. ($pattern)");
        }

        // last added path is a Dart servlet. This will conclude accpeting servlet path.

      }
      else {
        // detecting dangling brackets
        if (pattern.allMatches("[\{\}]")) {
          throw new Exception("Incomplete template bracket(s) are found. ($pattern)");
        }

        if (pattern == item) {
          rebuiltPath.add(item);
        }
        else {
          throw new Exception("Unexpected pattern. (Expected: $pattern, Instead: $item)");
        }
      }
    }

    // TODO: If successful, create Rule object
    // For now, printing compilation result
    print(rebuiltPath);
    print(rebuiltParam);
  }

  bool isCompiled() => true;
  bool hasError() => false;

  List<String> errors() {
    throw new UnimplementedError();
  }
}
